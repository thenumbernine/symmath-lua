local class = require 'ext.class'
local RealInterval = require 'symmath.set.RealInterval'

local PositiveReal = class(RealInterval)

PositiveReal.start = 0
PositiveReal.includeStart = false

return PositiveReal
