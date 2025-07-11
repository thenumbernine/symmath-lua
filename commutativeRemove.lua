-- this is going to work like the tableCommutativeEqual
-- returns 'false' if self doesn't contain expr
-- returns the set subtraction if it does
local table = require 'ext.table'
return function(self, expr)
	local clone = self:clone()

	local exprs
	if not getmetatable(self):isa(expr) then
		exprs = {expr}
	else
		exprs = expr
	end

	for i,expri in ipairs(exprs) do
		local found
		for j=1,#clone do
			if clone[j] == expri then
--DEBUG(@5):print('partial replace found',expri,'<br>')
				table.remove(clone, j)
				found = true
				break
			end
		end
		if not found then
--DEBUG(@5):print("partial replace didn't find",expri,'<br>')
			return false, clone
		end
	end
--DEBUG(@5):print("partial replace found all<br>")
	return true, clone
end
