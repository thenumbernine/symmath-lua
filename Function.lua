local class = require 'ext.class'
local Expression = require 'symmath.Expression'

local Function = class(Expression)
Function.precedence = 10	-- high since it will always show parenthesis
Function.name = 'Function'

return Function
