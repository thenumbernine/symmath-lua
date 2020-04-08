local class = require 'ext.class'
local RealInterval = require 'symmath.set.RealInterval'

local NonPositiveReal = class(RealInterval)

NonPositiveReal.finish = 0
NonPositiveReal.includeFinish = true

return NonPositiveReal
