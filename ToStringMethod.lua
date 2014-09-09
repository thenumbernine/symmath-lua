require 'ext'

local precedence = require 'symmath.precedence'

-- base class
local ToStringMethod = class()

function ToStringMethod:apply(expr, ...)
	if type(expr) ~= 'table' then return tostring(expr) end
	local lookup = expr.class
	if not lookup then return tostring(expr) end
	-- traverse class parentwise til a key in the lookup table is found
	while not self.lookupTable[lookup] do
		lookup = lookup.super
	end
	if not lookup then
		return tostring(expr)
	else
		return (self.lookupTable[lookup])(self, expr, ...)
	end
end

function ToStringMethod:testWrapStrWithParenthesis(node, parentNode)
	return precedence(node) < precedence(parentNode)
end

function ToStringMethod:wrapStrWithParenthesis(node, parentNode)
	local s = tostring(node)
	if self:testWrapStrWithParenthesis(node, parentNode) then
		s = '(' .. s .. ')'
	end
	return s
end

return ToStringMethod

