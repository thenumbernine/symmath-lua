local table = require 'ext.table'

--[[
accepts a table of {expr1, expr2, ...}
return table of {expr=expression, mult=multiplicity}
where 'multiplicity' is how often the particular expression appears
--]]
local function multiplicity(t)
	local n = table()
	for i,ti in ipairs(t) do
		local found
		for j=1,#n do
			if ti == n[j].expr then
				n[j].mult = n[j].mult + 1
				found = true
				break
			end
		end
		if not found then
			n:insert{expr=ti, mult=1}
		end
	end
	return n
end

return multiplicity
