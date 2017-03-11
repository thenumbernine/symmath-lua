local range = require 'ext.range'

--[[
arguments:
none: returns 1
n: returns a nxn identity matrix
m,n: returns a mxn matrix with subset kxk equal to the identity matrix, for k = min(m,n)
--]]
return function(...)
	local symmath = require 'symmath'
	local nargs = select('#', ...)
	if nargs == 0 then return symmath.Constant(1) end
	local m,n
	if nargs == 1 then
		m = ...
		n = m
	elseif nargs == 2 then
		m,n = ...
	end
	return symmath.Matrix(
		range(m):map(function(i)
			return range(n):map(function(j)
				return i == j and 1 or 0
			end)
		end):unpack()
	)
end
