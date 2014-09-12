-- composite for now
-- TODO rational simplification: merge all into one fraction
--   	factor out top and bottom
-- 		simplify accordingly
return function(x, ...)
	local expand = require 'symmath.expand'
	local prune = require 'symmath.prune'
	local factor = require 'symmath.factor'
	local tidy = require 'symmath.tidy'
	local lastx
	for iter=1,10 do	
		lastx = x
		x = expand(x, ...)
		x = prune(x, ...)
		--x = factor(x)
		--x = prune(x)
		do break end -- calling expand() again after this breaks things ...
		--if x == lastx then break end
	end
	x = tidy(x, ...)
	return x
end

