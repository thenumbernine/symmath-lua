return function(obj, ...)
	local Constant = require 'symmath.Constant'
	local Expression = require 'symmath.Expression'
	
	if type(obj) == 'number' then return Constant(obj) end
	if type(obj) ~= 'table' then return obj end
	if Expression.is(obj) then return obj:clone() end
	
	return obj
end

