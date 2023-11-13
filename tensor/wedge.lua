local table = require 'ext.table'
local Binary = require 'symmath.op.Binary'

local wedge = Binary:subclass()
wedge.precedence = 4
wedge.name = '/\\'

-- copied from mul
-- is this in add as well?  put in parent class?
function wedge:flatten()
	for i=#self,1,-1 do
		local ch = self[i]
		if wedge:isa(ch) then
			local expr = {table.unpack(self)}
			table.remove(expr, i)
			for j=#ch,1,-1 do
				local chch = ch[j]
				table.insert(expr, i, chch)
			end
			return wedge(table.unpack(expr))
		end
	end
end


wedge.rules = {
	Prune = {
		{apply = function(eval, expr)
			-- TODO sort somehow so db wedge da = -da wedge db
			-- for the sake of addition/subtraction
			print'FINISHME'
		end},
	}
}

return wedge
