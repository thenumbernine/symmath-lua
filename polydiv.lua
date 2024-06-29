local table = require 'ext.table'
local symmath

--[[
polydiv(a,b[,x])
a:polydiv(b[,x])

assumes the expression is in add -> mul form

where a and b are polynomials wrt the variable x
if x is omitted then it is attempted to be inferred

returns (a / b), remainder
--]]
local function polydivr(a, b, x)
--DEBUG(symmath.polydiv): print'polydivr begin'
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	local polyCoeffs = symmath.polyCoeffs
	local clone = symmath.clone

--DEBUG(symmath.polydiv): print('polydivr dividing', a, 'by', b, 'wrt var', x)

	-- in case someone is dividing by a Lua number...
	a = clone(a)
	b = clone(b)

	if not x then
		-- infer x.  from the highest variable integer power of a? ... of b?
		-- from whatever the two have in common?

		local vars = a:getDependentVars(b)

		if #vars == 0 then
--DEBUG(symmath.polydiv): print('found no vars, using normie division')
			-- no variables at all?  no polynomial division
			-- ... just use regular division
			-- TODO is this considered a remainder or the polynomial itself?
			return a / b, Constant(0)
		end

		if #vars == 1 then
			x = vars[1]
--DEBUG(symmath.polydiv): print('inferred var', x)
		end
		if #vars == 2 then
			error("you didn't specify an 'x' variable, and there are more than one variables for me to choose from.")
		end
	end

	local res = {}

	local cb = polyCoeffs(b, x)
	local db = table.maxn(cb)
	local lb = cb[db]

	-- if the max degree of the denominator is 0 then the variable doesn't appear in the denominator
	-- and that means no polynomial division is needed
	if db == 0 then
--DEBUG(symmath.polydiv): print('found no leading poly, using normie division')
		-- TODO is this considered a remainder or the polynomial itself?
		return a / b, Constant(0)
	end

	local ca = polyCoeffs(a, x)
	local da = table.maxn(ca)
	local la = ca[da]

--DEBUG(symmath.polydiv):	print'coeffs of numerator'
--DEBUG(symmath.polydiv):	for k,v in pairs(ca) do
--DEBUG(symmath.polydiv):		print('coeff', k,' = ', v)
--DEBUG(symmath.polydiv):	end
--DEBUG(symmath.polydiv):	print'coeffs of denom'
--DEBUG(symmath.polydiv):	for k,v in pairs(cb) do
--DEBUG(symmath.polydiv):		print('coeff', k,' = ', v)
--DEBUG(symmath.polydiv):	end
--DEBUG(symmath.polydiv):	print('numerator degree', da)
--DEBUG(symmath.polydiv):	print('numerator leading coefficient', la)

	while da >= db do
		local r = (la / lb)()
		local i = da-db
--DEBUG(symmath.polydiv):	print('setting the ', i, 'th result coefficient to ', r)
		if res[i] then
			-- something went wrong ?
			-- most likely the num / denom wasn't in add -> mul -> div form
			break
		end
		res[i] = r:clone()
--DEBUG(symmath.polydiv):	print('numerator becomes', a - r * b * x^i)
		a = (a - r * b * x^i)()
--DEBUG(symmath.polydiv):	print('simplified numerator is', a)
		ca = polyCoeffs(a, x)
--DEBUG(symmath.polydiv):	print'coeffs of numerator'
--DEBUG(symmath.polydiv):	for k,v in pairs(ca) do
--DEBUG(symmath.polydiv):		print('coeff', k,' = ', v)
--DEBUG(symmath.polydiv):	end
		da = table.maxn(ca)
		la = ca[da]
--DEBUG(symmath.polydiv):	print('numerator degree is now', da)
--DEBUG(symmath.polydiv):	print('numerator leading coefficient', la)
	end

	local sum = Constant(0)
	local keys = table.keys(res):sort(function(a_,b_) return a_ > b_ end)
	for _,k in ipairs(keys) do
		local v = res[k]
--DEBUG(symmath.polydiv):	print('sum adding degree',k,' coeff', v,'of var', x)
		sum = sum + v * (k == 0 and Constant(1) or (k == 1 and x or x^k))
	end

--DEBUG(symmath.polydiv):	print('polydivr returning sum', sum)
--DEBUG(symmath.polydiv):	print('returning remainder', a)
	return sum, a
end

--[[
return (a/b) using polynomial long-division
--]]
local function polydiv(a, b, x)
--DEBUG(symmath.polydiv):	print'polydiv begin'
--DEBUG(symmath.polydiv):	print'polydiv calling polydivr'
	local res, remainder = polydivr(a, b, x)
--DEBUG(symmath.polydiv):	print'polydiv returning results'
	return res + (remainder / b)()
end

return setmetatable({
	polydiv = polydiv,
	polydivr = polydivr,
}, {
	__call = function(T, a, b, x)
--DEBUG(symmath.polydiv):	print'polydiv.__call begin'
--DEBUG(symmath.polydiv):	print'polydiv.__call tail-calling polydiv'
		return polydiv(a, b, x)		-- by default return a single expression
	end,
})
