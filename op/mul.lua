local class = require 'ext.class'
local table = require 'ext.table'
local Binary = require 'symmath.op.Binary'

local mul = class(Binary)
mul.implicitName = true
mul.precedence = 3
mul.name = '*'

function mul:init(...)
	mul.super.init(self, ...)

	-- auto flatten any muls
	for i=#self,1,-1 do
		if mul.is(self[i]) then
			local x = table.remove(self, i)
			for j=#x,1,-1 do
				table.insert(self, i, x[j])
			end
		end
	end
end

function mul:evaluateDerivative(deriv, ...)
	local add = require 'symmath.op.add'
	local sums = table()
	for i=1,#self do
		local terms = table()
		for j=1,#self do
			if i == j then
				terms:insert(deriv(self[j]:clone(), ...))
			else
				terms:insert(self[j]:clone())
			end
		end
		if #terms == 1 then
			sums:insert(terms[1])
		else
			sums:insert(mul(terms:unpack()))
		end
	end
	if #sums == 1 then
		return sums[1]
	else
		return add(sums:unpack())
	end
end

mul.removeIfContains = require 'symmath.commutativeRemove'

-- now that we've got matrix multilpication, this becomes more difficult...
-- non-commutative objects (matrices) need to be compared in-order
-- commutative objects can be compared in any order
mul.match = function(a, b, matches)
	matches = matches or table()
	if require 'symmath.Wildcard'.is(b) and b:wildcardMatches(a) then
		if matches[b.index] == nil then
			matches[b.index] = a
			return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
		else
			if b ~= matches[b.index] then return false end
		end	
	else
		if not mul.is(a) or not mul.is(b) then return false end
	end	
	
	-- order-independent
	local a = table(a)
	local b = table(b)
	for ai=#a,1,-1 do
		-- non-commutative compare...
		if not a[ai].mulNonCommutative then
			-- table.find uses == uses __eq which ... should ... only pick bi if it is mulNonCommutative as well (crossing fingers, it's based on the equality implementation)
			--local bi = b:find(a[ai])
			local bi
			for _bi=1,#b do
				if b[_bi]:match(a[ai], matches) then
					bi = _bi
					break
				end
			end
			if bi then
				a:remove(ai)
				b:remove(bi)
			end
		end
	end
	
	-- now compare what's left in-order (since it's non-commutative)
	local n = #a
	if n ~= #b then return false end
	for i=1,n do
		if not a[i]:match(b[i], matches) then return false end
	end
	
	return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
end

function mul:reverse(soln, index)
	-- y = a_1 * ... * a_j(x) * ... * a_n
	-- => a_j(x) = y / (a_1 * ... * a_j-1 * a_j+1 * ... * a_n)
	for k=1,#self do
		if k ~= index then
			soln = soln / self[k]:clone()
		end
	end
	return soln
end

function mul:getRealDomain()
	local I = self[1]:getRealDomain()
	if I == nil then return nil end
	for i=2,#self do
		local I2 = self[i]:getRealDomain()
		if I2 == nil then return nil end
		I = I * I2
	end
	return I
end

function mul:flatten()
	for i=#self,1,-1 do
		local ch = self[i]
		if mul.is(ch) then
			local expr = {table.unpack(self)}
			table.remove(expr, i)
			for j=#ch,1,-1 do
				local chch = ch[j]
				table.insert(expr, i, chch)
			end
			return mul(table.unpack(expr))
		end
	end
end

--[[
a * (b + c) * d * e becomes
(a * b * d * e) + (a * c * d * e)
--]]
function mul:distribute()
	local add = require 'symmath.op.add'
	local sub = require 'symmath.op.sub'
	for i,ch in ipairs(self) do
		if add.is(ch) or sub.is(ch) then
			local terms = table()
			for j,chch in ipairs(ch) do
				local term = self:clone()
				term[i] = chch:clone()
				terms:insert(term)
			end
			return getmetatable(ch)(table.unpack(terms))
		end
	end
end

mul.rules = {
	Eval = {
		{apply = function(eval, expr)
			local result = 1
			for _,x in ipairs(expr) do
				result = result * eval:apply(x)
			end
			return result
		end},
	},

	Expand = {
		{apply = function(expand, expr)
			local dstr = expr:distribute()
			if dstr then return expand:apply(dstr) end
		end},
	},

	FactorDivision = {
		{apply = function(factorDivision, expr)
			local Constant = require 'symmath.Constant'
			local div = require 'symmath.op.div'
			
			-- first time processing we want to simplify()
			--  to remove powers and divisions
			--expr = expr:simplify()
			-- but not recursively ... hmm ...
			
			-- flatten multiplications
			local flat = expr:flatten()
			if flat then return factorDivision:apply(flat) end

			-- distribute multiplication
			local dstr = expr:distribute()
			if dstr then return factorDivision:apply(dstr) end

			-- [[ same as Prune:

			-- push all fractions to the left
			for i=#expr,2,-1 do
				if div.is(expr[i])
				and Constant.is(expr[i][1])
				and Constant.is(expr[i][2])
				then
					table.insert(expr, 1, table.remove(expr, i))
				end
			end

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
					return factorDivision:apply(expr[1]) 
				end
			end
			
			--]]	
		end},
	},

	Prune = {
		{apply = function(prune, expr)	
			local Constant = require 'symmath.Constant'
			local pow = require 'symmath.op.pow'
			local div = require 'symmath.op.div'
			
			-- flatten multiplications
			local flat = expr:flatten()
			if flat then return prune:apply(flat) end
			
			-- move unary minuses up
			--[[ pruning unm immediately
			do
				local unm = require 'symmath.op.unm'
				local unmCount = 0
				for i=1,#expr do
					local ch = expr[i]
					if unm.is(ch) then
						unmCount = unmCount + 1
						expr[i] = ch[1]
					end
				end
				if unmCount % 2 == 1 then
					return -prune:apply(expr)	-- move unm outside and simplify what's left
				elseif unmCount ~= 0 then
					return prune:apply(expr)	-- got an even number?  remove it and simplify this
				end
			end
			--]]

			-- push all fractions to the left
			for i=#expr,2,-1 do
				if div.is(expr[i])
				and Constant.is(expr[i][1])
				and Constant.is(expr[i][2])
				then
					table.insert(expr, 1, table.remove(expr, i))
				end
			end

			
			-- [[ and now for Matrix*Matrix multiplication ...
			-- do this before the c * 0 = 0 rule
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

			-- [[ a^m * a^n => a^(m + n)
			do
				local modified = false
				local i = 1
				while i <= #expr do
					local x = expr[i]
					local base
					local power
					if pow.is(x) then
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
							if pow.is(x2) then
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

					if pow.is(base) then
						base, power = table.unpack(base)
					end
					if div.is(base) then
						base, denom = table.unpack(base)
					end
					if not Constant.isValue(denom, 1) then
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
						if not Constant.isValue(powers[1], 1) then
							num = num ^ powers[1]
						end
					else
						num = bases:map(function(base,i)
							if Constant.isValue(powers[i], 1) then
								return base
							else
								return base ^ powers[i]
							end
						end)
						assert(#num > 0)
						if #num == 1 then
							num = num[1]
						else
							num = mul(num:unpack())
						end
					end
					
					local denom
					if #uniqueDenomIndexes == 1 then
						local i = uniqueDenomIndexes[1]
						denom = denoms[i]
						if not Constant.isValue(powers[i], 1) then
							denom = denom^powers[i]
						end
					elseif #denoms > 1 then
						denom = mul(table.unpack(uniqueDenomIndexes:map(function(i)
							if Constant.isValue(powers[i], 1) then
								return denoms[i]
							else
								return denoms[i]^powers[i]
							end
						end)))
					end
					
					local expr = num
					if not Constant.isValue(denom, 1) then
						expr = expr / denom
					end
					return prune:apply(expr)
				end
			end
			--]]
		end},
	
		{logPow = function(prune, expr)
			local symmath = require 'symmath'
			-- b log(a) => log(a^b)
			-- I would like to push this to prevent x log(y) => log(y^x)
			-- but I would like to keep -1 * log(y) => log(y^-1)
			-- so I'll make a separate rule for that ...
			for i=1,#expr do
				if symmath.log.is(expr[i]) then
					expr = expr:clone()
					local a = table.remove(expr,i)
					if #expr == 1 then expr = expr[1] end
					return prune:apply(symmath.log(a[1] ^ expr))
				end
			end	
		end},

		{negLog = function(prune, expr)
			local symmath = require 'symmath'
			-- -1*log(a) => log(1/a)
			if #expr == 2
			and expr[1] == symmath.Constant(-1)
			and symmath.log.is(expr[2])
			then
				return prune:apply(symmath.log(1/expr[2][1]))
			end	
		end},
	},

	Tidy = {
		{apply = function(tidy, expr)
			local unm = require 'symmath.op.unm'
			local Constant = require 'symmath.Constant'
			
			-- -x * y * z => -(x * y * z)
			-- -x * y * -z => x * y * z
			do
				local unmCount = 0
				for i=1,#expr do
					local ch = expr[i]
					if unm.is(ch) then
						unmCount = unmCount + 1
						expr[i] = ch[1]
					end
				end
				assert(#expr > 1)
				if unmCount % 2 == 1 then
					return -tidy:apply(expr)	-- move unm outside and simplify what's left
				elseif unmCount ~= 0 then
					return tidy:apply(expr)	-- got an even number?  remove it and simplify this
				end
			end
			
			-- (has to be solved post-prune() because tidy's Constant+unm will have made some new ones)
			-- 1 * x => x 	
			local first = expr[1]
			if Constant.is(first) and first.value == 1 then
				table.remove(expr, 1)
				if #expr == 1 then
					expr = expr[1]
				end
				return tidy:apply(expr)
			end
		end},
	},
}
-- ExpandPolynomial inherits from Expand
mul.rules.ExpandPolynomial = mul.rules.Expand

return mul
