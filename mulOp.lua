local class = require 'ext.class'
local table = require 'ext.table'
local BinaryOp = require 'symmath.BinaryOp'

mulOp = class(BinaryOp)
mulOp.implicitName = true
mulOp.precedence = 3
mulOp.name = '*'

function mulOp:evaluateDerivative(...)
	local diff = require 'symmath'.diff
	local addOp = require 'symmath.addOp'
	local sums = table()
	for i=1,#self do
		local terms = table()
		for j=1,#self do
			if i == j then
				terms:insert(diff(self[j]:clone(), ...))
			else
				terms:insert(self[j]:clone())
			end
		end
		if #terms == 1 then
			sums:insert(terms[1])
		else
			sums:insert(mulOp(terms:unpack()))
		end
	end
	if #sums == 1 then
		return sums[1]
	else
		return addOp(sums:unpack())
	end
end

-- now that we've got matrix multilpication, this becomes more difficult...
-- non-commutative objects (matrices) need to be compared in-order
-- commutative objects can be compared in any order
mulOp.__eq = function(a,b)
	-- order-independent
	local a = table(a)
	local b = table(b)
	for ai=#a,1,-1 do
		-- non-commutative compare...
		if not a[ai].mulNonCommutative then
			-- table.find uses == uses __eq which ... should ... only pick bi if it is mulNonCommutative as well (crossing fingers, it's based on the equality implementation)
			local bi = b:find(a[ai])
			if bi then
				a:remove(ai)
				b:remove(bi)
			end
		end
	end
	-- now compare what's left in-order (since it's non-commutative)
	if #a ~= #b then return false end
	for i=1,#a do
		if a[i] ~= b[i] then return false end
	end
	return true
end

mulOp.visitorHandler = {
	Eval = function(eval, expr)
		local result = 1
		for _,x in ipairs(expr) do
			result = result * eval:apply(x)
		end
		return result
	end,

	Expand = function(expand, expr)
		local symmath = require 'symmath'	
		local addOp = symmath.addOp
		local subOp = symmath.subOp
		
		expr = expr:clone()
		
		--[[
		a * (b + c) * d * e becomes
		(a * b * d * e) + (a * c * d * e)
		--]]

		for i,x in ipairs(expr) do
			if addOp.is(x) or subOp.is(x) then
				local terms = table()
				for j,xch in ipairs(x) do
					local term = expr:clone()
					term[i] = xch:clone()
					terms:insert(term)
				end
				expr = getmetatable(x)(table.unpack(terms))
				return expand:apply(expr)
			end
		end
	end,

	FactorDivision = function(factor, expr)
		local symmath = require 'symmath'
		local addOp = symmath.addOp
		local subOp = symmath.subOp
		
		-- first time processing we want to simplify()
		--  to remove powers and divisions
		--expr = expr:simplify()
		-- but not recursively ... hmm ...
		
		-- flatten multiplications
		-- TODO this is also in Prune
		-- make Rules
		for i=#expr,1,-1 do
			local ch = expr[i]
			if mulOp.is(ch) then
				table.remove(expr, i)
				for j=#ch,1,-1 do
					local chch = ch[j]
					table.insert(expr, i, chch)
				end
				return factor:apply(expr)
			end
		end
		
		-- distribute multiplication
		-- TODO this is also in Expand
		-- make Rules
		for i,ch in ipairs(expr) do
			if addOp.is(ch) or subOp.is(ch) then
				local terms = table()
				for j,chch in ipairs(ch) do
					local term = expr:clone()
					term[i] = chch:clone()
					terms:insert(term)
				end
				expr = getmetatable(ch)(table.unpack(terms))
				return factor:apply(expr)
			end
		end
	end,

	Prune = function(prune, expr)	
		local symmath = require 'symmath'
		local Constant = symmath.Constant
		local powOp = symmath.powOp
		local divOp = symmath.divOp

		assert(#expr > 0)
		
		-- flatten multiplications
		for i=#expr,1,-1 do
			local ch = expr[i]
			if mulOp.is(ch) then
				-- this looks like a job for splice ...
				table.remove(expr, i)
				for j=#ch,1,-1 do
					local chch = ch[j]
					table.insert(expr, i, chch)
				end
				return prune:apply(expr)
			end
		end
		
		-- move unary minuses up
		--[[ pruning unmOp immediately
		do
			local unmOp = require 'symmath.unmOp'
			local unmOpCount = 0
			for i=1,#expr do
				local ch = expr[i]
				if unmOp.is(ch) then
					unmOpCount = unmOpCount + 1
					expr[i] = ch[1]
				end
			end
			if unmOpCount % 2 == 1 then
				return -prune:apply(expr)	-- move unm outside and simplify what's left
			elseif unmOpCount ~= 0 then
				return prune:apply(expr)	-- got an even number?  remove it and simplify this
			end
		end
		--]]

		-- push all Constants to the lhs, sum as we go
		local cval = 1
		for i=#expr,1,-1 do
			if Constant.is(expr[i]) then
				cval = cval * table.remove(expr, i).value
			end
		end

		-- if it's all constants then return what we got
		if #expr == 0 then 
			return Constant(cval) 
		end
		
		if cval == 0 then 
			return Constant(0) 
		end
		
		if cval ~= 1 then
			table.insert(expr, 1, Constant(cval))
		else
			if #expr == 1 then 
				return prune:apply(expr[1]) 
			end
		end

		-- [[ and now for Matrix*Matrix multiplication ...
		for i=#expr,2,-1 do
			local rhs = expr[i]
			local lhs = expr[i-1]
		
			local result
			if lhs.pruneMul then
				result = lhs.pruneMul(lhs, rhs)
			elseif rhs.pruneMul then
				result = rhs.pruneMul(lhs, rhs)
			end
			if result then
				table.remove(expr, i)
				expr[i-1] = result
				if #expr == 1 then expr = expr[1] end
				return prune:apply(expr)
			end
		end
		--]]

		-- [[ a^m * a^n => a^(m + n)
		do
			local modified = false
			local i = 1
			while i <= #expr do
				local x = expr[i]
				local base
				local power
				if powOp.is(x) then
					base = x[1]
					power = x[2]
				else
					base = x
					power = Constant(1)
				end
				
				if base then
					local j = i + 1
					while j <= #expr do
						local x2 = expr[j]
						local base2
						local power2
						if powOp.is(x2) then
							base2 = x2[1]
							power2 = x2[2]
						else
							base2 = x2
							power2 = Constant(1)
						end
						if base2 == base then
							modified = true
							table.remove(expr, j)
							j = j - 1
							power = power + power2
						end
						j = j + 1
					end
					if modified then
						expr[i] = base ^ power
					end
				end
				i = i + 1
			end
			if modified then
				if #expr == 1 then expr = expr[1] end
				return prune:apply(expr)
			end
		end
		--]]
		
		-- [[ factor out denominators
		-- a * b * (c / d) => (a * b * c) / d
		--  generalization:
		-- a^m * b^n * (c/d)^p = (a^m * b^n * c^p) / d^p
		do
			local uniqueDenomIndexes = table()
			
			local denoms = table()
			local powers = table()
			local bases = table()
			
			for i=1,#expr do
				-- decompose expressions of the form 
				--  (base / denom) ^ power
				local base = expr[i]
				local power = Constant(1)
				local denom = Constant(1)

				if powOp.is(base) then
					base, power = table.unpack(base)
				end
				if divOp.is(base) then
					base, denom = table.unpack(base)
				end
				if denom ~= Constant(1) then
					uniqueDenomIndexes:insert(i)
				end

				denoms:insert(denom)
				powers:insert(power)
				bases:insert(base)
			end
			
			if #uniqueDenomIndexes > 0 then	
				
				local num
				if #bases == 1 then
					num = bases[1]
					if powers[1] ~= Constant(1) then
						num = num ^ powers[1]
					end
				else
					num = bases:map(function(base,i)
						if powers[i] == Constant(1) then
							return base
						else
							return base ^ powers[i]
						end
					end)
					assert(#num > 0)
					if #num == 1 then
						num = num[1]
					else
						num = mulOp(num:unpack())
					end
				end
				
				local denom
				if #uniqueDenomIndexes == 1 then
					local i = uniqueDenomIndexes[1]
					denom = denoms[i]
					if powers[i] ~= Constant(1) then
						denom = denom^powers[i]
					end
				elseif #denoms > 1 then
					denom = mulOp(table.unpack(uniqueDenomIndexes:map(function(i)
						if powers[i] == Constant(1) then
							return denoms[i]
						else
							return denoms[i]^powers[i]
						end
					end)))
				end
				
				local expr = num
				if denom ~= Constant(1) then
					expr = expr / denom
				end
				return prune:apply(expr)
			end
		end
		--]]
	end,

	Tidy = function(tidy, expr)
		local symmath = require 'symmath'
		local unmOp = symmath.unmOp
		local Constant = symmath.Constant
		
		-- -x * y * z => -(x * y * z)
		-- -x * y * -z => x * y * z
		do
			local unmOpCount = 0
			for i=1,#expr do
				local ch = expr[i]
				if unmOp.is(ch) then
					unmOpCount = unmOpCount + 1
					expr[i] = ch[1]
				end
			end
			assert(#expr > 1)
			if unmOpCount % 2 == 1 then
				return -tidy:apply(expr)	-- move unm outside and simplify what's left
			elseif unmOpCount ~= 0 then
				return tidy:apply(expr)	-- got an even number?  remove it and simplify this
			end
		end
		
		-- (has to be solved post-prune() because tidy's Constant+unmOp will have made some new ones)
		-- 1 * x => x 	
		local first = expr[1]
		if Constant.is(first) and first.value == 1 then
			table.remove(expr, 1)
			if #expr == 1 then
				expr = expr[1]
			end
			return tidy:apply(expr)
		end
	end,
}
-- ExpandPolynomial inherits from Expand
mulOp.visitorHandler.ExpandPolynomial = mulOp.visitorHandler.Expand

return mulOp
