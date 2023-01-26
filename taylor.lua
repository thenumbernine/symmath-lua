--[[
I'll have this immediately evaluate for now
Maybe later I'll make it deferrable
args:
	expr = expression
	x = variable to expand
	a = where to expand.  default is 0.
	n = how many iterations to expand.  default is infinite.  though I can't handle infinite sums yet.
--]]
return function(expr, x, a, n)
--	n = n or symmath.inf
	a = a or 0
	-- x = x or whatever the first var of 'x' is
	--[[ TODO can't use Sum until I can represent lim n->inf d/dx^n
	-- but right now :diff() requires a finite set of variables
	-- so TODO I need to change :diff to accept a number of differentiation
	-- how about change :diff(x,x) to :diff(x,2) and make the shorthand :diff(x,y) to :diffs(x,y)
	-- TODO I also don't have gamma function or factorial.
	-- TODO make sure 'n' is not found in 'expr'
	local symmath = require 'symmath'
	local i = symmath.Variable'i'
	return symmath.Sum(expr:diff(x, i) * (x - a)^i / factorial(i), i, 0, n)
	--]]

	local sum = 0
	local factorial_i = 1
	local poly = 1
	for i=0,n do
		if i > 0 then
			expr = expr:diff(x)()
		end
		factorial_i = factorial_i * math.max(i, 1)
		sum = sum + expr:replace(x,a) * (x - a)^i / factorial_i
	end
	return sum
end
