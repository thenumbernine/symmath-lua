--[[
base class for all symmath.export options

usage with tostring serialization:
symmath.tostring = require 'symmath.export.***' for *** any subclass of Export

I made this before I made the symmath.Visitor parent class, so consider merging those.
--]]

local class = require 'ext.class'

--local Visitor = require 'symmath.visitor.Visitor'
-- Visitor...
--  (1) clones everything that passes through it (to prevent accidental/intentional in-place modifications)
--  (2) processes bottom-up (rather than Export's top-down)
-- so until these can be unified/negotiated I'm keeping Export separate

-- [[
local Export = class()

function Export:apply(expr, ...)
	if type(expr) ~= 'table' then return tostring(expr) end
	local lookup = expr.class
	-- traverse class parentwise til a key in the lookup table is found
	while lookup and not self.lookupTable[lookup] do
		lookup = lookup.super
	end
	if not lookup then 
		local tolua = require 'ext.tolua'
		error("in exporter "..self.name.." expected to find a lookup for class named "
			..tostring(getmetatable(expr).name)
				.." for expr\n"
-- can't do this if our class is MultiLine ... it'll be infinite recursion
--				..require 'symmath.export.MultiLine'(expr)..'\n'
				..require 'symmath.export.Verbose'(expr)..'\n'
				..tolua(expr)
			) 
	end
	return (self.lookupTable[lookup])(self, expr, ...)
end

-- separate the __call function to allow child classes to permute the final output without permuting intermediate results
-- this means internally classes should call self:apply() rather than self() to prevent extra intermediate permutations 
function Export.__call(self, ...)
	return self:apply(...)
end
--]]

local function precedence(x)
	return x.precedence or 10
end

function Export:testWrapStrOfChildWithParenthesis(parentNode, childIndex)
	local sub = require 'symmath.op.sub'
	if sub.is(parentNode) and childIndex > 1 then
		return precedence(parentNode[childIndex]) <= precedence(parentNode)
	else
		return precedence(parentNode[childIndex]) < precedence(parentNode)
	end
end

function Export:wrapStrOfChildWithParenthesis(parentNode, childIndex)
	local node = parentNode[childIndex]
	local s = self:apply(node)
	if self:testWrapStrOfChildWithParenthesis(parentNode, childIndex) then
		s = '(' .. s .. ')'
	end
	return s
end

function Export:fixVariableName(name) return name end

return Export
