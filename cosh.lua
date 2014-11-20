require 'ext'
local Function = require 'symmath.Function'
local cosh = class(Function)
cosh.name = 'cosh'
cosh.func = math.cosh
function cosh:diff(...)
	local x = unpack(self.xs)
	local sinh = require 'symmath.sinh'
	local diff = require 'symmath'.diff
	return diff(x,...) * sinh(x)
end
return cosh

