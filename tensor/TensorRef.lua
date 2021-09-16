local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Expression = require 'symmath.Expression'
local Wildcard = require 'symmath.Wildcard'

local TensorRef = class(Expression)
TensorRef.name = 'TensorRef'
TensorRef.precedence = 10	-- stop wrapping tensor reps in parenthesis ...

function TensorRef:init(tensor, ...)
	TensorRef.super.init(self, tensor, ...)
	
	-- not necessarily true, for comma derivatives of scalars/expressions
	--assert(Tensor:isa(tensor))	

	-- make sure the rest of the arguments are tensor indexes
	local TensorIndex = require 'symmath.tensor.TensorIndex'
	for i=1,select('#',...) do
		local index = select(i, ...)
		if not (TensorIndex:isa(index) or Wildcard:isa(index)) then
			error('argument '..(i+1)..' of TensorRef is not a TensorIndex or Wildcard: '..require 'ext.tolua'(index))
		end
	end
end

function TensorRef:countNonDerivIndexes()
	local count = 0
	local foundDeriv
	for i=2,#self do
		if not self[i].derivative then
			assert(not foundDeriv, "found some non-derivatives after derivatives")
			count = count + 1
		else
			foundDeriv = true
		end
	end
	return count
end

function TensorRef:hasIndex(symbol)
	for i=2,#self do
		if self[i].symbol == symbol then return true end
	end
	return false
end

--[[
hasDerivIndex() if any indexes are derivatives then it returns the first derivative index
hasDerivIndex(sym1, sym2, ... symN) if any index is a derivative and has a symbol matching sym1...symN, returns that index
TODO maybe return the location within TensorIndex of the derivative?
--]]
function TensorRef:hasDerivIndex(...)
	local n = select('#', ...)
	for i=2,#self do
		local si = self[i]
		if si.derivative then 
			if n == 0 then return si end 
			for j=1,n do
				if si.symbol == select(j, ...) then return si end
			end
		end
	end
	return false
end


function TensorRef:hasTensorIndex(symbol)
	for i=2,#self do
		if self[i].symbol == symbol and not self[i].derivative then return true end
	end
	return false
end


-- how does this behave any different than Expression:clone() 
function TensorRef:clone()
	return TensorRef(range(#self):map(function(i)
		return self[i]:clone()
	end):unpack())
end

function TensorRef:setDependentVars(...)
	local Variable = require 'symmath.Variable'
	if not Variable:isa(self[1]) then
		error("cannot yet call a non-Variable, non-TensorRef(Variable) to :setDependentVars() on other variables/tensrrefs-of-variables")
	end
	local var = self[1]

	-- filter out setDependentVars() of matching # of tensorref indexes
	-- this way x:setDependentVars(y) and x'^i':setDependentVars(y) are separate
	if var.dependentVars then
		var.dependentVars = var.dependentVars:filter(function(depvar)
			return depvar.src == var
			or #depvar.src ~= #self
		end)
	else
		var.dependentVars = table()
	end
	var.dependentVars:append(table{...}:mapi(function(wrt)
		return {src=self:clone(), wrt=wrt:clone()}
	end))
	var:removeDuplicateDepends()
end

function TensorRef:getDependentVars()
	return (self.dependentVars or table()):mapi(function(depvar, k, t)
		return #depvar.src == #self and depvar.wrt or nil, #t+1
	end)
end

--[[
similar function is found in symmath/Variable.lua
only return true for the dependentVars entries with src==TensorRef(self, ...) with matching # indexes
that match x (either Variable equals, or TensorRef with matching Variable and # of indexes)
--]]
function TensorRef:dependsOn(x)
--print('does TensorRef '..self..' depend on '..x..'?')
	local Variable = require 'symmath.Variable'

	-- TODO handle dense tensor? idk, this is for variables wrt other variables

	-- not handling non-variable T^ij
	if not Variable:isa(self[1]) then return end

	-- y^i depends on y^j
	-- (but y^ij is considered a different variable, so is not dependent on y^i)
	if TensorRef:isa(x) 
	and self[1] == x[1] 
	and #self == #x
	then 
		return true 
	end

	if self[1].dependentVars then
		for _,depvar in ipairs(self[1].dependentVars) do
			if TensorRef:isa(depvar.src)
			and #depvar.src == #self
			then
				local wrt = depvar.wrt
				if wrt:dependsOn(x) then return true end
			end
		end
	end
	return false
end


TensorRef.rules = {
	Prune = {
		-- t _ab _cd => t _abcd
		{combine = function(prune, expr)
			local Tensor = require 'symmath.Tensor'
			local t = expr[1]
			if not Tensor:isa(t) then 
				if TensorRef:isa(t) then
					local indexes = {table.unpack(expr,2)}
					return prune:apply(
						TensorRef(t[1], table():append{table.unpack(t,2)}:append(indexes):unpack())
					)
				end
			end	
		end},

		{evalDeriv = function(prune, expr)
			local Tensor = require 'symmath.Tensor'
			local t = expr[1]
			if not Tensor:isa(t) 
			and expr[2].derivative
			then 
				-- if it can be evaluated then apply differentiation
				-- (if it is a tensor or variable then it won't be applied)
				if t.evaluateDerivative then
					return prune:apply(t:evaluateDerivative(function(x)
						return TensorRef(x, table.unpack(expr, 2))
					end))
				end
			end
		end},

		{replacePartial = function(prune, expr)
			local Tensor = require 'symmath.Tensor'
			local t = expr[1]
			if not Tensor:isa(t)			-- if it's not a tensor ...
			and expr[2].derivative then	-- if this is a derivative then 
				local indexes = {table.unpack(expr,2)}
				-- if any derivative indexes are for single variables then apply them directly
				local diffvars
				for i=#indexes,1,-1 do
					local index = indexes[i]
					local basis = Tensor.findBasisForSymbol(index.symbol)
					-- maybe I should just treat numbers like symbols?
					if basis and #basis.variables == 1 then
						table.remove(indexes, i)
						local v = basis.variables[1]
						diffvars = diffvars or table()
						diffvars:insert(1,v)
					end
				end
				if diffvars and #diffvars > 0 then
					local Derivative = require 'symmath.Derivative'
					local result = Derivative(t, diffvars:unpack())
					if #indexes > 0 then
						result = TensorRef(result, table.unpack(indexes)) 
					end
					return prune:apply(result)
				end
			end
		end},

		{apply = function(prune, expr)
			local Tensor = require 'symmath.Tensor'
			
			local t = expr[1]
			local indexes = {table.unpack(expr,2)}

			-- if it's not a tensor ...
			-- ...then just leave the indexing there 
			if not Tensor:isa(t) then return end

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
				error("Tensor() needs as many non-derivative indexes as the tensor's rank.  Found "..#nonDerivativeIndexes.." but needed "..rank.." for expression "..expr)
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
			
				local TensorIndex = require 'symmath.tensor.TensorIndex'
			
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
					return type(index.symbol) == 'number'
				end)
				if foundNumbers then
					local newdim = t:dim()
					local srcIndexes = {table.unpack(indexes)}
					local sis = {}
					for i=#newdim,1,-1 do
						if type(indexes[i].symbol) == 'number' then
							sis[i] = indexes[i].symbol
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
			if Tensor:isa(t) then 
				for i,index in ipairs(t.variance) do
					assert(index.symbol, "failed to find index on "..i.." of "..#t.variance)
				end	
			end
			return prune(t)
		end},
	},
}

return TensorRef
