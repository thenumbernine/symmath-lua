local class = require 'ext.class'
local RealInterval = require 'symmath.set.RealInterval'

local NegativeReal = class(RealInterval)

NegativeReal.finish = 0
NegativeReal.includeFinish = false

return NegativeReal
