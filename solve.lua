local function maxn(t)
	local m = 0
	for k,v in pairs(t) do
		if type(k) == 'number' then
			m = math.max(m, k)
		end
	end
	return m
end

--[[
accepts an equation and a variable
returns an equation with that variable on the lhs and the rest on the rhs
--]]
return function(eqn, x)
	local div = require 'symmath.op.div'
	local mul = require 'symmath.op.mul'
	local Equation = require 'symmath.op.Equation'	
	local Constant = require 'symmath.Constant'
	local polyCoeffs = require 'symmath.polyCoeffs'
	local sqrt = require 'symmath.sqrt'
	
	assert(eqn, 'expected equation to solve, or expression to solve for zero')

	eqn = eqn()

-- multiply by all denominators
-- or just those of the variable we want to solve for?
	if div.is(eqn[1]) then
		eqn = (eqn * eqn[1][1])()
	end
	if div.is(eqn[2]) then
		eqn = (eqn * eqn[2][2])()
	end

	assert(Equation.is(eqn), "expected the expression to be an equation or inequality")
	
	local eq = getmetatable(eqn)
		-- move everything to one side of the equation
print'subtracting lhs from rhs...<br>'		
	local lhs = eqn[1] - eqn[2]
print('...got',lhs,'<br>')
	
print('looking for coeffs wrt',x,'<br>')	
	local coeffs = polyCoeffs(lhs, x)
print('...got',require 'ext.tolua'(coeffs),'<br>')

	local function getCoeff(n)
		return coeffs[n] or Constant(0)
	end

	-- 'homogeneous' polynomial
	if not coeffs.extra then
		local n = maxn(coeffs)
		if n == 0 then return end	-- a = 0 <=> no solutions
		if n == 1 then		-- c1 x + c0 = 0 <=> x = -c0/c1
--print('coeffs',table.map(coeffs[1],tostring):concat('\n'),'\nend coeffs')
			return eq(x, -getCoeff(0) / getCoeff(1))()
		end
		-- this is where factor() comes in handy ...
		if n == 2 then
			local a,b,c = getCoeff(2), getCoeff(1), getCoeff(0)
			return eq(x, (-b-sqrt(b^2-4*a*c))/(2*a))(),
					eq(x, (-b+sqrt(b^2-4*a*c))/(2*a))()
		end
		-- and on ...
	end

	local result = Constant(0)
	for i=0,maxn(coeffs) do
		if coeffs[i] then
			result = result + x^i * getCoeff(i) 
		end
	end
	if coeffs.extra then
		result = result + getCoeff'extra'
	end
	return result
end
