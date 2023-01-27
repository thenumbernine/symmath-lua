--[[
arguments:
none: returns 1
n: returns a nxn identity matrix
m,n: returns a mxn matrix with subset kxk equal to the identity matrix, for k = min(m,n)
--]]
return function(...)
	local nargs = select('#', ...)
	local Constant = require 'symmath.Constant'
	if nargs == 0 then return Constant(1) end
	local m,n
	if nargs == 1 then
		m = ...
		n = m
	elseif nargs == 2 then
		m,n = ...
	end
	local Matrix = require 'symmath.Matrix'
	local rows = Matrix()
	for i=1,m do
		local row = Matrix()
		rows[i] = row
		for j=1,n do
			row[j] = Constant(i == j and 1 or 0)
		end
	end
	return rows
end
