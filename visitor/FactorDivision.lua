local class = require 'ext.class'
local Visitor = require 'symmath.visitor.Visitor'
local Constant = require 'symmath.Constant'
local unmOp = require 'symmath.unmOp'
local addOp = require 'symmath.addOp'
local subOp = require 'symmath.subOp'
local mulOp = require 'symmath.mulOp'
local divOp = require 'symmath.divOp'

local FactorDivision = class(Visitor)

-- converts to add -> mul -> div
FactorDivision .lookupTable = {
	[unmOp] = function(self, expr)
		return self:apply(Constant(-1) * expr[1])
	end,
	[mulOp] = function(self, expr)
		-- first time processing we want to simplify()
		--  to remove powers and divisions
		--expr = expr:simplify()
		-- but not recursively ... hmm ...
		
		-- flatten multiplications
		-- TODO this is also in Prune
		-- make Rules
		for i=#expr,1,-1 do
			local ch = expr[i]
			if ch:isa(mulOp) then
				table.remove(expr, i)
				for j=#ch,1,-1 do
					local chch = ch[j]
					table.insert(expr, i, chch)
				end
				return self:apply(expr)
			end
		end
		
		-- distribute multiplication
		-- TODO this is also in Expand
		-- make Rules
		for i,ch in ipairs(expr) do
			if ch:isa(addOp) or ch:isa(subOp) then
				local terms = table()
				for j,chch in ipairs(ch) do
					local term = expr:clone()
					term[i] = chch:clone()
					terms:insert(term)
				end
				expr = getmetatable(ch)(table.unpack(terms))
				return self:apply(expr)
			end
		end
	end,
	[divOp] = function(self, expr)
		if expr[1] == Constant(1) then return end
		return self:apply(expr[1] * (Constant(1)/expr[2]))
	end,
}

function FactorDivision:__call(expr, ...)
	-- convert to add -> div -> mul and simplify first ... 
	expr = expr:distributeDivision() 
	-- ... before applying the visitor
	return FactorDivision.super.__call(self, expr, ...)
end

return FactorDivision 
