local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'

local Heaviside = class(Function)

Heaviside.name = 'Heaviside'
Heaviside.nameForExporterTable = {}
Heaviside.nameForExporterTable.LaTeX = '\\mathcal{H}'
Heaviside.code = 'function(x) return x >= 0 and 1 or 0 end'

function Heaviside:evaluateDerivative(deriv, ...)
	return require 'symmath.Constant'(0)
end

Heaviside.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real

function Heaviside:getRealRange()
	if self.cachedSet then return self.cachedSet end
	
	symmath = symmath or require 'symmath'
	local RealSubset = symmath.set.RealSubset
	
	local Is = self[1]:getRealRange()
	if Is == nil then 
		self.cachedSet = nil
		return nil 
	end

	-- if the input domain overlaps the negative reals then include {0}
	-- if the input domain overlaps the positive reals then include {1}
	local domain = table()
	if symmath.set.negativeReal:intersects(Is) then
		domain:insert(symmath.set.RealInterval(0, 0, true, true))
	end
	if symmath.set.positiveReal:intersects(Is) then
		domain:insert(symmath.set.RealInterval(1, 1, true, true))
	end
	self.cachedSet = symmath.set.RealSubset(domain)
	return self.cachedSet
end

function Heaviside:evaluateLimit(x, a, side)
	symmath = symmath or require 'symmath'
	local Limit = symmath.Limit
	local Side = Limit.Side
	local Constant = symmath.Constant

	local L = symmath.prune(Limit(self[1], x, a, side))
	if Constant.isValue(L, 0) then
		if side == Side.plus then return Constant(1) end
		if side == Side.minus then return Constant(0) end
		if side == Side.both then return symmath.invalid end
		error'got a bad limit side'
	end
	--[[ TODO get isTrue() to work
	if L:lt(0):isTrue() then return Constant(0) end
	if L:gt(0):isTrue() then return Constant(1) end
	--]]
	-- [[
	if symmath.set.negativeReal:contains(L) then return Constant(0) end
	if symmath.set.positiveReal:contains(L) then return Constant(1) end
	--]]
	-- here: lim x->a H(x) when a>0 is undetermined
	
	-- TODO only for L contained within the domain of H
	return Heaviside(L)
end

return Heaviside
