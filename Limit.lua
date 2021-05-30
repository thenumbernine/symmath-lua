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
--]]
Limit.rulesBubbleIn = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			
			-- limits ...
			-- put this in their own Expression member function?
			local f, x, a, side = table.unpack(expr)

--[[
local var = symmath.var
printbr(var'f':eq(f))
printbr(var'x':eq(x))
printbr(var'a':eq(a))
printbr(var'side':eq(side))
--]]

			-- TODO shouldn't prune() already be called on the children before the parent?
			--f = prune:apply(f)
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
					return symmath.invalid		-- return nil?
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
				return prune:apply(
					mul(
						table.mapi(f, function(fi)
							return Limit(fi, x, a, side)
						end):unpack()
					)
				)
			end	
		
			-- lim (f/g) = (lim f)/(lim g) so long as (lim g) ~= 0
			local div = symmath.op.div
			local inf = symmath.inf
			if div:isa(f) then
				local p, q = table.unpack(f)
				

				local lp = prune:apply(Limit(p, x, a, side))
				local lq = prune:apply(Limit(q, x, a, side))
				

-- [=[
				if (Constant.isValue(lp, 0) or lp == inf or lus == Constant(-1) * inf)
				and (Constant.isValue(lq, 0) or lq == inf or lus == Constant(-1) * inf)
				then
					-- L'Hospital:
					p = p:diff(x)()
					q = q:diff(x)()
					return prune:apply(Limit((p/q):prune(), x, a, side))
				end
--]=]


				--[[ 
				alright, p/q has an asymptote here ... how to determine which way it goes.
				
				lim x->0+ 1/x is inf
				lim x->0- 1/x is -inf
				
				lim x->0+ 1/x^2 is inf
				lim x->0- 1/x^2 is inf
				
				lim x->0+ x/x^2 is inf
				lim x->0- x/x^2 is -inf

				... how do you convince it which to pick?

				first, simplfy, second, look at denominator power?
				
				--]]
				if Constant.isValue(lq, 0) then
-- [=[

					-- TODO only for 1/x or c/x for positive c (or swap for negative)

					if side == Side.plus then
						return inf
					elseif side == Side.minus then
						return Constant(-1) * inf
					else
						-- when lim g = 0 then we have to use L'Hopital's rule, or resort to the +/- side of the limit
						return symmath.invalid
					end
--]=]				
				elseif lq == inf or lq == Constant(-1) * inf then		-- p/inf
					return Constant(0)
				else
					return prune:apply(lp / lq)
				end
			end

			-- lim (p^q) = (lim p)^(lim q)
			local pow = symmath.op.pow
			if pow:isa(f) then
				local p, q = table.unpack(f)
				return prune:apply(Limit(p, x, a, side) ^ Limit(q, x, a, side))
			end
	
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
