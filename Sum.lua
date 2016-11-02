local class = require 'ext.class'
local Expression = require 'symmath.Expression'
local Sum = class(Expression)
Sum.name = 'Sum'

-- Sum:init(expr, var, start, finish)
function Sum:expr() return self[1] end
function Sum:var() return self[2] end
function Sum:start() return self[3] end
function Sum:finish() return self[4] end

return Sum
