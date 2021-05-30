--[[
formal mathematicaal definition of limit:

lim x→c+ f(x) = L <=> for all ε > 0 there exists δ > 0 s.t. ( 0 < x − c < δ) => |f(x) − L| < ε 
lim x→c- f(x) = L <=> for all ε > 0 there exists δ > 0 s.t. (-δ < x - c < 0) => |f(x) − L| < ε
--]]
local class = require 'ext.class'
local table = require 'ext.table'
local Expression = require 'symmath.Expression'
local symmath


local Side = class(Expression)
Side.name = 'Side'
Side.plus = setmetatable({name='+'}, Side)
Side.minus = setmetatable({name='-'}, Side)
Side.both = setmetatable({name=''}, Side)
function Side:new(name)
	if name == '+' or name == 'plus' then return self.plus end
	if name == '-' or name == 'minus' then return self.minus end
	if name == nil or name == 'both' then return self.both end
	error("unknown side")
end
function Side:clone() return self end
Side.__eq = rawequal


local Limit = class(Expression)

Limit.name = 'Limit'
Limit.nameForExporterTable = {}
Limit.nameForExporterTable.Language = 'limit'

-- higher than +, so wrap + with ()'s
--Limit.precedence = 2.5
-- higher than unm
Limit.precedence = 3.5

-- init: Limit(f(x),x,a, side): 
-- lim(x->a)(f(x)) = Limit(f(x), x, a, side)

function Limit:init(...)
	if select('#', ...) < 3 then
		error("expected Limit(f(x), x, a, [side])")
	end
	
	local f, x, a, side = ...
	
	assert(require 'symmath.Variable':isa(x))

	if not Side:isa(side) then side = Side(side) end

	Limit.super.init(self, f, x, a, side)
end

--[[
alright, here we get a reason to use a bubble-in phase.  (parent-first)
right now visitor only does bubble-out. (child-first)
and that means that the indeterminate expressions will be replaced with 'invalid' before the limit can reach them.
solutions.

otherwise we just get lim(1/x, x, 0) = lim(nan, x, 0) = nan

another fix: don't evaluate indeterminates outside of limits.
but that would just leave expressions sitting, rather than telling the user "hey this doesn't work"

so we do want simplfiications to go on ?right? 
but we definitely do not want indeterminate forms replaced.  maybe push only that rule? 
maybe just do everything for Limit in bubble-in?

how about the insides? what form should we use?
	lim x->0- (1/x^2) = ...
	... if you simplify the insides first, you get 'invalid' ... I need to push exactly that "invalid" generation rule.
	= lim x->0- (1/x)^2
	= (lim x->0- 1/x)^(lim x->0- 2)
	= (-inf)^2
	= inf
should I put this in pow -> div -> mul -> add format?
or should I just have an exceptional rule for p/q(x)^n => (p^(1/n)/q(x))^n
--]]
Limit.rulesBubbleIn = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local inf = symmath.inf
			local invalid = symmath.invalid
			
			-- limits ...
			-- put this in their own Expression member function?
			local f, x, a, side = table.unpack(expr)

			-- put any infs into prune() form, -inf => -1 * inf
			-- but what if 'a' is a limit too?
			-- what about lim x->(lim ...) f(x) ?
			a = a:prune()

--[[
local var = symmath.var
printbr(var'f':eq(f))
printbr(var'x':eq(x))
printbr(var'a':eq(a))
printbr(var'side':eq(side))
--]]

			-- TODO shouldn't prune() already be called on the children before the parent?
			--f = prune:apply(f)
			--f = symmath.simplify(f)
			-- yeah, well, this is a tough one, because tan(x) simplifies to sin(x)/cos(x)
			-- but x/x^2 simplifies to 1/x
			-- so how about i just keep the original for tan's sake
			local origf = f
			f = symmath.simplify(f)

-- [=[
			-- lim x->a f(x) = lim x->a+ f(x) = lim x->a- f(x) only when the + and - limit are equal
			if side == Side.both then
				local ll = Limit(f, x, a, '+')
				local left = prune:apply(ll)

				local lr = Limit(f, x, a, '-')
				local right = prune:apply(lr)
				if left == right then 
					return left 
				else
				-- if lim x->a+ ~= lim x->a- then lim x->a is unknown
					return invalid		-- return nil?
				end
			end
--]=]

			-- lim x->a x+ = lim x-> a- = a
			if f == x then
				return a
			end
		
			-- lim x->a c => c
			local Constant = symmath.Constant
			if Constant:isa(f) then 
				return f
			end

			-- is this always true for arbitrary variables?  
			local Variable = symmath.Variable
			if Variable:isa(f) then
				return f
			end

			-- lim add = add lim
			local add = symmath.op.add
			if add:isa(f) then
				return prune:apply(
					add(
						table.mapi(f, function(fi)
							return Limit(fi, x, a, side)
						end):unpack()
					)
				)
			end
		
			-- lim mul = mul lim
			local mul = symmath.op.mul
			if mul:isa(f) then
--print'evaluating a mul limit'
				local L = mul(
						table.mapi(f, function(fi)
							return Limit(fi, x, a, side)
						end):unpack()
					)
--print('lim applied to subexprs:')
--print(L)
				L = prune:apply(L)
--print'pruning lim'
--print(L)
				return L
			end	
		
			-- lim (f/g) = (lim f)/(lim g) so long as (lim g) ~= 0
			local div = symmath.op.div
			if div:isa(f) then
				local p, q = table.unpack(f)
				
				local lp = prune:apply(Limit(p, x, a, side))
				local lq = prune:apply(Limit(q, x, a, side))
				
--[=[
				if (
					Constant.isValue(lp, 0) 
--					or lp == inf 
--					or lus == Constant(-1) * inf
				) and (
					Constant.isValue(lq, 0) 
--					or lq == inf 
--					or lus == Constant(-1) * inf
				) then
					-- L'Hospital:
					p = p:diff(x)()
					q = q:diff(x)()
					return prune:apply(Limit((p/q):prune(), x, a, side))
				end
--]=]

				--[[
				how to determine when lim (x -> root) of p(q) / prod of (x - roots) is approaching from +inf or -inf
				seems you would want the limit in the form of pow -> div -> mul -> add/sub, 
				and then to compare the roots of the denominator with x->a, to see if we are approaching from the left or right.
				... and then looking at the sign of p(x) / prod of (x - all other roots) to see if we should be flipping the sign of the limit's +-inf
				--]]
				if Constant.isValue(lq, 0) then
					if not p:dependsOn(x) then
						
						-- lim x->root+- 1/x = +-inf
						if q == x then
							if side == Side.plus then
								return (p * inf):prune()
							else
								return (-p * inf):prune()
							end
						end
						
						-- lim x->root+- 1/x^n = +-inf
						local Wildcard = symmath.Wildcard
						-- x:match(x^Wildcard(1)) won't match x^Constant(1)
						local n = q:match(x^Wildcard{1, cannotDependOn=x})
						if n 
						and symmath.set.integer:contains(n)
						then

							if symmath.set.evenInteger:contains(n) then
								return (p * inf):prune()
							elseif symmath.set.oddInteger:contains(n) then
								if side == Side.plus then
									return (p * inf):prune()
								else
									return (-p * inf):prune()
								end
							else
								error'here'
							end
						end
					end
				end

				-- lim x->+-inf p(x) / q(x)
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
							local leadingCoeffRatio = (cp[dp] / cq[dq]):prune()
							if leadingCoeffRatio:lt(0):isTrue() then
								return Constant(-1) * inf 
							elseif leadingCoeffRatio:gt(0):isTrue() then
								return inf
							else
								error("how do I fix this?")
							end
						elseif dp == dq then
--printbr'using degree(p) == degree(q)...'							
							local leadingCoeffRatio = (cp[dp] / cq[dq]):prune()
							return leadingCoeffRatio 
						elseif dp < dq then
--printbr'using degree(p) < degree(q)...'							
							return Constant(0)
						end
					end
				end
			
				if not Constant.isValue(lq, 0) then
					return prune:apply(lp / lq)
				end
			end

			-- lim (p^q) = (lim p)^(lim q)
			local pow = symmath.op.pow
			if pow:isa(f) then
				local p, q = table.unpack(f)
				return prune:apply(Limit(p, x, a, side) ^ Limit(q, x, a, side))
			end


			-- functions whose limit is the same as their value
			-- abs
			-- exp
			-- atan
			-- tanh
			-- asinh
			-- cosh
			-- sinh
			-- cos
			-- sin
			if symmath.abs:isa(f) 
			--or symmath.exp:isa(f)	-- exp(x) is shorthand for pow(e, x)
			or symmath.atan:isa(f)
			or symmath.tanh:isa(f)
			or symmath.asinh:isa(f)
			or symmath.cosh:isa(f)
			or symmath.sinh:isa(f)
			or symmath.sin:isa(f) 
			or symmath.cos:isa(f)
			then
				return getmetatable(f)(
					Limit(f[1], x, a, side):prune()
				)
			end
			
			-- functions with asymptotes
			-- tan
			if symmath.tan:isa(origf) then
				local f = origf
				local L = Limit(f[1], x, a, side):prune()
				if L == symmath.pi/2 then
					if side == Side.plus then return Constant(-1) * inf end
					if side == Side.minus then return inf end
				end
				-- for that matter, if L == integer * pi / 2
				local n = (symmath.Wildcard(1) * symmath.pi) / 2
				if n and symmath.set.integer:contains(n) then
					if side == Side.plus then return Constant(-1) * inf end
					if side == Side.minus then return inf end
					error'here'
				end
				-- otherwise. ... can we assert L isn't going to be in the set of {n in Z, n pi / 2}?
				-- if we can assert that then return tan(L)
				--return symmath.tan(L)
				return getmetatable(f)(
					Limit(f[1], x, a, side):prune()
				)
			end

			-- functions that are only true on (0, inf) 
			-- log
			-- sqrt ... sqrt is going to be under pow()... and TODO I don't think I've added these edge cases
			-- cbrt ... same with cbrt
			if symmath.log:isa(f)
			then
				local L = Limit(f[1], x, a, side):prune()
				if symmath.set.positiveReal:contains(L) then
					return getmetatable(f)(L)
				end
				if symmath.set.negativeReal:contains(L) then
					return invalid
				end
				if Constant.isValue(L, 0) then
					if side == Side.plus then
						return Constant(-1) * inf
					end
					return invalid
				end
				return getmetatable(f)(
					Limit(f[1], x, a, side):prune()
				)
			end

			-- functions only true on (1, inf)
			-- acosh
			if symmath.acosh:isa(f)
			then
				local L = Limit(f[1], x, a, side):prune()
				if symmath.set.RealSubset(1, math.huge, false, false):contains(L) then
					return getmetatable(f)(L)
				end
				if symmath.set.RealSubset(-math.huge, 1, false, false):contains(L) then
					return invalid
				end
				if Constant.isValue(L, 1) then
					if side == Side.plus then
						return Constant(0)
					end
					return invalid
				end
				-- TODO this?
				return getmetatable(f)(
					Limit(f[1], x, a, side):prune()
				)
			end
			
			-- functions that are only true on (-1, 1)
			-- asin
			-- acos
			-- atanh
			if symmath.atanh:isa(f) 
			or symmath.asin:isa(f)
			or symmath.acos:isa(f)
			then
				local L = Limit(f[1], x, a, side):prune()
				if symmath.set.RealSubset(-1, 1, false, false):contains(L) then
					return getmetatable(f)(L)
				end
				-- TODO use this elsewhere.  it's preferrable to Constant.isValue(L, -1), right?
				-- then again, the only difference is that RealSubset(-1,-1,true,true):contains(L) will also pick up variables defined to exist only on the set {-1} ...
				-- so it's basically the same as Constant.isValue(L, -1)
				--if symmath.set.RealSubset(-1, -1, true, true):contains(L) then
				if Constant.isValue(L, -1) and side == Side.plus then 
					if symmath.acos:isa(f) then
						return inf
					else
						return Constant(-1) * inf 
					end
				end
				if Constant.isValue(L, 1) and side == Side.minus then 
					if symmath.acos:isa(f) then
						return Constant(-1) * inf
					else
						return inf 
					end
				end
			
				if symmath.set.RealSubset{
					{-math.huge, -1, false, false},
					{1, math.huge, false, false}
				}:contains(L) then
					return invalid
				end
			
				-- otherwise ... ?
				return getmetatable(f)(
					Limit(f[1], x, a, side):prune()
				)
			end
		
		
			-- multivariate functions
			-- atan2
			
			-- Heaviside
			if symmath.Heaviside:isa(f) then
				local L = Limit(f[1], x, a, side):prune()
				if Constant.isValue(L, 0) then
					if side == Side.plus then return Constant(1) end
					if side == Side.minus then return Constant(0) end
					if side == Side.both then return invalid end
					error'here'
				end
				if L:lt(0):isTrue() then return Constant(0) end
				if L:gt(0):isTrue() then return Constant(1) end
				-- here: lim x->a H(x) when a>0 is undetermined
			end


			--[[
			but this ends up returning 'invalid' ... why is that?
			especially when the only thing in Limit's rules that returns 'invalid' is when left limit and right limit don't agree
			ahh that's exactly it ... 
			if you just request any f(x):lim(x,a) then it will test the + limit and the - limit
			and if they aren't caught and replaced in this function then what comes back is
			Limit(f(x), x, a, '+') == Limit(f(x), x, a, '-')
			and that will always be 'false' because the sides differ
			technically the comparator should not say 'false' all the time.
			technically I shouldn't use == but Equality and :isTrue()
			and in taht case, return no definite answer for comparing unresolved limits ...
			--]]
		end},
	},
}

Limit.rules = {
	Prune = {
		{apply = function(prune, expr)
		end},
	}
}

return Limit
