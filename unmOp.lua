require 'ext'
local Expression = require 'symmath.Expression'
local Constant = require 'symmath.Constant'
local diff = require 'symmath.diff'
local expand = require 'symmath.expand'

local unmOp = class(Expression)
unmOp.precedence = 3	--4	--make it match mul and div so there aren't extra parenthesis around mul and div

function unmOp:diff(...)
	local x = unpack(self.xs)
	--x = prune(x)
	return -diff(x,...)
end

function unmOp:eval()
	return -self.xs[1]:eval()
end

function unmOp:expand()
	return expand(Constant(-1) * self.xs[1])
end

return unmOp

