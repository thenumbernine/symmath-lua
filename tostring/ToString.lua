require 'ext'

local precedence = require 'symmath.precedence'

-- base class
local ToString = class()

function ToString:apply(expr, ...)
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

function ToString:testWrapStrWithParenthesis(node, parentNode)
	return precedence(node) < precedence(parentNode)
end

function ToString:wrapStrWithParenthesis(node, parentNode)
	local s = tostring(node)
	if self:testWrapStrWithParenthesis(node, parentNode) then
		s = '(' .. s .. ')'
	end
	return s
end

return ToString

