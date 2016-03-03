local function has(expr, x)
	local found = false
	expr:map(function(y)
		if y == x then found = true end
	end)
	return found
end

-- if expr == x^n for some nonnegative integer n then returns n
-- otherwise returns nil
local function isXToTheNth(expr, x)
	if expr == x then return 1 end
	local powOp = require 'symmath.powOp'
	local Constant = require 'symmath.Constant'
	if powOp.is(expr)
	and expr[1] == x
	and Constant.is(expr[2])
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
	local mulOp = require 'symmath.mulOp'
		
	if not mulOp.is(expr) then
--print('not mulOp')
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
--print('is mulOp')
		-- then process all terms
		-- if you find an x^n then assume it's the only one there (courtesy of simplify())
		-- and put the rest in a mulOp and add it to coeffs[n]
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
-- checks if it's in a div -> add -> mul form, and (if so) tosses the denominator
-- returns coefficients of a non-equation expression
-- such that (sum for n=0 to table.max(result) of x^n * result[n]) + result.extra == expr
return function(expr, x)
--print('polyCoeffs',expr,x)
	local addOp = require 'symmath.addOp'
	local divOp = require 'symmath.divOp'
	local mulOp = require 'symmath.mulOp'
	local Constant = require 'symmath.Constant'

	local ExpandPolynomial = require 'symmath.visitor.ExpandPolynomial'
	expr = ExpandPolynomial()(expr)
	expr = expr:simplify()
	
	-- ... but don't run tidy (to keep unms consts from being factored out) ... so, here's a final prune ...
	local prune = require 'symmath.prune'
	expr = prune(expr)
--print('simplifying',expr)
	--simplify/canoncial form is atm div -> add -> mul
	-- so a), cross-multiply denominator (if it's there)
	-- b) solve polynomial 
	
	-- here is the equivalent of multipling by denomiators
	if divOp.is(expr) then
		expr = expr[1]	-- cross multiply the denom across with the zero 
	end
	
	-- group terms by polynomial coefficients
	local coeffs = {}	-- result = coeffs[n] * x^n + coeffs.extra, where coeffs.extra holds all the nonlinear x references

	if not addOp.is(expr) then
--print('not addOp')
		processTerm(coeffs, expr, x)
	else
--print('is addOp')
		for i=#expr,1,-1 do
			processTerm(coeffs, expr[i], x)
		end
	end

--[[
--print('got coeffs')
for k,v in pairs(coeffs) do
	--print(k,v)
end
--]]

	return coeffs
end

