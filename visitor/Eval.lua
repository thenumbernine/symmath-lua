local class = require 'ext.class'
local Visitor = require 'symmath.visitor.Visitor'
local Eval = class(Visitor)
Eval.name = 'Eval' 

function Eval:__call(expr, evalmap, ...)
	local symmath = require 'symmath'
	local Constant = symmath.Constant
	local Variable = symmath.Variable
	local complex = require 'symmath.complex'

	-- do the replaces based on the evalmap
	if evalmap then
		for k,v in pairs(evalmap) do
			if type(v) ~= 'number' and not complex:isa(v) then
				error("expected the values of the evaluation map to be numbers, but found "..tostring(k).." = ("..type(v)..")"..tostring(v))
			end
			if type(k) == 'table' then
				expr = expr:replace(k,Constant(v))
			elseif type(k) == 'string' then
				expr = symmath.map(expr, function(node)
					if not Variable:isa(node) or node.name ~= k then return end
					return Constant(v)
				end)
			end
		end
	end
	expr = symmath.simplify(expr)

	return self:apply(expr, ...)
end

return Eval
