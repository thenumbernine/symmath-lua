--[[
accepts an equation and a variable
returns an equation with that variable on the lhs and the rest on the rhs
--]]
return function(eqn, x)
	local clone = require 'symmath.clone'
	local addOp = require 'symmath.addOp'
	local divOp = require 'symmath.divOp'
	local powOp = require 'symmath.powOp'
	local mulOp = require 'symmath.mulOp'
	local Constant = require 'symmath.Constant'
	
	eqn = clone(eqn)

	-- 1) move everything to one side of the equation
	local lhs = (eqn[1] - eqn[2]):simplify()
	
	--simplify/canoncial form is atm div -> add -> mul
	-- so a), cross-multiply denominator (if it's there)
	-- b) solve polynomial 
	
	-- TODO here multiply by any denomiators
	if lhs:isa(divOp) then
		lhs = lhs[1]	-- cross multiply the denom across with the zero 
	end
	
	-- group terms by polynomial coefficients
	local coeffs = {}	-- result = coeffs[n] * x^n + coeffs.extra, where coeffs.extra holds all the nonlinear x references

	local function has(expr, x)
		local found = false
		expr:map(function(y)
			if y == x then found = true end
		end)
		return found
	end

	local function isPoly(expr)
		if expr == x then return 1 end
		if expr:isa(powOp)
		and expr[1] == x
		and not has(expr[2], x)
		then
			-- found x^n
			local n = expr[2]
			if n:isa(Constant) then
				n = n.value 
				return n 
			end
		end
	end

	if not lhs:isa(addOp) then
		local power = isPoly(lhs)
		if power then
			coeffs[power] = {Constant(1)}
		else
			if has(lhs, x) then
				-- and ... with no other coeffs ... we can just solve the inverse of zero of whatever is wrapping 'x'
				coeffs.extra = {lhs}
			else
				-- and we have no solution
				--coeffs[0] = lhs
				return
			end
		end
	else
		for i=#lhs,1,-1 do
			-- mul op? 
			if lhs[i]:isa(mulOp) then
				
				-- find x^n, then look for any other f(x)
				local foundXToTheN = false
				for j=1,#lhs[i] do
					local power = isPoly(lhs[i][j])
					if power then
						table.remove(lhs[i], j)
						coeffs[power] = coeffs[power] or {}
						if #lhs[i] == 0 then
							table.insert(coeffs[power], Constant(1))
						else
							table.insert(coeffs[power], mulOp(unpack(lhs[i])))
						end
						foundXToTheN = true
						break
					end
				end
				-- didn't find x^n? if there's an x in it
				if not foundXToTheN then
					if has(lhs[i], x) then
						coeffs.extra = coeffs.extra or {}
						table.insert(coeffs.extra, lhs[i])
					else
						coeffs[0] = coeffs[0] or {}
						table.insert(coeffs[0], lhs[i])
					end
				end
			else	-- non-mul-op in the sum
				local power = isPoly(lhs[i])
				if power then
					coeffs[power] = coeffs[power] or {}
					table.insert(coeffs[power], Constant(1))
				else
					if has(lhs[i], x) then
						coeffs.extra = coeffs.extra or {}
						table.insert(coeffs.extra, lhs[i])
					else
						coeffs[0] = coeffs[0] or {}
						table.insert(coeffs[0], lhs[i])
					end
				end
			end
		end
	end

	local function getCoeff(n)
		if not coeffs[n] then return Constant(0) end
		if #coeffs[n] == 0 then return Constant(1) end
		return mulOp(unpack(coeffs[n]))
	end

	-- 'homogeneous' polynomial
	if not coeffs.extra then
		local n = table.maxn(coeffs)
		if n == 0 then return end	-- a = 0 <=> no solutions
		if n == 1 then		-- c1 x + c0 = 0 <=> x = -c0/c1
			print('coeffs',table.map(coeffs[1],tostring):concat('\n'),'\nend coeffs')
			return (-getCoeff(0) / getCoeff(1)):simplify()
		end
		-- this is where factor() comes in handy ...
		if n == 2 then
			local a,b,c = getCoeff(2), getCoeff(1), getCoeff(0)
			local sqrt = require 'symmath.sqrt'
			return ((-b-sqrt(b^2-4*a*c))/(2*a)):simplify(),
					((-b+sqrt(b^2-4*a*c))/(2*a)):simplify()
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

	return 
end
