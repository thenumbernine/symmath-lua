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
	[unmOp] = function(self, expr)
		return self:apply(Constant(-1) * expr[1])
	end,
	
	[mulOp] = function(self, expr)
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
				return self:apply(expr)

			end
		end
	end,

	[subOp] = function(self, expr)
		--assert(#expr > 1) -- TODO
		if #expr == 1 then return self:apply(expr[1]) end

		if #expr == 2 then
			expr = expr[1] + -expr[2]
		else
			expr = expr[1] + -addOp(table.unpack(expr[2]))
		end
		return self:apply(expr)
	end,

	-- this isn't here because factoring isnt fully implmented yet
	--[[ so until then I'll make it its own function ...
	[powOp] = function(self, expr)
		-- for certain small integer powers, expand 
		-- ... or should we have all integer powers expended under a different command?
		if expr[2]:isa(Constant)
		and expr[2].value >= 0
		and expr[2].value < 10
		and expr[2].value == math.floor(expr[2].value)
		then
			local result = Constant(1)
			for i=1,expr[2].value do
				result = result * expr[1]:clone()
			end
			return result:simplify()
		end
	end,
	--]]
}

return Expand

