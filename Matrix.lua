require 'ext'
local Expression = require 'symmath.Expression'

local Matrix = class(Expression)
Matrix.name = 'Matrix'
Matrix.precedence = 10

function Matrix:init(...)
	local RowVector = require 'symmath.RowVector'
	local args = {...}
	if #args == 2
	and type(args[1]) == 'number'
	then
		local numRows = args[1]
		local numCols = args[2]
		-- treat them like width/height
		Matrix.super.init(self)
		local Constant = require 'symmath.Constant'
		for i=1,numRows do
			local row = RowVector()
			for j=1,numCols do
				row[j] = Constant(0)
			end
			self[i] = row
		end
	else
		Matrix.super.init(self, ...)
		for i=1,#self do
			if not (type(self[i]) == 'table') then 
				error('matrix children expected a row table')
			end
			self[i] = RowVector(unpack(self[i]))
		end
	end
end

return Matrix

