-- I would use 'dependsOn', but that also returns true if a variable is defined as depending on this variable
local function has(expr, x)
	local found = false
	expr:map(function(y)
		if y == x then found = true end
	end)
	return found
end

-- if expr == x^n for some nonnegative integer n then returns n
-- otherwise returns nil
-- TODO use :match() maybe?  add support for Wildcard matching only constants? only to a specific class?
local function isXToTheNth(expr, x)
	if expr == x then return 1 end
	local pow = require 'symmath.op.pow'
	local Constant = require 'symmath.Constant'
	if pow:isa(expr)
	and expr[1] == x
	and Constant:isa(expr[2])
	then
		local n = expr[2].value
		if n == math.floor(n)
		and n > 0
		then
			return n
		end
	end
end

local function addToCoeffs(coeffs, n, expr)
	local Constant = require 'symmath.Constant'
	if Constant.isValue(expr, 0) then return end
	if not coeffs[n] then
		coeffs[n] = expr
	else
		coeffs[n] = coeffs[n] + expr
	end
end

-- processes an individual term of f(x) = sum(i, coeffs[i] * x^i) + coeffs.extra
local function processTerm(coeffs, expr, x)
--print('processTerm',expr,x)
	local clone = require 'symmath.clone'
	local mul = require 'symmath.op.mul'
		
	if not mul:isa(expr) then
--print('not mul')
		-- just process expr
--print('testing',expr,x)
		local n = isXToTheNth(expr, x)
--print('got power',n)
		if n then
			-- if expr is x^n then add 1 to the x^n coefficient
			local Constant = require 'symmath.Constant'
			addToCoeffs(coeffs, n, Constant(1))
		else
			-- if expr is not x^n then ...
			if has(expr, x) then
				-- if expr is a function of x then put it in extra
				addToCoeffs(coeffs, 'extra', expr)
			else
				-- otherwise, expr is not a function of x, consider it linear wrt x
				addToCoeffs(coeffs, 0, expr)
			end
		end
	else
--print('is mul')
		-- then process all terms
		-- if you find an x^n then assume it's the only one there (courtesy of simplify())
		-- and put the rest in a mul and add it to coeffs[n]
		for i=1,#expr do
--print('testing',expr[i],x)
			local n = isXToTheNth(expr[i], x)
--print('got power',n)
			if n then
				if #expr == 2 then	-- the insert the other
					addToCoeffs(coeffs, n, expr[2-i+1])
				else	-- add the rest of the mul-op terms
					local c = clone(expr)
					table.remove(c, i)
					addToCoeffs(coeffs, n, c)
				end
				return		-- assume there's only one x^n
			end
		end
		-- if we made it this far then there's no x^n among the multiplication elements
		-- if any of them do manage to have an 'x' then assume it's nonlinear and put that in extra
		if has(expr, x) then
			addToCoeffs(coeffs, 'extra', expr)
		else
			addToCoeffs(coeffs, 0, expr)
		end
	end
end

-- assumes this is in a add -> mul form
-- returns coefficients of a non-equation expression
-- such that (sum for n=0 to table.max(result) of x^n * result[n]) + result.extra == expr
return function(expr, x)
	local ExpandPolynomial = require 'symmath.visitor.ExpandPolynomial'
	
	--[[
	Alright, this is supposed to put our expression into a polynomial form
	but it's not
	It's supposed to do something like simplifyAddMulDiv does
	but simplifyAddMulDiv doesn't specify powers, and seems to put powers at highest precedence
	when what we want here is powers at lowest precedence ... so add-mul-div-pow
	
	but with that said,
	where else are ExpandPolynomial or factorDivision used?
	isn't factorDivision now just simplifyAddMulDiv?  no, it's called by it though on all its terms
	--]]
	expr = ExpandPolynomial()(expr)
	--expr = expr:simplify()		-- this recombines polys into pow-mul-add
	--expr = expr:factorDivision()	-- this recombines too
	--expr = expr:simplifyAddMulDiv()	-- this starts off with :simplify(), so it's as bad as above

	-- mul/Prune/factorDenominators will convert back to div, so avoid that	
	local mul = require 'symmath.op.mul'
	local pushed = mul:pushRule'Prune/factorDenominators'
	expr = expr:prune()				-- this combines x powers and sums without recombining the poly
	if pushed then mul:popRule'Prune/factorDenominators' end
	
	-- group terms by polynomial coefficients
	local coeffs = {}	-- result = coeffs[n] * x^n + coeffs.extra, where coeffs.extra holds all the nonlinear x references

	for term in expr:iteradd() do
		processTerm(coeffs, term, x)
	end

	return coeffs
end
