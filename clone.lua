return function(obj, ...)
	local Constant = require 'symmath.Constant'
	if Constant.isNumber(obj) then
		return Constant(obj)
	end

	if type(obj) ~= 'table' then return obj end

	local Expression = require 'symmath.Expression'
	if Expression:isa(obj) then return obj:clone() end

	return obj
end
