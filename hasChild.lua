--[[
example: 
expr:hasChild(function(x) return whatever:isa(x) end)
--]]
local function hasChild(expr, lookfor)
	if lookfor(x) then return true end
	for i=1,#x do
		if hasChild(x[i], lookfor) then return true end
	end
end
return hasChild
