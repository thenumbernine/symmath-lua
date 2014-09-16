require 'ext'
local Function = require 'symmath.Function'
local Constant = require 'symmath.Constant'
local sqrt = class(Function)
sqrt.name = 'sqrt'
sqrt.func = math.sqrt
function sqrt:diff(...)
	local x = unpack(self.xs)
	local diff = require 'symmath'.diff
	return Constant(.5) * diff(x, ...) / sqrt(x)
end
return sqrt

