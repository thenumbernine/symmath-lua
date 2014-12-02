local unmOp = require 'symmath.unmOp'
local addOp = require 'symmath.addOp'
local subOp = require 'symmath.subOp'
local mulOp = require 'symmath.mulOp'
local divOp = require 'symmath.divOp'
local modOp = require 'symmath.modOp'
local powOp = require 'symmath.powOp'
local Constant = require 'symmath.Constant'
local Invalid = require 'symmath.Invalid'
local Function = require 'symmath.Function'
local Derivative = require 'symmath.Derivative'
local Variable = require 'symmath.Variable'
local Visitor = require 'symmath.singleton.Visitor'

local Eval = class(Visitor)

Eval.lookupTable = {
	[unmOp] = function(self, expr)
		return -self:apply(expr[1])
	end,

	[addOp] = function(self, expr)
		local result = 0
		for _,x in ipairs(expr) do
			result = result + self:apply(x)
		end
		return result
	end,
	
	[subOp] = function(self, expr)
		local result = self:apply(expr[1])
		for i=2,#expr do
			result = result - self:apply(expr[i])
		end
		return result
	end,

	[mulOp] = function(self, expr)
		local result = 1
		for _,x in ipairs(expr) do
			result = result * self:apply(x)
		end
		return result
	end,

	[divOp] = function(self, expr)
		local a, b = unpack(expr)
		return self:apply(a) / self:apply(b)
	end,
	
	[modOp] = function(self, expr)
		local a, b = unpack(expr)
		return self:apply(a) % self:apply(b)
	end,
	
	[powOp] = function(self, expr)
		local a, b = unpack(expr)
		return self:apply(a) ^ self:apply(b)
	end,

	[Constant] = function(self, expr)
		return expr.value
	end,
	
	[Invalid] = function(self, expr)
		return 0/0
	end,
	
	[Function] = function(self, expr)
		return expr.func(table.map(expr, function(node, k)
			if type(k) ~= 'number' then return end
			return self:apply(node)
		end):unpack())
	end,

	[Derivative] = function(self, expr)
		error("cannot evaluate derivative"..tostring(expr)..".  try replace()ing derivatives.")
	end,
	
	[Variable] = function(self, expr)
		error("Variable "..tostring(expr).." wasn't replace()'d with a constant during eval")
	end,
}

function Eval:__call(expr, evalmap, ...)
	local symmath = require 'symmath'
	-- do the replaces based on the evalmap
	if evalmap then
		for k,v in pairs(evalmap) do
			if type(v) ~= 'number' then
				error("expected the values of the evaluation map to be numbers, but found "..tostring(k).." = ("..type(v)..")"..tostring(v))
			end
			if type(k) == 'table' then
				expr = expr:replace(k,symmath.Constant(v))
			elseif type(k) == 'string' then
				expr = symmath.map(expr, function(node)
					if not node:isa(symmath.Variable) or node.name ~= k then return end
					return symmath.Constant(v)
				end)
			end
		end
	end
	expr = symmath.simplify(expr)

	return self:apply(expr, ...)
end

return Eval

