return function(...)
	local Constant = require 'symmath.Constant'
	local Matrix = require 'symmath.Matrix'
	local rows = Matrix()
	local n = select('#', ...)
	for i=1,n do
		local row = Matrix()
		rows[i] = row
		for j=1,n do
			local el
			if i == j then
				el = select(i, ...)
				if type(el) == 'number' then el = Constant(el) end
			else
				el = Constant(0)
			end
			row[j] = el
		end
	end
	return rows
end
