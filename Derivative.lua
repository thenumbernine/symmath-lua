require 'ext'

local Expression = require 'symmath.Expression'
local Constant = require 'symmath.Constant'
local Variable = require 'symmath.Variable'
local simplify = require 'symmath.simplify'
--[[
xs[1] is the expression
all subsequent xs's are variables
--]]
local Derivative = class(Expression)
Derivative.precedence = 4

function Derivative:init(...)
	local vars = table{...}
	local expr = assert(vars:remove(1), "can't differentiate nil")
	assert(#vars > 0, "can't differentiate against nil")
	for _,x in ipairs(vars) do
		assert(x and type(x) == 'table' and x.isa and x:isa(Variable), "diff() expected wrt expressions to be a variable")
	end
	vars:sort(function(a,b) return a.name < b.name end)
	Derivative.super.init(self, expr, unpack(vars))
end

function Derivative:eval()
	error("cannot evaluate derivatives.  try calling simplify() first")
end

return Derivative

