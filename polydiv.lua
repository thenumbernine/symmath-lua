local table = require 'ext.table'
local polyCoeffs = require 'symmath.polyCoeffs'
local Constant = require 'symmath.Constant'

--[[
polydiv(a,b)
a:polydiv(b)

returns a / b where a and b are polynomials wrt the variable x
--]]
return function(a, b, x)
	
	if not x then
		-- infer x.  from the highest variable integer power of a? ... of b?
		-- from whatever the two have in common?
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
