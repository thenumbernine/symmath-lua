--[[
base class for all symmath.tostring options
example usage:
symmath.tostring = require 'symmath.tostring.***' for *** any subclass of ToString

I made this before I made the symmath.Visitor parent class, so consider merging those.
--]]

require 'ext'
local Visitor = require 'symmath.singleton.Visitor'


-- Visitor...
--  (1) clones everything that passes through it (to prevent accidental/intentional in-place modifications)
--  (2) processes bottom-up (rather than ToString's top-down)
-- so until these can be unified/negotiated I'm keeping ToString separate

-- [[
local ToString = class()

function ToString:apply(expr, ...)
	if type(expr) ~= 'table' then return tostring(expr) end
	local lookup = expr.class
	-- traverse class parentwise til a key in the lookup table is found
	while lookup and not self.lookupTable[lookup] do
		lookup = lookup.super
	end
	if not lookup then error("expected to find a lookup for class named "..tostring(expr.name)) end
	return (self.lookupTable[lookup])(self, expr, ...)
end

-- separate the __call function to allow child classes to permute the final output without permuting intermediate results
-- this means internally classes should call self:apply() rather than self() to prevent extra intermediate permutations 
function ToString.__call(self, ...)
	return self:apply(...)
end
--]]

local function precedence(x)
	return x.precedence or 10
end

function ToString:testWrapStrOfChildWithParenthesis(parentNode, childIndex)
	local subOp = require 'symmath.subOp'
	if parentNode:isa(subOp) and childIndex > 1 then
		return precedence(parentNode[childIndex]) <= precedence(parentNode)
	else
		return precedence(parentNode[childIndex]) < precedence(parentNode)
	end
end

function ToString:wrapStrOfChildWithParenthesis(parentNode, childIndex)
	local node = parentNode[childIndex]
	
	-- tostring() needed to call MultiLine's conversion to tables ...
	--local s = tostring(node)
	local s = self:apply(node)
	
	if self:testWrapStrOfChildWithParenthesis(parentNode, childIndex) then
		s = '(' .. s .. ')'
	end
	return s
end

return ToString

