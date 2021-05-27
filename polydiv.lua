local table = require 'ext.table'
local polyCoeffs = require 'symmath.polyCoeffs'
local Constant = require 'symmath.Constant'

--[[
polydiv(a,b)
a:polydiv(b)

returns a / b where a and b are polynomials wrt the variable x
--]]
return function(a, b, x)
--print('a', a)
--print('b', b)
--print('x', x)
		
	local res = {}

	local cb = polyCoeffs(b, x)
--print('coeffs of b:')
--for k,v in pairs(cb) do print(k,v) end
	local db = table.maxn(cb)
--print('degree of b', db)
	local lb = cb[db]
--print('lead of b', lb)
	
	local ca = polyCoeffs(a, x)
--print('coeffs of a:')
--for k,v in pairs(ca) do print(k,v) end
	local da = table.maxn(ca)
--print('degree of a', da)
	local la = ca[da]
--print('lead of a', la)
	
	while da >= db do
		local r = (la / lb)()
		local i = da-db
--print('scaling by x^'..i)
		res[i] = r:clone()
--print('setting res', i, 'to', r)		
		a = (a - r * b * x^i)()
--print('new a:', a)		
		ca = polyCoeffs(a, x)
--print('coeffs of a:')
--for k,v in pairs(ca) do print(k,v) end
		da = table.maxn(ca)
--print('degree of a', da)
		la = ca[da]
--print('lead of a', la)

--do break end
	end

--print('coeffs of res:')
--for k,v in pairs(res) do print(k,v) end
	local sum = symmath.Constant(0)
	local keys = table.keys(res):sort(function(a,b) return a > b end)
	for _,k in ipairs(keys) do
		local v = res[k]
--print('adding', v, k)
		sum = sum + v * (k == 0 and 1 or (k == 1 and x or x^k))
	end
	return sum + a / b
end
