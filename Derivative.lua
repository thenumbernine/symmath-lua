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

function Derivative:distribute()
	if not (self.xs[1]:isa(Variable) and self.xs[1].deferDiff) then
		-- ... and if we're not lazy-evaluating the derivative of this with respect to other variables ...
		if not self.xs[1].diff then
			error("failed to differentiate "..tostring(self.xs[1]).." with type "..type(self.xs[1]))
		end
		return self.xs[1]:diff(unpack(self.xs, 2))
	end
	
	if self.xs[1]:isa(Variable) then
		-- deferred diff ... at least optimize out the dx/dx = 1
		if #self.xs == 2 
		and self.xs[1] == self.xs[2]
		then
			return Constant(1)
		end
	end
	
	return self:clone()
end

return Derivative

