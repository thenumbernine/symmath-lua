-- converts to add -> mul -> div

local Visitor = require 'symmath.visitor.Visitor'
local FactorDivision = Visitor:subclass()
FactorDivision.name = 'FactorDivision'

function FactorDivision:__call(expr, ...)
	-- convert to add -> div -> mul and simplify first ...
	expr = expr:distributeDivision()
	-- ... before applying the visitor
	return FactorDivision.super.__call(self, expr, ...)
end

return FactorDivision
