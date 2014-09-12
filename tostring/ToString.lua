require 'ext'

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

function ToString:apply(expr, ...)
	if type(expr) ~= 'table' then return tostring(expr) end
	local lookup = expr.class
	-- traverse class parentwise til a key in the lookup table is found
	while lookup and not self.lookupTable[lookup] do
		lookup = lookup.super
	end
	if not lookup then error("expected to find a lookup") end
	return (self.lookupTable[lookup])(self, expr, ...)
end

-- separate the __call function to allow child classes to permute the final output without permuting intermediate results
-- this means internally classes should call self:apply() rather than self() to prevent extra intermediate permutations 
function ToString.__call(self, ...)
	return self:apply(...)
end

return function precedence(x)
	if x.precedence then return x.precedence end
	return 10
end

function ToString:testWrapStrWithParenthesis(node, parentNode)
	return precedence(node) < precedence(parentNode)
end

function ToString:wrapStrWithParenthesis(node, parentNode)
	-- tostring() needed to call MultiLine's conversion to tables ...
	--local s = tostring(node)
	local s = self:apply(node)
	
	if self:testWrapStrWithParenthesis(node, parentNode) then
		s = '(' .. s .. ')'
	end
	return s
end

return ToString

