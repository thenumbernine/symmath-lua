local table = require 'ext.table'
local symmath

local function filterUnique(...)
	local t = table()
	for i=1,select('#', ...) do
		t:insertUnique((select(i, ...)))
	end
	return t:unpack()
end

--[[
accepts an equation and a variable
returns an equation with that variable on the lhs and the rest on the rhs
--]]
local function solve(eqn, x, hasSimplified)
	symmath = symmath or require 'symmath'
	local unm = symmath.op.unm
	local div = symmath.op.div
	local mul = symmath.op.mul
	local sqrt = symmath.sqrt
	local polyCoeffs = symmath.polyCoeffs
	local Constant = symmath.Constant
	local Equation = symmath.op.Equation

	assert(eqn, 'expected equation to solve, or expression to solve for zero')
	if not Equation:isa(eqn) then
		error("expected the expression to be an equation or inequality: "..eqn)
	end

	-- should I solve as-is at first
	-- or should I try to move everything to one side first?
	-- should I then simplify()
	-- 		which cross-multiplies fractions and potentially changes denominators, and therefore solution sets
	-- 		but also groups terms and therefore could reduce the # of variables in the equation
	eqn = eqn:prune():factor()	-- or should I do this per-part?

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

		-- fwiw here's the pathway that (x^2):eq(0) uses
		return
		--filterUnique(
			solns:mapi(function(soln)
				return x:eq(soln())
			end):unpack()
		--)
	end

	-- otherwise, polynomial solver?

	local eq = getmetatable(eqn)
		-- move everything to one side of the equation
--print'subtracting lhs from rhs...'
	local lhs = eqn[1] - eqn[2]
--print('...got',lhs)

	-- -x = 0 => x = 0
	if unm:isa(lhs) then lhs = lhs[1] end

-- [[ handle denominator
	if div:isa(lhs) then
		-- TODO why is this intermittantly adding the x != 0 ?
		local notZero = table{lhs[2]:eq(0):solve(x)}
		if notZero[1] == nil then notZero = table() end	-- couldn't find the solve var
		for i=1,#notZero do
			assert(symmath.op.eq:isa(notZero[i]))
			setmetatable(notZero[i], symmath.op.ne)
		end
		local solns = notZero
		-- make sure you add the != operators last
		solns = table{lhs[1]:eq(0):solve(x)}:append(solns)
		-- TODO remove contraditions, {x!=y, x==y} => {x!=y}
		return
		--filterUnique(
			solns:unpack()
		--)
	end
--]]

	-- handle multiplication separately
	if mul:isa(lhs) then
		local solns = table()
		for _,term in ipairs(lhs) do
			if term:dependsOn(x) then
				solns:append{term:eq(0):solve(x)}
			end
		end
		return
		--filterUnique(
			solns:unpack()
		--)
	end

--print('looking for coeffs wrt',x)
	local coeffs = polyCoeffs(lhs, x)

	local function getCoeff(n)
		return coeffs[n] or Constant(0)
	end

	local n = table.maxn(coeffs)

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
--print('solving poly n==2')
			local a,b,c = getCoeff(2), getCoeff(1), getCoeff(0)
			local res1 = eq(x, (-b-sqrt(b^2-4*a*c))/(2*a))()
			local res2 = eq(x, (-b+sqrt(b^2-4*a*c))/(2*a))()
			return
			--filterUnique(
				res1, res2
			--)
		end
		-- and on ...

		if n == 4 then
--print('solving poly n==4')
			if not coeffs[1] and not coeffs[3] then
				-- ax^4 + bx^2 + c
				local a,b,c = getCoeff(4), getCoeff(2), getCoeff(0)
				local res1 = eq(x, sqrt((-b-sqrt(b^2-4*a*c))/(2*a)))()
				local res2 = eq(x, sqrt((-b+sqrt(b^2-4*a*c))/(2*a)))()
				return
				--filterUnique(
					res1, (-res1)(), res2, (-res2)()
				--)
			end
		end
	end

	local result = Constant(0)
	for i=0,n do
		if coeffs[i] then
			result = result + x^i * coeffs[n]
		end
	end
	if coeffs.extra then
		result = result + coeffs.extra
	end

	if not hasSimplified then
		return result():eq(0):solve(x, true)
	end

	return result:eq(0)
end

return solve
