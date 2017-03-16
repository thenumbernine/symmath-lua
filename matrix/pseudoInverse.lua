-- from https://en.wikipedia.org/wiki/Moore%E2%80%93Penrose_pseudoinverse
local function pseudoInverse(A)
	local AT = A:transpose()
	local APlus
	if #A > #A[1] then
		local ATA = (AT * A)():inverse()
		APlus = (ATA * AT)()
	else
		local AAT = (A * AT)():inverse()
		APlus = (AT * AAT)()
	end
	local APlusA = (APlus * A)()
	local determinable = APlusA == require 'symmath.matrix.identity'(#APlusA)
	return APlus, determinable
end

return pseudoInverse
