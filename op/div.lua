local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local math = require 'ext.math'
local Binary = require 'symmath.op.Binary'

local symmath

local div = class(Binary)
div.precedence = 3.5
div.name = '/'

function div:evaluateDerivative(deriv, ...)
	local a, b = self[1], self[2]
	a, b = a:cloneIfMutable(), b:cloneIfMutable()
	return (deriv(a, ...) * b - a * deriv(b, ...)) / (b * b)
end

function div:reverse(soln, index)
	local p,q = table.unpack(self)
	-- y = p(x) / q => p(x) = q * y
	if index == 1 then
		soln = soln * q:cloneIfMutable()
	-- y = p / q(x) => q(x) = p / y
	elseif index == 2 then
		soln = p:cloneIfMutable() / soln
	end
	return soln
end

function div:getRealRange()
	if self.cachedSet then return self.cachedSet end
	local I = self[1]:getRealRange()
	if I == nil then 
		self.cachedSet = nil
		return nil 
	end
	local I2 = self[2]:getRealRange()
	if I2 == nil then 
		self.cachedSet = nil
		return nil 
	end
	self.cachedSet = I / I2
	return self.cachedSet
end

-- lim (f/g) = (lim f)/(lim g) so long as (lim g) ~= 0
function div:evaluateLimit(x, a, side)
	symmath = symmath or require 'symmath'
	local prune = symmath.prune
	local Limit = symmath.Limit
	local Side = Limit.Side
	local Constant = symmath.Constant
	local inf = symmath.inf

	local p, q = table.unpack(self)
	
	local Lp = prune(Limit(p, x, a, side))
	local Lq = prune(Limit(q, x, a, side))

-- [=[ L'Hospital:
	if (	-- 0 / 0
		Constant.isValue(Lp, 0) and Constant.isValue(Lq, 0)
	) or (	-- |inf| / |inf|
		(Lp == inf or Lp == Constant(-1) * inf)
		and (Lq == inf or Lq == Constant(-1) * inf)
	) then
		p = p:diff(x)()
		q = q:diff(x)()
		return prune(
			Limit(
				prune(p / q), 
				x, a, side
			)
		)
	end
--]=]

	--[[
	how to determine when lim (x -> root) of p(q) / prod of (x - roots) is approaching from +inf or -inf
	seems you would want the limit in the form of pow -> div -> mul -> add/sub, 
	and then to compare the roots of the denominator with x->a, to see if we are approaching from the left or right.
	... and then looking at the sign of p(x) / prod of (x - all other roots) to see if we should be flipping the sign of the limit's ±inf
	--]]
	if Constant.isValue(Lq, 0) then
		if not p:dependsOn(x) then
			
			-- lim x->root± 1/x = ±inf
			if q == x then
				if side == Side.plus then
					return prune(p * inf)
				else
					return prune(-p * inf)
				end
			end
			
			-- lim x->root± 1/x^n = ±inf
			local Wildcard = symmath.Wildcard
			-- x:match(x^Wildcard(1)) won't match x^Constant(1)
			local n = q:match(x^Wildcard{1, cannotDependOn=x})
			if n 
			and symmath.set.integer:contains(n)
			then

				if symmath.set.evenInteger:contains(n) then
					return prune(p * inf)
				elseif symmath.set.oddInteger:contains(n) then	-- TODO just else, so long as inf is alreayd excluded
					if side == Side.plus then
						return prune(p * inf)
					else
						return prune(-p * inf)
					end
				else
					error'here'
				end
			end
		end
	end

	-- lim x->±inf p(x) / q(x)
	if a == inf
	or a == Constant(-1) * inf
	then
		local cp = p:polyCoeffs(x)
		local cq = q:polyCoeffs(x)
		
		-- if we got two polynomials ...
		if cp.extra == nil
		and cq.extra == nil
		then
			local dp = table.maxn(cp)
			local dq = table.maxn(cq)
--printbr('p: ', p)
--printbr('q: ', q)
--printbr('keys of coeffs of p: ', table.keys(cp):concat', ')
--printbr('keys of coeffs of q: ', table.keys(cq):concat', ')
--printbr('degrees if p(x)/q(x): ', dp, dq)
--printbr('leading coeff of p:', cp[dp])
--printbr('leading coeff of q:', cq[dq])
			if dp > dq then
--printbr'using degree(p) > degree(q)...'							
				local leadingCoeffRatio = prune(cp[dp] / cq[dq])
				if leadingCoeffRatio:lt(0):isTrue() then
					return Constant(-1) * inf 
				elseif leadingCoeffRatio:gt(0):isTrue() then
					return inf
				else
					error("how do I fix this?")
				end
			elseif dp == dq then
--printbr'using degree(p) == degree(q)...'							
				local leadingCoeffRatio = prune(cp[dp] / cq[dq])
				return leadingCoeffRatio 
			elseif dp < dq then
--printbr'using degree(p) < degree(q)...'							
				return Constant(0)
			end
		end
	end

	-- handle cos(x)/sin(x) == tan(x) here
	-- TODO this is here only because tan() prune()'s into sin()/cos()
	-- if instead we keep tan() as-is then move this into tan:evaluateLimit()
	if symmath.sin:isa(p)
	and symmath.cos:isa(q)
	then
		if p[1] == q[1] then
			local th = p[1]
			local L = prune(Limit(th, x, a, side))
			if L == symmath.pi/2 then
				if side == Side.plus then return Constant(-1) * inf end
				if side == Side.minus then return inf end
			end
			-- for that matter, if L == integer * pi / 2
			local n = (symmath.Wildcard(1) * symmath.pi) / 2
			if n and symmath.set.integer:contains(n) then
				if side == Side.plus then return Constant(-1) * inf end
				if side == Side.minus then return inf end
				error'got an invalid Limit side'
			end
			-- TODO only for L contained within the domain of H
			-- i.e. only for L's set NOT INTERSECTING {(2n+1)/pi} for n in Z
			return symmath.tan(L)
		end
	end


	-- TODO only for Lq's set NOT INTERSECTING {0}
	if not Constant.isValue(Lq, 0) then
		return prune(Lp / Lq)
	end
end

div.rules = {
	DistributeDivision = {
		{apply = function(distributeDivision, expr)
			symmath = symmath or require 'symmath'
			local add = symmath.op.add
			local num, denom = expr[1], expr[2]
			if not add:isa(num) then return end
			return getmetatable(num)(range(#num):map(function(k)
				return (num[k] / denom):simplify()
			end):unpack())
		end},
	},

	Factor = {
--[[
-- hmm ... raise everything to the lowest power? 
-- if there are any sqrts, square everything?
-- but what i was trying to fix was actually just a c^(-1/2)
-- TODO this produces incorrect results for negatives
		{apply = function(factor, expr)
			symmath = symmath or require 'symmath'
			local sqrt = symmath.sqrt
			local pow = symmath.op.pow
			local div = symmath.op.div
			local Constant = symmath.Constant
			for x in expr[2]:itermul() do
				if pow:isa(x)
				and div:isa(x[2])
				and Constant.isValue(x[2][1], 1)
				and Constant.isValue(x[2][2], 2)
				then
					return sqrt(
						(expr[1]^2):prune() / 
						(expr[2]^2):prune()
					)
				end
			end
		end},
--]]
	
-- [[ trying for polynomial division using polydiv
-- I'm not sure if I should put this in Factor or Prune 
-- if it's in Prune then just return the polydivr results
-- if it's in Factor then maybe I should recursively build roots and return the product of (x - roots)
-- ... and then let the next Prune() call divide them out
		{polydiv = function(factor, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			
			-- now when polydiv encounters a non-poly situation, it calls simplify()
			-- so ... don't use polydiv ... use its internal
			local polydivr = symmath.polydiv.polydivr
		
			
			local function candivide(p, q)
				-- for expr == p / q
				-- if p and q are polynomials of some var (with no 'extra')
				-- then try to divide p from q and see if no remainer exists
				-- and then try to divide q from p

				local vars = expr:getDependentVars()
				for _,x in ipairs(vars) do
					
					local c, r = polydivr(p, q, x)
					if Constant.isValue(r, 0) then
	--printbr('1. dividing', p, 'by', q, 'wrt x', x, 'and getting', c,' remainder', r)					
						-- with simplification
						-- return c
						-- without
						return c * q, q
					end
				
					local c, r = polydivr(q, p, x)
					if Constant.isValue(r, 0) then
	--printbr('2. dividing', q, 'by', p, 'wrt x', x, 'and getting', c,' remainder', r)					
						-- with simplification
						--return 1/c
						-- without
						return p, c * p
					end
				end
			end
		
--[=[ TODO HAS BUGS DON'T USE THIS
			local mp, mq = table.unpack(expr)

			-- if p or q is mul -> add then ...
			-- polydiv needs add -> mul
			-- but don't rearrange so fast!
			-- instead cycle through mul's terms and check them individually
			--  and pick them apart
			--  maybe remove them too?
			
			local srcp = table(symmath.op.mul:isa(mp) and mp or {mp})
			local srcq = table(symmath.op.mul:isa(mq) and mq or {mq})

			local dstp = table()
			local dstq = table()

			-- now go through the pairs of srcq/srcq and, if they do divide, put their results into dstp/dstq
			-- if they don't then skip them, and pile them on in the end
			-- mind you this will approach terms on a first-come, first-serve basis
			-- should i repeat until we get no more results?

			local found
			repeat
				found = nil
				for i,p in ipairs(srcp) do
					for j,q in ipairs(srcq) do
					
						local newp, newq = candivide(p, q)
						if newp then
							assert(newq)

							dstp:insert(newp)
							dstq:insert(newq)
							srcp:remove(i)
							srcq:remove(j)
							found = true
							break
						end
					end
					if found then break end
				end
			until not found

			dstp:append(srcp)	-- append what's left
			dstq:append(srcq)

			return (#dstp == 1 and dstp[1] or symmath.op.mul(dstp:unpack()))
					/ (#dstq == 1 and dstq[1] or symmath.op.mul(dstq:unpack()))
--]=]			
-- [=[ or just try the num/denom as-is
			local np, nq = candivide(expr[1], expr[2])
			if np then
				return np / nq
			end
--]=]
		end},
--]]
	
--[[ trying for polynomial division using polydiv
-- I'm not sure if I should put this in Factor or Prune 
-- if it's in Prune then just return the polydivr results
-- if it's in Factor then maybe I should recursively build roots and return the product of (x - roots)
-- ... and then let the next Prune() call divide them out
-- don't enable this in Prune and Factor
-- 
-- ... however *WARNING* here in Prune it gets stuck somewhere.
-- but if my modification of the above fails then copy this back into Factor		
		{polydiv = function(factor, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			
			local p, q = table.unpack(expr)
			
			-- for expr == p / q
			-- if p and q are polynomials of some var (with no 'extra')
			-- then try to divide p from q and see if no remainer exists
			-- and then try to divide q from p

			-- now when polydiv encounters a non-poly situation, it calls simplify()
			-- so ... don't use polydiv ... use its internal
			local polydivr = symmath.polydiv.polydivr
		
			local vars = expr:getDependentVars()
			for _,x in ipairs(vars) do
				
				local c, r = polydivr(p, q, x)
				if Constant.isValue(r, 0) then
					return c
				end
			
				local c, r = polydivr(q, p, x)
				if Constant.isValue(r, 0) then
					return 1/c
				end
			end
			
		end},
--]]


	},

	FactorDivision = {
		{apply = function(factorDivision, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local mul = symmath.op.mul

			if Constant.isValue(expr[1], 1) then return end
		
			-- a/(b1 * ... * bn) => a * 1/b1 * ... * 1/bn
			if mul:isa(expr[2]) then
				local prod = mul(expr[1], range(#expr[2]):mapi(function(i)
					return 1 / expr[2][i]:clone()
				end):unpack())
				return factorDivision:apply(prod)
			end

			-- a/b => a * 1/b
			return factorDivision:apply(expr[1] * (Constant(1)/expr[2]))
		end},
	},

	Prune = {		
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local add = symmath.op.add
			local mul = symmath.op.mul
			local div = symmath.op.div
			local pow = symmath.op.pow
			local Array = symmath.Array
			local Constant = symmath.Constant

			-- matrix/scalar
			do
				local a, b = table.unpack(expr)
				if Array:isa(a) and not Array:isa(b) then
					local result = a:clone()
					for i=1,#result do
						result[i] = result[i] / b
					end
					return prune:apply(result)
				end
			end

			if expr[1] == symmath.invalid
			or expr[2] == symmath.invalid
			then
				return symmath.invalid
			end

			-- p/inf is 0 for p != inf
			if expr[2] == symmath.inf 
			or expr[2] == Constant(-1) * symmath.inf 
			then
				if expr[1] ~= symmath.inf 
				and expr[1] ~= Constant(-1) * symmath.inf
				then
					return Constant(0)
				end
				return symmath.invalid
			end

			-- x / 0 => invalid
			if Constant.isValue(expr[2], 0) then
				return symmath.invalid
			end

			if expr[1] == symmath.inf then
				-- inf / negative = -inf
				if symmath.set.negativeReal:contains(expr[2]) then
					return -inf
				end
				-- inf / 0 = invalid
				return symmath.inf
			end

			if symmath.simplifyConstantPowers  then
				-- Constant / Constant => Constant
				if Constant:isa(expr[1]) and Constant:isa(expr[2]) then
					return Constant(expr[1].value / expr[2].value)
				end

				-- q / Constant = 1/Constant * q
				if Constant:isa(expr[2]) then
					return prune:apply(
						Constant(1/expr[2].value) * expr[1]
					)
				end
		
				-- (c1 * m) / c2 => (c1 / c2) * m
				if mul:isa(expr[1]) and Constant:isa(expr[1][1]) and Constant:isa(expr[2]) then
					local rest = #expr[1] == 2 and expr[1][2] or mul(table.unpack(expr[1], 2))
					return Constant(expr[1][1].value / expr[2].value) * rest
				end
			
				-- c1 / (c2 * m) => (c1/c2) / m
				if Constant:isa(expr[1]) and mul:isa(expr[2]) and Constant:isa(expr[2][1]) then
					local rest = #expr[2] == 2 and expr[2][2] or mul(table.unpack(expr[2], 2))
					return Constant(expr[1].value / expr[2][1].value) / rest
				end
		
				-- (c1 * m1) / (c2 * m2) => ((c1/c2) * m1) / m2
				if mul:isa(expr[1]) and Constant:isa(expr[1][1])
				and mul:isa(expr[2]) and Constant:isa(expr[2][1])
				then
					local rest1 = #expr[1] == 2 and expr[1][2] or mul(table.unpack(expr[1], 2))
					local rest2 = #expr[2] == 2 and expr[2][2] or mul(table.unpack(expr[2], 2))
					return (Constant(expr[1][1].value / expr[2][1].value) * rest1) / rest2
				end
			end

			-- x / 1 => x
			if Constant.isValue(expr[2], 1) then
				return expr[1]
			end

			-- x / -1 => -1 * x
			if Constant:isa(expr[2]) and expr[2].value < 0 then
				return prune:apply(Constant(-1) * expr[1] / Constant(-expr[2].value))
			end
			
			-- 0 / x => 0
			if Constant.isValue(expr[1], 0) then
				if expr[1].value == 0 then
					return Constant(0)
				end
			end
			
			-- (a / b) / c => a / (b * c)
			if div:isa(expr[1]) then
				return prune:apply(expr[1][1] / (expr[1][2] * expr[2]))
			end
			
			-- a / (b / c) => (a * c) / b
			if div:isa(expr[2]) then
				local a, b = table.unpack(expr)
				local b, c = table.unpack(b)
				return prune:apply((a * c) / b)
			end

			if expr[1] == expr[2] then
				return Constant(1)		-- ... for expr[1] != 0
			end

			-- [[ 
			-- conjugates of square-roots in denominator
			-- a / (b + sqrt(c)) => a (b - sqrt(c)) / ((b + sqrt(c)) (b - sqrt(c))) => a (b - sqrt(c)) / (b^2 - c)
			--[=[ the (b + sqrt(c)) matches the remaining Wildcard 
			local a,b,c,d = expr:match(Wildcard(1) / ((Wildcard(2) + Wildcard(3) ^ div(1,2)) * Wildcard(4)))
			if a then
				print('a\n'..a..'\nb\n'..b..'\nc\n'..c..'\nd\n'..d)
				error'here'
			end
			--]=]
			local Wildcard = symmath.Wildcard
			local mul = symmath.op.mul
			local num, denom = table.unpack(expr)
			if mul:isa(denom) then
				for i=1,#denom do
					if add:isa(denom[i]) then
						local a, b, c = denom[i]:match(Wildcard(1) + Wildcard(2) * Wildcard(3) ^ div(1,2)) 
						if a then
							denom = denom:clone()
							table.remove(denom, i)
							table.insert(denom, (a^2 - b^2 * c))
							return prune:apply((expr[1] * (a - b * c ^ div(1,2))) / denom)
						end
					end
				end
			end
			--]]


			local num, denom = table.unpack(expr)
			
			-- [[ maybe this should replace the rule above?
			-- if any sqrt()s are found within any adds or muls on the top then multiply them on the bottom and top
			-- hmm this leaves sqrt(5)/(2*sqrt(3)) in a bad state ...
			local pow = symmath.op.pow
			for x in num:iteradd() do
				for y in x:itermul() do
					if pow:isa(y)
					and symmath.set.negativeReal:contains(y[2])
					then
						local fix = y[1] ^ -y[2]
						num = num * fix
						denom = denom * fix
						return prune:apply(num) / prune:apply(denom)
						-- this causes stack overflows
						--return prune:apply(num / denom)
					end
				end
			end
			--]]

			--[[ put negative powers on the opposite side of the div
			-- div -> mul -> pow -> unm => switch side of div and negative pow
			local pow = symmath.op.pow
			for k=1,2 do
				local from = expr[k]
				local to = expr[3-k]
				for x in from:iteradd() do
					for y in x:itermul() do
						if pow:isa(y)
						and symmath.set.negativeReal:contains(y[2]) 
						then
							num = prune:apply(num * y[1] ^ -y[2])
							denom = prune:apply(denom * y[1] ^ -y[2])
							--return prune:apply(num / denom)
							return num / denom
						end
					end
				end
			end
			--]]

			-- [[ any sqrt()s on the bottom, multiply by bottom and top
			-- TODO conjugate pairs?
			local function toProdList(x)
				symmath = symmath or require 'symmath'
				local mul = symmath.op.mul
				local Constant = symmath.Constant
				if mul:isa(x) then return table(x) end
				if Constant.isValue(x, 1) then return table() end
				return table{x}
			end

			local function fromProdList(x)
				symmath = symmath or require 'symmath'
				local mul = symmath.op.mul
				local Constant = symmath.Constant
				if #x == 0 then return Constant(1) end
				if #x == 1 then return x[1] end
				return mul(x:unpack())
			end

			local numlist = toProdList(num)
			local denomlist = toProdList(denom)
			local modified
			if #denomlist > 1 then
				for i=1,#denomlist do
					if pow:isa(denomlist[i])
					and div:isa(denomlist[i][2])
					-- TODO any fraction, esp odd fractions
					and Constant.isValue(denomlist[i][2][1], 1)
					and Constant.isValue(denomlist[i][2][2], 2)
					then
						modified = true
						numlist:insert(denomlist[i])
						denomlist[i] = denomlist[i][1]
					end
				end
			end
			if modified then
				return prune:apply(fromProdList(numlist) / fromProdList(denomlist))
			end
			--]]

			-- [[ a / (-c * b) => -a / (c * b)
			local num, denom = table.unpack(expr)
			if mul:isa(denom) then
				for i=1,#denom do
					if Constant:isa(denom[i])
					and denom[i].value < 0
					then
						denom = denom:clone()
						denom[i] = Constant(-denom[i].value)
						return prune:apply(-num / denom)
					end
				end
			end
			--]]

			-- (r^m * a * b * ...) / (r^n * x * y * ...) => (r^(m-n) * a * b * ...) / (x * y * ...)
			-- TODO combine this with the stuff in add.Factor somehow
			-- that builds lists of term=, power= as well
			do
				local modified
				local nums, denoms
				if mul:isa(expr[1]) then
					nums = table(expr[1])
				else
					nums = table{expr[1]}
				end
				if mul:isa(expr[2]) then
					denoms = table(expr[2])
				else
					denoms = table{expr[2]}
				end
			
				local function listToBasesAndPowers(list)
					local bases = table()
					local powers = table()
					for i=1,#list do
						local x = list[i]
						local base, power
						if pow:isa(x) then
							base, power = table.unpack(x)
						else
							base, power = x, Constant(1)
						end
						bases[i] = assert(base)
						powers[i] = assert(power)
					end
					return bases, powers
				end
				
				local numBases, numPowers = listToBasesAndPowers(nums)
				local denomBases, denomPowers = listToBasesAndPowers(denoms)
			
				-- split any constant integers into its prime factorization
				for _,info in ipairs{
					{numBases, numPowers},
					{denomBases, denomPowers}
				} do
					local bases, powers = table.unpack(info)
					for i=#bases,1,-1 do
						local b = bases[i]
						if symmath.set.integer:contains(b) 
						and b.value ~= 0 
						then
							bases:remove(i)
							local value = b.value
							local power = powers:remove(i)
							if value < 0 then	-- insert -1 if necessary
								bases:insert(i, Constant(-1))
								powers:insert(i, power:clone())
								value = -value
							end
							if value == 1 then
								bases:insert(i, Constant(1))
								powers:insert(i, power:clone())
							else
								local fs = math.primeFactorization(value)	-- 1 returns a nil list
								for _,f in ipairs(fs) do
									bases:insert(i, f)
									powers:insert(i, power:clone())
								end
							end
						end
					end
				end

				-- TODO move minus sign to the top
				-- TODO if the coefficients are non-integers then just divide them

				-- from this point on, nums and denoms don't match up with numBases (specifically because of the prime factorization of integers)
				-- so don't worry about and don't use nums and denoms

				for i=1,#numBases do
					for j=#denomBases,1,-1 do
						if not Constant.isValue(numBases[i], 1)
						and numBases[i] == denomBases[j] 
						then
							modified = true
							local resultPower = numPowers[i] - denomPowers[j]
							numPowers[i] = resultPower
							denomBases:remove(j)
							denomPowers:remove(j)
						end
					end
				end
				
				if modified then
					if #numBases == 0 and #denomBases == 0 then return Constant(1) end

					-- can I construct these even if they have no terms?
					local num
					if #numBases > 0 then
						num = numBases:map(function(v,i) 
							return v ^ numPowers[i]
						end)
						assert(#num > 0)
						if #num == 1 then
							num = num[1]
						else
							num = mul(num:unpack())
						end
					end
					local denom
					if #denomBases > 0 then
						denom = denomBases:map(function(v,i) 
							return v ^ denomPowers[i]
						end)
						assert(#denom > 0)
						if #denom == 1 then
							denom = denom[1]
						else
							denom = mul(denom:unpack())
						end
					end
					
					local result
					if #numBases == 0 then
						result = Constant(1) / denom
					elseif #denomBases == 0 then
						result = num
					else
						result = num / denom
					end

					return prune:apply(result)
				end
			end

			--[[ a / b^(p/q) => (a / b^(p/q)) * (b^((q-p)/q) / b^((q-p)/q)) => (a * b^((q-p)/q)) / b
			local Wildcard = symmath.Wildcard
			local a, b, p, q = expr:match(Wildcard(1) / Wildcard(2) ^ (Wildcard(3) / Wildcard(4)))
			if a then
				if Constant.isValue(a, 1) then
					return prune:apply(b ^ ((q - p) / q) / b)
				else
					return prune:apply(a * b ^ ((q - p) / q) / b)
				end
			end
			--]]

			--[[ (a + b) / c => a/c + b/c ...
			local add = require 'symmath.op.add'
			if add:isa(expr[1]) then
				return prune:apply(add(
					table.mapi(expr[1], function(x)
						return x / expr[2]
					end):unpack()))
			end
			--]]

			-- this would be helpful if it wasn't evaluated after children, where exponent polys get distributed
			-- do I need a bubble-in/bubble-out callback?
			-- I just got this to call first by calling the *same* callback before and after child recursion
			-- that might be a bad idea, but it solves this problem.
			-- but that screws up things elsewhere ...
			--[[
			-- x / x^a => x^(1-a)
			if pow:isa(expr[2]) and expr[1] == expr[2][1] then
				return prune:apply(expr[1]:clone() ^ (1 - expr[2][2]:clone()))
			end
			
			-- x^a / x => x^(a-1)
			if pow:isa(expr[1]) and expr[1][1] == expr[2] then
				return prune:apply(expr[1][1]:clone() ^ (expr[1][2]:clone() - 1))
			end
			
			-- x^a / x^b => x^(a-b)
			if pow:isa(expr[1])
			and pow:isa(expr[2])
			and expr[1][1] == expr[2][1]
			then
				return prune:apply(expr[1][1]:clone() ^ (expr[1][2]:clone() - expr[2][2]:clone()))
			end
			--]]
		
			--[[ TODO attempt polynomial division?  or put that in :factor()?
			if add:isa(expr[1]) then
				local a,b = expr[1], expr[2]
				local q = Constant(0)
				local r = a
			end
			--]]
		
			--[[ cheat
			-- now that cos.rules.Prune has simplified all the cos^2's into sin^2's
			-- if there's a div that needs to be simplified, there could be some extra terms not simplified
			-- (1 - sin(theta)^2) / cos(theta) = cos(theta)^2 / cos(theta) = cos(theta)
			do
				local sin = require 'symmath.sin'
				local cos = require 'symmath.cos'
				if cos:isa(expr[2]) then
					local inside = expr[2][1]
					if expr[1]() == (1 - sin(inside)^2)() then
						return cos(inside)
					end
				end
			end
			--]]
		end},	

		-- this could go after the apply rule, but that ends with a subsequent prune(a)/prune(b) ..
		{logPow = function(prune, expr)
			symmath = symmath or require 'symmath'
			-- log(a) / b => log(a^(1/b))
			if symmath.log:isa(expr[1]) then
				local a = expr[1][1]
				local b = expr[2]
				return prune:apply(symmath.log(a ^ (1 / b)))
			end
		end},
	},

	Tidy = {
		{apply = function(tidy, expr)
			symmath = symmath or require 'symmath'
			local unm = symmath.op.unm
			local Constant = symmath.Constant
			
			local a, b = table.unpack(expr)
			local ua = unm:isa(a)
			local ub = unm:isa(b)
			
			if ua and ub then return tidy:apply(a[1] / b[1]) end
			
			if ua 
			--and Constant:isa(a[1]) 
			then 
				return tidy:apply(-(a[1] / b)) 
			end
			
			if ub 
			--and Constant:isa(b[1]) 
			then 
				return tidy:apply(-(a / b[1])) 
			end
		end},
	},
}

return div
