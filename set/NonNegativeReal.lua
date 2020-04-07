local class = require 'ext.class'
local RealInterval = require 'symmath.set.RealInterval'

local NonNegativeReal = class(RealInterval)

NonNegativeReal.start = 0

return NonNegativeReal
