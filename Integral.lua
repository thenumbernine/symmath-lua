local class = require 'ext.class'
local Expression = require 'symmath.Expression'
local Integral = class(Expression)
Integral.name = 'Integral'

-- Integral:init(expr, var[, start, finish])
function Integral:expr() return self[1] end
function Integral:var() return self[2] end
function Integral:start() return self[3] end
function Integral:finish() return self[4] end

return Integral
