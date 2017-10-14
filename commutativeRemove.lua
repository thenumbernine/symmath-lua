-- this is going to work like the nodeCommutativeEqual
-- returns 'false' if self doesn't contain expr
-- returns the set subtraction if it does
local table = require 'ext.table'
return function(self, expr)
	local clone = self:clone()

	local exprs
	if not getmetatable(self).is(expr) then
		exprs = {expr}
	else
		exprs = expr
	end

	for i,expri in ipairs(exprs) do
		local found
		for j=1,#clone do
			if clone[j] == expri then
				table.remove(clone, j)
				found = true
				break
			end
		end
		if not found then
			return false, clone
		end
	end
	return true, clone
end
