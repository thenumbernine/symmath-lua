local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Expression = require 'symmath.Expression'
local Wildcard = require 'symmath.Wildcard'
local symmath

local TensorRef = class(Expression)
TensorRef.name = 'Tensor.Ref'
TensorRef.precedence = 10	-- stop wrapping tensor reps in parenthesis ...

function TensorRef:init(tensor, ...)
	TensorRef.super.init(self, tensor, ...)
	
	-- not necessarily true, for comma derivatives of scalars/expressions
	--assert(Tensor:isa(tensor))	

	-- make sure the rest of the arguments are tensor indexes
	symmath = symmath or require 'symmath'
	local TensorIndex = symmath.Tensor.Index
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
	symmath = symmath or require 'symmath'
	local Variable = symmath.Variable
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
	symmath = symmath or require 'symmath'
	local Variable = symmath.Variable

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
				-- [[ matches Variabe:dependsOn
				local wrt = depvar.wrt
				if Variable:isa(wrt)
				and wrt == x
				then
					return true
				end
				if TensorRef:isa(wrt)
				and TensorRef:isa(x)
				and #wrt == #x
				then
					return true
				end
				--]]
			end
		end
	end
	return false
end

--[[
similar function is found in symmath/Variable.lua
also an equivalent function in symmath/op/eq.lua
set a variable's dependent vars to all variables found in the expression
--]]
function TensorRef:inferDepenedentVars(...)
	self:setDependentVars(TensorRef.super.getDependentVars(...):unpack())
end

--[[
set symmetries of the Tensor.Ref
but store the symmetry in the Variable
since creating new Ref's happens all the time

TODO 
right now I'm just setting this to work like the :symmetrizeIndexes
but maybe change that as well, and this, to only symmetrize indexes
if the degree matches

TODO how about symmetries in derivatives?  i suppose that's obvious
but how about symmetries between deriv- and non-deriv- indexes?  like d_kij,l = d_lij,k
NOTICE lower'ness can be sorted as well ... but also notice if g_ij = g_ji then g^i_j != g_j^i, but g^ij = g^ji, so only sort it if the lower-ness is consistent (and if there's no derivatives after it? unless ofc it is deriv'd indexes)
--]]
function TensorRef:setSymmetries(...)
	symmath = symmath or require 'symmath'
	local Variable = symmath.Variable
	
	local var = self[1]
	if not Variable:isa(var) then
		error("can only set symmetries of a TensorRef of a Variable")
	end
	
	local targetDegree = #self-1
	
	-- override all symmetries every time you call?
	-- or just override all of them for this particular degree?
	-- or just override them for this particular combination of lower and deriv?
	-- or just the deriv and degree?
	local key = self:getSymmetriesKey()
	var.indexSymmetries = var.indexSymmetries or {}
	var.indexSymmetries[key] = table()

	for i=1,select('#', ...) do
		local indexNumbers = table(select(i, ...))
		-- infer whether we are symmetrizing across derivatives
		local acrossDerivs 
		local deriv = self[1+indexNumbers[1]].derivative
		local acrossLowers
		local lower = not not self[1+indexNumbers[1]].lower
		local lowers = {lower}
		for j=2,#indexNumbers do
			local oderiv = self[1+indexNumbers[j]].derivative
			local olower = not not self[1+indexNumbers[j]].lower
			lowers[j] = olower
			if deriv ~= oderiv then acrossDerivs = true end
			if lower ~= olower then acrossLowers = true end
		end
		var.indexSymmetries[key]:insert{
			indexNumbers = indexNumbers,
			lowers = lowers,
			-- this can be inferred from the key
			targetDegree = targetDegree,
			acrossDerivs = acrossDerivs,
			acrossLowers = acrossLowers,
		}
	end
end

function TensorRef:getSymmetriesKey()
	return table.sub(self, 2):mapi(function(index) 
		--[[ using matching upper/lower and deriv?
		return (index.lower and '_' or '^')..(index.degree or '')
		--]]
		-- [[ use deriv and degree?
		return index.degree or ' '
		--]]
	end):concat()
end

function TensorRef:getSymmetries()
	symmath = symmath or require 'symmath'
	local Variable = symmath.Variable
	local var = self[1]
	if not Variable:isa(var) then return end	-- otherwise we have no symmetry info
	if not var.indexSymmetries then return end
	local key = self:getSymmetriesKey()
	local syms = var.indexSymmetries[key]
	if not syms then return end
	-- why unpack()? only so the arguments can match setSymmetries()
	return syms:unpack()
end

--[[
if the variable matches, the size matches, and the derivs matches (ignore upper/lower) then ...
TODO how about implicit for derivatives of tensors, like K_(ij) => K_(ij),k

hmm this asks the question, should the symmetries also include deriv-only sets of indexes?
how about deriv+non-deriv? (like d_kij,l == d_lij,k)
	
assert all the sym indexes have matching lower and deriv~=nil
but the lower doesn't have to match the 'find' TensorRef in 'symmetries'
--]]
function TensorRef:applySymmetries()
	symmath = symmath or require 'symmath'
	local Variable = symmath.Variable
	local var = self[1]
	if not Variable:isa(var) then 
		error("can't apply symmetries to a Tensor.Ref that is not of a Variable") 
	end
	
	local result = self:clone()
	if not var.indexSymmetries then return result end
	
	local key = self:getSymmetriesKey()
	local syms = var.indexSymmetries[key]
	if not syms then return result end

	for _,sym in ipairs(syms) do
		-- [[ this doesn't consider targetDegree, but the key does
		result = result:symmetrizeIndexes(var, sym.indexNumbers, sym.acrossDerivs)
		--]]
		--[[ goes slower than :symmetrizeIndexes()
		local is = table()
		for _,i in ipairs(sym.indexNumbers) do
			is:insert(result[1+i])
		end
		is:sort(function(a,b)
			if a.lower and not b.lower then return false end
			if b.lower and not a.lower then return true end
			return a.symbol < b.symbol
		end)
		local lowerChanges
		local hasDeriv = is[1].derivative
		local lower = is[1].lower
		for i=2,#is do
			if lower ~= is[i].lower then lowerChanges = true end
			if is[i].derivative then hasDeriv = true end
		end
		-- TODO don't change raise/lower if the set of indexes crosses(includes?) any derivatives
		if not (hasDeriv and lowerChanges) then
			for j,i in ipairs(sym.indexNumbers) do
				result[1+i].symbol = is[j].symbol
				result[1+i].lower = is[j].lower
			end
		end
		--]]
	end
	return result
end

--[[
args:
	var = base var, to replace TensorRef(var, ...) with TensorRef( dense form of var, ...)
	indexes = var indexes

TODO the C name exporter is pretty application-specific
but I think so is the C exporter for TensorRef anyways.
--]]
function TensorRef.makeDense(x)
	symmath = symmath or require 'symmath'
	local Tensor = symmath.Tensor
	local Variable = symmath.Variable
	assert(TensorRef:isa(x))
	assert(Variable:isa(x[1]))
--printbr('creating dense tensor', x)	
	local basevar = x[1]:clone()
	local indexes = table.sub(x, 2):mapi(function(index) return index:clone() end)
	local numDeriv = 0
	local indexesWithoutDeriv = indexes:mapi(function(index)
		index = index:clone()
		if index.derivative == ',' then numDeriv = numDeriv + 1 end
		index.derivative = nil
		return index
	end)
	local degreeCSuffix = '_'..indexes:mapi(function(index)
		return index.lower and 'l' or 'u'
	end):concat()
	
	-- ss[1] is the TensorRef, ss[2...] is the 
	local allsymkeys = {}
	for _,s in ipairs{x:getSymmetries()} do
		-- only if the lowers of the indexes match with s's form
		-- or if they are both lowered or both uppered
		if not s.acrossLowers then
			local acrossLowers 
			local lower = not not x[1+s.indexNumbers[1]].lower
			for _,i in ipairs(s.indexNumbers) do
				local olower = not not x[1+i].lower
				if lower ~= olower then
					acrossLowers = true
					break
				end
			end
			if not acrossLowers then
				for _,i in ipairs(s.indexNumbers) do
					allsymkeys[i] = true
				end
			end
		end
	end

	local chart = Tensor:findChartForSymbol()
	assert(chart, "can't make dense without creating a Tensor.Chart first!")
	local xNames = table.mapi(chart.coords, function(c) return c.name end)

	local result = Tensor(indexesWithoutDeriv, function(...)
		
		-- [[ TODO this is just the same as :reindex() ...
		local is = {...}
		local thisIndexes = indexes:mapi(function(index) return index:clone() end)
		for i=1,#is do
			thisIndexes[i].symbol = xNames[is[i]]
		end
		local thisRef = TensorRef(basevar, thisIndexes:unpack())
		--]]
		
		-- now sort 'thisIndexes' based on symmetries
		thisRef = thisRef:applySymmetries()
		
		-- TODO how to specify names per exporter?
		local v = Variable(symmath.export.LaTeX:applyLaTeX(thisRef))
	
		-- insert dots between non-sym indexes
		local thisIndexCSuffix = table()
		for i=1,#thisRef-1 do
			local index = thisRef[i+1]
			if i > 1 and not (allsymkeys[i-1] and allsymkeys[i]) then
				thisIndexCSuffix:insert'.'
			end
			thisIndexCSuffix:insert(index.symbol)
		end
		thisIndexCSuffix = thisIndexCSuffix:concat()
		
		local derivCPrefix
		if numDeriv == 0 then
			derivCPrefix = ''
		elseif numDeriv == 1 then
			derivCPrefix = 'partial_'
		else
			derivCPrefix = 'partial'..numDeriv..'_'
		end
		local cname = derivCPrefix .. basevar:nameForExporter'C'..degreeCSuffix..'.'..thisIndexCSuffix
		v:nameForExporter('C', cname)
		
		return v
	end)
--printbr(x, '=>', result)
	return result
end

-- returns true if the var matches and the index raise/lower and derivatives all match
--  but doesn't care what the symbols are
function TensorRef.matchesIndexForm(a, b)
	local ta = TensorRef:isa(a)
	local tb = TensorRef:isa(b)
	if not ta and not tb then return true end
	if not ta ~= not tb then return false end
	local na = #a
	if na ~= #b then return false end
	if a[1] ~= b[1] then return false end	-- TODO should this function also verify that the vars match?
	for i=2,na do
		if not not a[i].lower ~= not not b[i].lower then return false end
		if a[i].derivative ~= b[i].derivative then return false end
	end
	return true
end

-- returns true if the var is the same, the length is the same, and the different derivs are the same
-- doesn't care about lowers
-- doesn't care about symbols
function TensorRef.matchesDegreeAndDeriv(a, b)
	assert(a)
	assert(b)
	local ta = TensorRef:isa(a)
	local tb = TensorRef:isa(b)
	if not ta and not tb then return true end
	if not ta ~= not tb then return false end
	local na = #a
	if na ~= #b then return false end
	if a[1] ~= b[1] then return false end	-- TODO should this function also verify that the vars match?
	for i=2,na do
		if a[i].derivative ~= b[i].derivative then return false end
	end
	return true
end

function TensorRef.removeDerivs(x)
	assert(TensorRef:isa(x))
	x = x:clone()
	for i=#x,2,-1 do
		if x[i].derivative then
			table.remove(x,i)
		end
	end
	return x
end

function TensorRef.matchesDegreeWithoutDerivs(a,b)
	a = TensorRef.removeDerivs(a)
	b = TensorRef.removeDerivs(b)
	return TensorRef.matchesDegreeAndDeriv(a,b)
end

TensorRef.rules = {
	Prune = {
		-- t _ab _cd => t _abcd
		{combine = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Tensor = symmath.Tensor
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
			symmath = symmath or require 'symmath'
			local Tensor = symmath.Tensor
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
			symmath = symmath or require 'symmath'
			local Tensor = symmath.Tensor
			local t = expr[1]
			if not Tensor:isa(t)			-- if it's not a tensor ...
			and expr[2].derivative then	-- if this is a derivative then 
				local indexes = {table.unpack(expr,2)}
				-- if any derivative indexes are for single variables then apply them directly
				local diffvars
				for i=#indexes,1,-1 do
					local index = indexes[i]
					-- TODO if Tensor is a dense-Tensor ... and Variables are used to represent indexed-Tensors .. then who determines what chart a Variable indexed-Tensor belongs to?
					local chart = Tensor:findChartForSymbol(index.symbol)
					-- maybe I should just treat numbers like symbols?
					if chart and #chart.coords == 1 then
						table.remove(indexes, i)
						local v = chart.coords[1]
						diffvars = diffvars or table()
						diffvars:insert(1,v)
					end
				end
				if diffvars and #diffvars > 0 then
					symmath = symmath or require 'symmath'
					local Derivative = symmath.Derivative
					local result = Derivative(t, diffvars:unpack())
					if #indexes > 0 then
						result = TensorRef(result, table.unpack(indexes)) 
					end
					return prune:apply(result)
				end
			end
		end},

		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Tensor = symmath.Tensor
			
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
					error("tried to apply "..#indexes.." indexes to a 0-degree tensor (a scalar): "..tostring(tensor))
				end
				if #nonDerivativeIndexes ~= 0 then
					error("Tensor.rep non-tensor needs as zero non-comma indexes as the tensor's degree.  Found "..#nonDerivativeIndexes.." but needed "..0)
				end
			else...
			--]]
			local degree = Tensor.degree(t)
			if #nonDerivativeIndexes ~= degree then
				error("Tensor() needs as many non-derivative indexes as the tensor's degree.  Found "..#nonDerivativeIndexes.." but needed "..degree.." for expression "..expr)
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
						local srcChart = t:findChartForSymbol(t.variance[i].symbol)
						local dstChart = t:findChartForSymbol(indexes[i].symbol)
					
						if srcChart ~= dstChart then
							-- only handling exchanges of variables at the moment
							
							local indexMap = {}
							for i=1,#dstChart.coords do
								indexMap[i] = table.find(srcChart.coords, dstChart.coords[i])  --assert(..., "failed to find src variable in dst chart")
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
				local chartForCommaIndex = {}
				for i=1,#indexes do
					if indexes[i].derivative then
						chartForCommaIndex[i] = t:findChartForSymbol(indexes[i].symbol)
					end
				end
			
				symmath = symmath or require 'symmath'
				local TensorIndex = symmath.Tensor.Index
			
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
								deriv:insert(chartForCommaIndex[i].tangentSpaceOperators[is[i]])
							else
								base:insert(is[i])
							end
						end
						local x = #base == 0 and t or t:get(base)
						for i,d in ipairs(deriv) do
							x = d(x)
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
