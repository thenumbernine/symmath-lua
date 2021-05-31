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
--print'polydivr begin'
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	local polyCoeffs = symmath.polyCoeffs
	local clone = symmath.clone

--print('polydivr dividing', a, 'by', b, 'wrt var', x)
	
	-- in case someone is dividing by a Lua number...
	a = clone(a)
	b = clone(b)

	if not x then
		-- infer x.  from the highest variable integer power of a? ... of b?
		-- from whatever the two have in common?
		
		local vars = a:getDependentVars(b)
		
		if #vars == 0 then
--print('found no vars, using normie division')			
			-- no variables at all?  no polynomial division 
			-- ... just use regular division
			-- TODO is this considered a remainder or the polynomial itself?
			return a / b, Constant(0)
		end
		
		if #vars == 1 then
			x = vars[1]
--print('inferred var', x)		
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
--print('found no leading poly, using normie division')			
		-- TODO is this considered a remainder or the polynomial itself?
		return a / b, Constant(0)
	end

	local ca = polyCoeffs(a, x)
	local da = table.maxn(ca)
	local la = ca[da]

--print'coeffs of numerator'
--for k,v in pairs(ca) do
--	print('coeff', k,' = ', v)
--end
--print'coeffs of denom'
--for k,v in pairs(cb) do
--	print('coeff', k,' = ', v)
--end
	
	while da >= db do
		local r = (la / lb)()
		local i = da-db
--print('setting the ', i, 'th result coefficient to ', r)
		if res[i] then
			-- something went wrong ? 
			-- most likely the num / denom wasn't in add -> mul -> div form
			break
		end
		res[i] = r:clone()
		a = (a - r * b * x^i)()
--print('removing to find num now is', a)		
		ca = polyCoeffs(a, x)
		da = table.maxn(ca)
		la = ca[da]
	end

	local sum = Constant(0)
	local keys = table.keys(res):sort(function(a,b) return a > b end)
	for _,k in ipairs(keys) do
		local v = res[k]
--print('sum adding degree',k,' coeff', v,'of var', x)		
		sum = sum + v * (k == 0 and Constant(1) or (k == 1 and x or x^k))
	end
	
--print('polydivr returning sum', sum)
--print('returning remainder', a)
	return sum, a
end

--[[
return (a/b) using polynomial long-division
--]]
local function polydiv(...)
--print'polydiv begin'
	local a, b = ...
--print'polydiv calling polydivr'
	local res, remainder = polydivr(...)
--print'polydiv returning results'
	return res + (remainder / b)()
end

return setmetatable({
	polydiv = polydiv,
	polydivr = polydivr,
}, {
	__call = function(T, ...)
--print'polydiv.__call begin'
--print'polydiv.__call tail-calling polydiv'
		return polydiv(...)		-- by default return a single expression
	end,
})
