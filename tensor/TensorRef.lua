local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Expression = require 'symmath.Expression'

local TensorRef = class(Expression)
TensorRef.name = 'TensorRef'
TensorRef.precedence = 10	-- stop wrapping tensor reps in parenthesis ...

function TensorRef:init(tensor, ...)
	TensorRef.super.init(self, tensor, ...)
	
	-- not necessarily true, for comma derivatives of scalars/expressions
	--assert(Tensor.is(tensor))	

	-- make sure the rest of the arguments are tensor indexes
	local TensorIndex = require 'symmath.tensor.TensorIndex'
	for i=1,select('#',...) do
		local index = select(i, ...)
		assert(TensorIndex.is(index), 'argument '..i..' of TensorRef is not a TensorIndex: '..require 'ext.tolua'(index))
	end
end

-- how does this behave any different than Expression:clone() 
function TensorRef:clone()
	return TensorRef(range(#self):map(function(i)
		return self[i]:clone()
	end):unpack())
end

TensorRef.visitorHandler = {
	Prune = function(prune, expr)
		local Tensor = require 'symmath.Tensor'
		local TensorIndex = require 'symmath.tensor.TensorIndex'
		
		local t = expr[1]
		local indexes = {table.unpack(expr,2)}

		-- if it's not a tensor ...
		if not Tensor.is(t) then 
			
			-- t _ab _cd => t _abcd
			if TensorRef.is(t) then
				return prune:apply(
					TensorRef(t[1], table():append{table.unpack(t,2)}:append(indexes):unpack())
				)
			end
			
			-- if this is a derivative then apply differentiation
			if indexes[1].derivative then
				if t.evaluateDerivative then
					return t:evaluateDerivative(function(x)
						return TensorRef(x, table.unpack(indexes))
					end)
				end
			end

			-- just leave the indexing there 
			return 
		end

		-- now transform all indexes that don't match up
		
		local foundDerivative
		local nonDerivativeIndexes = table()
		for i,index in ipairs(indexes) do
			if index.derivative then
				foundDerivative = true
			else
				nonDerivativeIndexes:insert(i)
			end
		end

		--[[ TODO possibly support for comma derivatives of (non-Tensor) scalar expressions?
		if is scalar then
			if #indexes > 0 then
				error("tried to apply "..#indexes.." indexes to a 0-rank tensor (a scalar): "..tostring(tensor))
			end
			if #nonDerivativeIndexes ~= 0 then
				error("Tensor.rep non-tensor needs as zero non-comma indexes as the tensor's rank.  Found "..#nonDerivativeIndexes.." but needed "..0)
			end
		else...
		--]]
		local rank = Tensor.rank(t)
		if #nonDerivativeIndexes ~= rank then
			error("Tensor() needs as many non-derivative indexes as the tensor's rank.  Found "..#nonDerivativeIndexes.." but needed "..rank)
		end

		-- this operates on indexes
		-- which hasn't been expanded according to commas just yet
		-- so commas must be all at the end
		local function transformIndexes(withDerivatives)
			-- raise all indexes, transform tensors accordingly
--print('transforming indexes '..table.map(indexes,tostring):concat',')
			for i=1,#indexes do
				if not indexes[i].derivative == not withDerivatives then

					-- TODO replace all of this, the upper/lower transforms, the inter-coordinate transforms
					-- with one general routine for transforming between basii (in place of transformIndex)

					t = t:applyRaiseOrLower(i, indexes[i])
					
					-- TODO this matches Tensor:applyRaiseOrLower
					local srcBasis, dstBasis
					if Tensor.__coordBasis then
						srcBasis = Tensor.findBasisForSymbol(t.variance[i].symbol)
						dstBasis = Tensor.findBasisForSymbol(indexes[i].symbol)
					end
				
					if srcBasis ~= dstBasis then
						-- only handling exchanges of variables at the moment
						
						local indexMap = {}
						for i=1,#dstBasis.variables do
							indexMap[i] = table.find(srcBasis.variables, dstBasis.variables[i])  --assert(..., "failed to find src variable in dst basis")
						end

--print('transforming tensor\n'..t)
						t = Tensor{
							-- only update indexes 1..i
							-- keep the rest the same
							-- TODO even better store an indexMap per 'i', and then update all at once
							--indexes = indexes,
							indexes = table.sub(indexes,1,i):append(table.sub(t.variance,i+1)),
							values = function(...)
								local srcIndexes = {...}
								srcIndexes[i] = indexMap[srcIndexes[i]] -- assert(..., "failed to remap\n"..tolua({i=i, srcIndexes=srcIndexes, indexMap=indexMap}, {indent=true}))
								if not srcIndexes[i] then return 0 end	-- zero whatever isn't there.
								-- but if it's a subindex then srcIndexes can be nil ...
--print('assigning at {'..table.concat(srcIndexes, ',')..'} to '..t[srcIndexes])
								return t[srcIndexes]
							end,
						}
--print('...into tensor\n'..t)
					end

					t.variance[i].symbol = indexes[i].symbol
					t.variance[i].number = indexes[i].number
				end
			end
		end

		transformIndexes(false)

		if foundDerivative then
			-- indexed starting at the first derivative index
			local basisForCommaIndex = {}
			for i=1,#indexes do
				if indexes[i].derivative then
					basisForCommaIndex[i] = Tensor.findBasisForSymbol(indexes[i].symbol)
				end
			end
		
			local newVariance = {}
			-- TODO straighten out the upper/lower vs differentiation order
			for i=1,#indexes do
				newVariance[i] = TensorIndex{
					symbol = indexes[i].symbol,
					lower = true,	-- when a tensor is differentiated, the index created is covariant
				}
			end

			t = Tensor{
				indexes = newVariance,
				values = function(...)
					local is = {...}
					-- pick out 
					local base = table()
					local deriv = table()
					for i=1,#is do
						if indexes[i].derivative then
							deriv:insert(basisForCommaIndex[i].variables[is[i]])
						else
							base:insert(is[i])
						end
					end
					local x = #base == 0 and t or t:get(base)
					for i,d in ipairs(deriv) do
						x = d:applyDiff(x)
					end
					return x
				end,
			}
			
			-- raise after differentiating
			-- TODO do this after each diff
			transformIndexes(true)

			for i=1,#indexes do
				indexes[i].derivative = false
			end
	--print('after differentiation: '..tensor)
		end
		
		-- handle specific number/variable indexes
		do
			local foundNumbers = table.find(indexes, nil, function(index)
				return index.number
			end)
			if foundNumbers then
				local newdim = t:dim()
				local srcIndexes = {table.unpack(indexes)}
				local sis = {}
				for i=#newdim,1,-1 do
					if indexes[i].number then
						sis[i] = indexes[i].number
						table.remove(indexes, i)
						table.remove(newdim, i)
					end
				end
				if #newdim == 0 then
					return prune(t:get(sis))
				else
					local dstToSrc = {}
					for i=1,#newdim do
						dstToSrc[i] = assert(table.find(srcIndexes, indexes[i]))
					end
					t = Tensor{
						dim = newdim,
						indexes = t.variance,
						values = function(...)
							local is = {...}
							for i=1,#is do
								sis[dstToSrc[i]] = is[i]
							end
							return t:get(sis)
						end,
					}
				end
			end
		end

		-- for all indexes
		
		-- apply any summations upon construction
		-- if any two indexes match then zero non-diagonal entries in the resulting tensor
		--  (scaling with the delta tensor)

		t = t:simplifyTraces()
		if Tensor.is(t) then 
			for i,index in ipairs(t.variance) do
				assert(index.number or index.symbol, "failed to find index on "..i.." of "..#t.variance)
			end	
		end
		return prune(t)
	end,
}

return TensorRef
