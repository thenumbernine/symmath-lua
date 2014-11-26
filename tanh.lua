require 'ext'
local Function = require 'symmath.Function'
local tanh = class(Function)
tanh.name = 'tanh'
tanh.func = math.tanh
function tanh:diff(...)
	local x = unpack(self)
	local cosh = require 'symmath.cosh'
	local diff = require 'symmath'.diff
	return diff(x,...) / cosh(x)^2
end
return tanh

