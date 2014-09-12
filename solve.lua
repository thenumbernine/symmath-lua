--[[
accepts an equation and a variable
returns an equation with that variable on the lhs and the rest on the rhs
--]]
return function(eqn, var)
	-- 1) move everything to one side of the equation
	-- 2) expand() to put our equations in mul add div order
	-- 3) solve for roots of each term that has our variable in it
	local zero = (eqn.xs[1] - eqn.xs[2]):simplify()
end
