require 'ext'
local Expression = require 'symmath.Expression'
local Constant = require 'symmath.Constant'

local unmOp = class(Expression)
unmOp.precedence = 3	--4	--make it match mul and div so there aren't extra parenthesis around mul and div

function unmOp:evaluateDerivative(...)
	local x = unpack(self):clone()
	local diff = require 'symmath'.diff
	return -diff(x,...)
end

return unmOp

