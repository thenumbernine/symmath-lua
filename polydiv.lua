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
local function polydivr(a, b, x, verbose)
	if verbose then
		verbose = _G.printbr or _G.print
		verbose'polydivr begin'
	end
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	local polyCoeffs = symmath.polyCoeffs
	local clone = symmath.clone

	if verbose then
		verbose('polydivr dividing', a, 'by', b, 'wrt var', x)
	end	
	
	-- in case someone is dividing by a Lua number...
	a = clone(a)
	b = clone(b)

	if not x then
		-- infer x.  from the highest variable integer power of a? ... of b?
		-- from whatever the two have in common?
		
		local vars = a:getDependentVars(b)
		
		if #vars == 0 then
			if verbose then
				verbose('found no vars, using normie division')			
			end			
			-- no variables at all?  no polynomial division 
			-- ... just use regular division
			-- TODO is this considered a remainder or the polynomial itself?
			return a / b, Constant(0)
		end
		
		if #vars == 1 then
			x = vars[1]
			if verbose then
				verbose('inferred var', x)		
			end		
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
		if verbose then
			verbose('found no leading poly, using normie division')			
		end		
		-- TODO is this considered a remainder or the polynomial itself?
		return a / b, Constant(0)
	end

	local ca = polyCoeffs(a, x)
	local da = table.maxn(ca)
	local la = ca[da]

	if verbose then
		verbose'coeffs of numerator'
		for k,v in pairs(ca) do
			verbose('coeff', k,' = ', v)
		end
		verbose'coeffs of denom'
		for k,v in pairs(cb) do
			verbose('coeff', k,' = ', v)
		end
		verbose('numerator degree', da)
		verbose('numerator leading coefficient', la)
	end

	while da >= db do
		local r = (la / lb)()
		local i = da-db
		if verbose then
			verbose('setting the ', i, 'th result coefficient to ', r)
		end		
		if res[i] then
			-- something went wrong ? 
			-- most likely the num / denom wasn't in add -> mul -> div form
			break
		end
		res[i] = r:clone()
		if verbose then
			verbose('numerator becomes', a - r * b * x^i)
		end
		a = (a - r * b * x^i)()
		if verbose then
			verbose('simplified numerator is', a)		
		end		
		ca = polyCoeffs(a, x)
		if verbose then
			verbose'coeffs of numerator'
			for k,v in pairs(ca) do
				verbose('coeff', k,' = ', v)
			end
		end
		da = table.maxn(ca)
		la = ca[da]
		if verbose then
			verbose('numerator degree is now', da)
			verbose('numerator leading coefficient', la)
		end
	end

	local sum = Constant(0)
	local keys = table.keys(res):sort(function(a,b) return a > b end)
	for _,k in ipairs(keys) do
		local v = res[k]
		if verbose then
			verbose('sum adding degree',k,' coeff', v,'of var', x)		
		end
		sum = sum + v * (k == 0 and Constant(1) or (k == 1 and x or x^k))
	end

	if verbose then
		verbose('polydivr returning sum', sum)
		verbose('returning remainder', a)
	end
	return sum, a
end

--[[
return (a/b) using polynomial long-division
--]]
local function polydiv(a, b, x, verbose)
	if verbose then
		verbose'polydiv begin'
	end	
	if verbose then
		verbose'polydiv calling polydivr'
	end	
	local res, remainder = polydivr(a, b, x, verbose)
	if verbose then
		verbose'polydiv returning results'
	end
	return res + (remainder / b)()
end

return setmetatable({
	polydiv = polydiv,
	polydivr = polydivr,
}, {
	__call = function(T, a, b, x, verbose)
		if verbose then
			verbose'polydiv.__call begin'
			verbose'polydiv.__call tail-calling polydiv'
		end		
		return polydiv(a, b, x, verbose)		-- by default return a single expression
	end,
})
