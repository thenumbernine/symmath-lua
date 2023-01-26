-- hack for require'ing symmath within the construction of symmath's namespace without causing a require() infinite loop
-- so instead of require 'symmath', preferrable is require 'symmath.namespace'()
local namespace
return function(...)
	local old = namespace
	if select('#', ...) > 0 then
		namespace = ...
	end
	return old
end
