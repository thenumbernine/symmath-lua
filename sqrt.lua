require 'ext'
local Function = require 'symmath.function'
local Constant = require 'symmath.constant'
local diff = require 'symmath.diff'
local sqrt = class(Function)
sqrt.name = 'sqrt'
sqrt.func = math.sqrt
function sqrt:diff(...)
	local x = unpack(self.xs)
	return Constant(.5) * diff(x, ...) / sqrt(x)
end
return sqrt

