local table = require 'ext.table'

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
local function solve(eqn, x, hasSimplified)
	local unm = require 'symmath.op.unm'
	local div = require 'symmath.op.div'
	local mul = require 'symmath.op.mul'
	local Equation = require 'symmath.op.Equation'	
	local Constant = require 'symmath.Constant'
	local polyCoeffs = require 'symmath.polyCoeffs'
	local sqrt = require 'symmath.sqrt'
	
	assert(eqn, 'expected equation to solve, or expression to solve for zero')
	if not Equation.is(eqn) then	
		error("expected the expression to be an equation or inequality: "..eqn)
	end

	-- should I solve as-is at first
	-- or should I try to move everything to one side first?
	-- should I then simplify()
	-- 		which cross-multiplies fractions and potentially changes denominators, and therefore solution sets
	-- 		but also groups terms and therefore could reduce the # of variables in the equation

	-- count occurrences
	local count = 0
	local stack = table()
	local trace = table()
	local function recurse(expr)
		for i,ch in ipairs(expr) do
			stack:insert{expr=ch,index=i}
			if ch==x then
				count = count + 1
				trace:insert(table(stack))
			end
			recurse(ch)
			assert(rawequal(stack:remove().expr, ch))
		end
	end
	
	recurse(eqn)
	
	if count == 0 then
		return nil, "couldn't find "..x.." in eqn "..eqn
	end
	-- in this case, find the variable, reverse each operation above it 
--print('solving for ',x)	
	if count == 1 then
--print('found 1 occurrence')		
		local stack = trace[1]
--print('our stack is',stack:map(function(q) return q.expr end):unpack())		
		-- trace[1] holds the stack to the var, so we can find parents that way
		local solns
		local side = stack[1].index
--print('our variable is on side',side)		
		if side == 1 then
			solns = table{eqn[2]:clone()}
		elseif side == 2 then
			solns = table{eqn[1]:clone()}
		end
--print('starting with',solns:unpack())
		assert(stack[#stack].expr == x)
		for j=1,#stack-1 do
			local expr = stack[j].expr
			local index = stack[j+1].index
--print('solving for index',index,'of expr',expr)
			local nextsolns = table()
			for _,soln in ipairs(solns) do
				local exprsolns = table{expr:reverse(soln, index)}
				nextsolns:append(exprsolns)
			end
			solns = nextsolns
--print('got',solns:unpack())
		end
	
		return solns:map(function(soln) 
			return x:eq(soln()) 
		end):unpack()
	end
	-- otherwise, polynomial solver?

	local eq = getmetatable(eqn)
		-- move everything to one side of the equation
--print'subtracting lhs from rhs...'		
	local lhs = eqn[1] - eqn[2]
--print('...got',lhs)

	-- -x = 0 => x = 0
	if unm.is(lhs) then lhs = lhs[1] end

-- [[ handle denominator
	if div.is(lhs) then
		local notZero = table{lhs[2]:eq(0):solve(x)}
		if notZero[1] == nil then notZero = table() end	-- couldn't find the solve var
		for i=1,#notZero do
			assert(op.eq.is(notZero[i]))
			setmetatable(notZero[i], op.ne)
		end
		local solns = notZero
		-- TODO remove contraditions, {x!=y, x==y} => {x!=y}
		solns:append{lhs[1]:eq(0):solve(x)}
		return solns:unpack()
	end
--]]
	
	-- handle multiplication separately
	if mul.is(lhs) then
		local solns = table()
		for _,term in ipairs(lhs) do
			if term:dependsOn(x) then
				solns:append{term:eq(0):solve(x)}
			end
		end
		return solns:unpack()
	end

--print('looking for coeffs wrt',x)	
	local coeffs = polyCoeffs(lhs, x)

	local function getCoeff(n)
		return coeffs[n] or Constant(0)
	end
	
	local n = maxn(coeffs)

	-- 'homogeneous' polynomial
	if not coeffs.extra then
		if n == 0 then return end	-- a = 0 <=> no solutions
		if n == 1 then		-- c1 x + c0 = 0 <=> x = -c0/c1
--print('coeffs',table.map(coeffs[1],tostring):concat('\n'),'\nend coeffs')
			return eq(x, -getCoeff(0) / getCoeff(1))()
		end
		-- quadratic solution
		-- this is where factor() comes in handy ...
		if n == 2 then
			local a,b,c = getCoeff(2), getCoeff(1), getCoeff(0)
			return eq(x, (-b-sqrt(b^2-4*a*c))/(2*a))(),
					eq(x, (-b+sqrt(b^2-4*a*c))/(2*a))()
		end
		-- and on ...
	
		if n == 4 then
			if not coeffs[1] and not coeffs[3] then
				-- ax^4 + bx^2 + c
				local a,b,c = getCoeff(4), getCoeff(2), getCoeff(0)
				local res1 = eq(x, sqrt((-b-sqrt(b^2-4*a*c))/(2*a)))()
				local res2 = eq(x, sqrt((-b+sqrt(b^2-4*a*c))/(2*a)))()
				return res1, (-res1)(), res2, (-res2)()
			end
		end
	end

	local result = Constant(0)
	for i=0,n do
		if coeffs[i] then
			result = result + x^i * getCoeff(i) 
		end
	end
	if coeffs.extra then
		result = result + getCoeff'extra'
	end

	if not hasSimplified then
		return result():eq(0):solve(x, true)
	end

	return result:eq(0)
end

return solve
