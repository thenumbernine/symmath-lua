local table = require 'ext.table'
return function(...)
	local args = {...}
	local rows = {}
	for i=1,#args do
		rows[i] = {}
		for j=1,#args do
			rows[i][j] = 0
		end
		rows[i][i] = args[i]
	end
	return require 'symmath.Matrix'(table.unpack(rows))
end
