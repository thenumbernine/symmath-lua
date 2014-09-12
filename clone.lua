return function(obj, ...)
	if type(obj) ~= 'table' then return obj end
	local Expression = require 'symmath.Expression'
	if obj.isa and obj:isa(Expression) then
		return obj:clone()
	end
	--non-Expression table?
	return obj
end

