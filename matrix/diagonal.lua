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
	return require 'symmath.Matrix'(unpack(rows))
end
