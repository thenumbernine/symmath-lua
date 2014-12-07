
--[[
accepts an equation and a variable
returns an equation with that variable on the lhs and the rest on the rhs
--]]
return function(eqn, x)
	assert(eqn, 'expected equation or expression to solve for zero')
	
	local mulOp = require 'symmath.mulOp'
	local EquationOp = require 'symmath.EquationOp'	
	local Constant = require 'symmath.Constant'
	
	local lhs
	local equalityClass = EquationOp
	if eqn:isa(EquationOp) then
		equalityClass = getmetatable(eqn)
		-- move everything to one side of the equation
		lhs = eqn[1] - eqn[2]
	else
		-- or just treat it like it is a lhs == 0
		lhs = eqn
	end

	local polyCoeffs = require 'symmath.polyCoeffs'
	local coeffs = polyCoeffs(lhs, x)

	local function getCoeff(n)
		return coeffs[n] or Constant(0)
	end

	-- 'homogeneous' polynomial
	if not coeffs.extra then
		local n = table.maxn(coeffs)
		if n == 0 then return end	-- a = 0 <=> no solutions
		if n == 1 then		-- c1 x + c0 = 0 <=> x = -c0/c1
--print('coeffs',table.map(coeffs[1],tostring):concat('\n'),'\nend coeffs')
			return equalityClass(x, -getCoeff(0) / getCoeff(1)):simplify()
		end
		-- this is where factor() comes in handy ...
		if n == 2 then
			local a,b,c = getCoeff(2), getCoeff(1), getCoeff(0)
			local sqrt = require 'symmath.sqrt'
			return equalityClass(x, (-b-sqrt(b^2-4*a*c))/(2*a)):simplify(),
					equalityClass(x, (-b+sqrt(b^2-4*a*c))/(2*a)):simplify()
		end
		-- and on ...
	end

	local result = Constant(0)
	for i=0,table.maxn(coeffs) do
		if coeffs[i] then
			result = result + x^n * getCoeff(i) 
		end
	end
	if coeffs.extra then
		result = result + getCoeff'extra'
	end

end
