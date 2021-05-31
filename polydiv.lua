local table = require 'ext.table'
local symmath

--[[
polydiv(a,b[,x])
a:polydiv(b[,x])

returns a / b where a and b are polynomials wrt the variable x
--]]
return function(a, b, x)
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	local polyCoeffs = symmath.polyCoeffs
	local clone = symmath.clone
	
	-- in case someone is dividing by a Lua number...
	a = clone(a)
	b = clone(b)

	if not x then
		-- infer x.  from the highest variable integer power of a? ... of b?
		-- from whatever the two have in common?
		local vars = {}
		local function collectVars(x)
			if symmath.Variable:isa(x) then
				vars[x.name] = x
			end
		end
		a:map(collectVars)
		b:map(collectVars)
		local keys = table.keys(vars)
		if #keys == 0 then
			-- no variables at all?  no polynomial division 
			-- ... just use regular division
			return symmath.simplify(a / b)
		end
		
		if #keys == 1 then
			x = vars[keys[1]]
		end
		if #keys == 2 then
			error("you didn't specify an 'x' variable, and there are more than one variables for me to choose from.")
		end
	end

	local res = {}

	local cb = polyCoeffs(b, x)
	local db = table.maxn(cb)
	local lb = cb[db]
	
	local ca = polyCoeffs(a, x)
	local da = table.maxn(ca)
	local la = ca[da]
	
	while da >= db do
		local r = (la / lb)()
		local i = da-db
		res[i] = r:clone()
		a = (a - r * b * x^i)()
		ca = polyCoeffs(a, x)
		da = table.maxn(ca)
		la = ca[da]
	end

	local sum = Constant(0)
	local keys = table.keys(res):sort(function(a,b) return a > b end)
	for _,k in ipairs(keys) do
		local v = res[k]
		sum = sum + v * (k == 0 and Constant(1) or (k == 1 and x or x^k))
	end
	return sum + (a / b)()
end
