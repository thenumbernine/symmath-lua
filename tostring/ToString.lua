require 'ext'

local precedence = require 'symmath.precedence'

-- base class
local ToString = class()

local function debugToString(t)
	if type(t) ~= 'table' then return tostring(t) end
	local m = getmetatable(t)
	setmetatable(t, nil)
	local s = tostring(t)
	setmetatable(t, m)
	return s
end

function ToString:__call(expr, ...)
	if type(expr) ~= 'table' then return tostring(expr) end
	local lookup = expr.class
	-- traverse class parentwise til a key in the lookup table is found
	while lookup and not self.lookupTable[lookup] do
		lookup = lookup.super
	end
	if not lookup then
		return toLua(expr)	-- ERROR
	end
	return (self.lookupTable[lookup])(self, expr, ...)
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

