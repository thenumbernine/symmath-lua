--[[
Rodrigues rotation formula:
--]]
return function(theta, n)
	local symmath = require 'symmath'
	local Matrix = symmath.Matrix
	local sin = symmath.sin
	local cos = symmath.cos
	local nx, ny, nz = table.unpack(n)
	local I = Matrix.identity(3)
	local K = Matrix({0, -nz, ny}, {nz, 0, -nx}, {-ny, nx, 0})
	local K2 = (K * K 
-- why did I have this here?
-- is this really all that's needed if 'n' isn't normalized?
		+ I * (nx^2 + ny^2 + nz^2 - 1)
	)()
	return (I
		+ K * sin(theta)
		+ K2 * (1 - cos(theta))
	)()
end
