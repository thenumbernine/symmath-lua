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

-- expose the internal class
Limit.Side = Side

-- init: Limit(f(x),x,a, side): 
-- lim(x->a)(f(x)) = Limit(f(x), x, a, side)

function Limit:init(...)
	if select('#', ...) < 3 then
		error("expected Limit(f(x), x, a, [side])")
	end
	
	local f, x, a, side = ...
	
	symmath = symmath or require 'symmath.namespace'()
	assert(symmath.Variable:isa(x))

	if not Side:isa(side) then side = Side(side) end

	Limit.super.init(self, f, x, a, side)
end

-- here's some commonly used functions by a class' evaluateLimit()
-- all static functions:

function Limit.evaluateLimit_ifInDomain(f, L)
	symmath = symmath or require 'symmath'
	
	local domain = f:getRealDomain()
	if domain:contains(L) then
		return getmetatable(f)(L)
	end
	
	-- is it enough that the complement contains L?
	-- or should we be safe?  only the open complement?
	if domain:complement():open():contains(L) then
		return symmath.invalid
	end
	
	-- SFINAE: if we cannot determine whether f(x) is inside or outside the function domain then don't touch the limit
end

function Limit.evaluateLimit_continuousFunction(f, x, a, side)
	symmath = symmath or require 'symmath'
	local L = symmath.prune(Limit(f[1], x, a, side))
	return Limit.evaluateLimit_ifInDomain(f, L)
end

-- functions that are continuous and increasing/decreasing on (-1, 1) -> (-inf, inf)
function Limit.evaluateLimit_plusMinusOne_to_plusMinusInf(f, x, a, side, decreasing)
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	local inf = symmath.inf

	local L = symmath.prune(Limit(f[1], x, a, side))
	
	-- TODO use this elsewhere.  it's preferrable to Constant.isValue(L, -1), right?
	-- then again, the only difference is that RealSubset(-1,-1,true,true):contains(L) will also pick up variables defined to exist only on the set {-1} ...
	-- so it's basically the same as Constant.isValue(L, -1)
	--if symmath.set.RealSubset(-1, -1, true, true):contains(L) then
	if Constant.isValue(L, -1) and side == Side.plus then 
		if decreasing then
			return inf
		else
			return Constant(-1) * inf
		end
	end
	if Constant.isValue(L, 1) and side == Side.minus then 
		if decreasing then
			return Constant(-1) * inf
		else
			return inf 
		end
	end

	-- this will handle returning the value for L in (-1, 1)
	-- or returning invalid for L in (-inf, -1) or (1, inf)
	-- so long as the function's getRealDomain is set to (-1, 1)
	return Limit.evaluateLimit_ifInDomain(f, L)
end

function Limit.evaluateLimit_plusMinusOne_to_minusPlusInf(f, x, a, side)
	return Limit.evaluateLimit_plusMinusOne_to_plusMinusInf(f, x, a, side, true)
end

--[[
TODO turn this into member methods

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
Limit.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local inf = symmath.inf
			
			-- limits ...
			-- put this in their own Expression member function?
			local f, x, a, side = table.unpack(expr)

			-- put any infs into prune() form, -inf => -1 * inf
			-- but what if 'a' is a limit too?
			-- what about lim x->(lim ...) f(x) ?
			--a = prune:apply(a)
			-- or just do this rule on the bubble-out


			-- TODO shouldn't prune() already be called on the children before the parent?
			--f = prune:apply(f)
			--f = symmath.simplify(f)
			-- yeah, well, this is a tough one, because tan(x) simplifies to sin(x)/cos(x)
			-- but x/x^2 simplifies to 1/x
			-- so how about i just keep the original for tan's sake
			--local origf = f
			-- instead I'll just look for tan()'s replacement: sin()/cos()
			-- but if I'm pruning f and a in advance ...
			-- ... maybe this whole rule isn't a bubble-in rule after all?
			--f = prune:apply(f)
			-- or just do this rule on the bubble-out

			-- lim x->a f(x) = lim x->a+ f(x) = lim x->a- f(x) only when the + and - limit are equal
			if side == Side.both then
				local ll = Limit(f, x, a, '+')
				local lr = Limit(f, x, a, '-')

				local pl = prune:apply(ll)
				local pr = prune:apply(lr)
				
				if pl == pr then 
					return pl 
				else
					-- if lim x->a+ ~= lim x->a- then lim x->a is unknown
					-- so SFINAE: don't touch the result
					--return nil
					-- but that causes the assumption that certain only-one-sided-limit's two-sided-limit is indeterminate to fail
					-- so return indeterminate?
					--return symmath.invalid
					-- but this causes the default unknown return of Limit, to return itself as is, 
					--  to cause this to compare lim x->a+ to lim x->a- , and see the two are separate expressions, and return 'invalid'
					-- so which is it?
				
					-- how about both?
					-- if the left and right limits are untouched (i.e. equal to the original expression before pruning)
					-- then return the original both-sides limit
					-- otherwise return invalid.
					if pl == ll and pr == lr then
						return
					else
						return symmath.invalid
					end
				end
			end

			if f.evaluateLimit then
				return f:evaluateLimit(x, a, side)
			end

			-- if we haven't figured it out then don't touch the result
		end},
	},
}

return Limit
