return function(obj, ...)
	if type(obj) == 'number' then
		local Constant = require 'symmath.Constant'
		return Constant(obj)
	end
	
	if type(obj) ~= 'table' then return obj end
	
	local Expression = require 'symmath.Expression'
	if Expression:isa(obj) then return obj:clone() end
	
	return obj
end

