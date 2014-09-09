require 'ext'
local Expression = require 'symmath.Expression'
local Constant = require 'symmath.Constant'
local diff = require 'symmath.diff'
local prune = require 'symmath.prune'
local expand = require 'symmath.expand'

local unmOp = class(Expression)
unmOp.precedence = 4

function unmOp:diff(...)
	local x = unpack(self.xs)
	--x = prune(x)
	return -diff(x,...)
end

function unmOp:eval()
	return -self.xs[1]:eval()
end

function unmOp:prune()
	return prune(Constant(-1) * self.xs[1])
end

function unmOp:expand()
	return expand(Constant(-1) * self.xs[1])
end

function unmOp:toVerboseStr()
	return 'unm('..self.xs[1]:toSingleLineStr()..')'
end

return unmOp

