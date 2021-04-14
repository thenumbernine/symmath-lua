--[=[ 2D
--[[
Rodrigues rotation formula.
Assumes |n| = 1
--]]
return function(theta, n)
	local symmath = require 'symmath'
	local Matrix = symmath.Matrix
	local sin = symmath.sin
	local cos = symmath.cos
	local nx, ny, nz = table.unpack(n)
	local I = Matrix.identity(3)
	-- K_ij = -ε_ijk n^k
	local K = Matrix({0, -nz, ny}, {nz, 0, -nx}, {-ny, nx, 0})
	-- K2_ij = K_ik K_kj = ε_ikl n^l ε_lmj n^m
	-- = (δ_im δ_kj - δ_ij δ_km) n^l n^m
	local K2 = (K * K 
-- this is here because the formula otherwise has an (1 - |n|^2) in it		
		+ I * (nx^2 + ny^2 + nz^2 - 1)
	)()
	-- I + K sin(θ) + K2 (1 - cos(θ))
	-- = δ_ij - sin(θ) ε_ijk n^k + (1 - cos(θ)) (δ_im δ_kj - δ_ij δ_km) n^l n^m
	return (I
		+ K * sin(theta)
		+ K2 * (1 - cos(theta))
	)()
end
--]=]

-- [=[
--[[
Rodrigues rotation formula, generalized to n-dimensions:
Assumes |n_i| = 1
--]]
return function(theta, ...)
	local symmath = require 'symmath'
	local Array = symmath.Array
	local Matrix = symmath.Matrix
	local Tensor = symmath.Tensor
	local sin = symmath.sin
	local cos = symmath.cos
	
	local ns = {...}
	local dim = #ns + 2
	for i=1,#ns do
		assert(#ns[i] == dim)
		ns[i] = Array(table.unpack(ns[i]))
	end
	local syms = table.sub(Tensor.defaultSymbols, 3, dim)
	
	local I = Matrix.identity(dim)
	-- K_ij = -ε_ijk..l * n1^k * ... * nN^l
	local eps = Tensor.LeviCivita(dim)
	local K = -1
	local epsIndexes = ''
	for i,n in ipairs(ns) do
		local sym = syms[i]
		local ni = Tensor('^'..sym, table.unpack(n))
		K = K * ni
		epsIndexes = epsIndexes .. sym
	end
	local i,j = table.unpack(Tensor.defaultSymbols, 1, 2)
	epsIndex = '_'..i..j..epsIndexes
	K = (K * eps(epsIndex))()
	assert(#K == dim and #K[1] == dim)
	K = Matrix(K:unpack())

	-- K2_ij = K_ik K_kj
	local K2 = (K * K)()
	
	if dim == 3 then
		-- only for 3D, replace the (1 - |n1|^2) with 0
		K2 = (K2 + Matrix:lambda({dim, dim}, function(i,j)
			return i <= 3 and i == j and 1 or 0
		end) * (ns[1]:normSq() - 1))()
	end

	-- I + K sin(θ) + K2 (1 - cos(θ))
	-- = δ_ij - sin(θ) ε_ijk n^k + (1 - cos(θ)) (δ_im δ_kj - δ_ij δ_km) n^l n^m
	return (I
		+ K * sin(theta)
		+ K2 * (1 - cos(theta))
	)()
end
--]=]
