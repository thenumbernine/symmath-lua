local class = require 'ext.class'
local unmOp = require 'symmath.unmOp'
local addOp = require 'symmath.addOp'
local subOp = require 'symmath.subOp'
local mulOp = require 'symmath.mulOp'
local powOp = require 'symmath.powOp'
local Constant = require 'symmath.Constant'
local Visitor = require 'symmath.visitor.Visitor'

local Expand = class(Visitor)
Expand.name = 'Expand'

Expand.lookupTable = {
	[unmOp] = function(expand, expr)
		return expand:apply(Constant(-1) * expr[1])
	end,
	
	[mulOp] = function(expand, expr)
		expr = expr:clone()
local original = expr:clone()
local symmath = require 'symmath'	
		
		--[[
		a * (b + c) * d * e becomes
		(a * b * d * e) + (a * c * d * e)
		--]]

		for i,x in ipairs(expr) do
			if x:isa(addOp) or x:isa(subOp) then
				local terms = table()
				for j,xch in ipairs(x) do
					local term = expr:clone()
					term[i] = xch:clone()
					terms:insert(term)
				end
				expr = getmetatable(x)(table.unpack(terms))
				return expand:apply(expr)

			end
		end
	end,

	[subOp] = function(expand, expr)
		return expand:apply(expr[1] + -addOp(table.unpack(expr, 2)))
	end,
}

return Expand

