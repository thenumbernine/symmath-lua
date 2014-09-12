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
Derivative.precedence = 5

function Derivative:init(...)
	local ch = table{...}
	local y = ch:remove(1)
	for _,x in ipairs(ch) do
		assert(x and type(x) == 'table' and x.isa and x:isa(Variable), "diff() expected wrt expressions to be a variable")
	end
	ch:sort(function(a,b) return a.name < b.name end)
	Derivative.super.init(self, y, unpack(ch))
end

function Derivative:eval()
	error("cannot evaluate derivatives.  try calling simplify() first")
end

return Derivative

