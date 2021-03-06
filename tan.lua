local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath
local RealDomain

local tan = class(Function)
tan.name = 'tan'
tan.realFunc = math.tan
tan.cplxFunc = require 'symmath.complex'.tan

function tan:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	local cos = require 'symmath.cos'
	return deriv(x, ...) / cos(x)^2
end

function tan:reverse(soln, index)
	return require 'symmath.atan'(soln)
end

function tan:getRealDomain()
	if self.cachedSet then return self.cachedSet end
	-- (-inf,inf) => (-inf,inf) increasing, periodic
	local Is = self[1]:getRealDomain()
	if Is == nil then 
		self.cachedSet = nil
		return nil 
	end
	RealDomain = RealDomain or require 'symmath.set.RealDomain'
	self.cachedSet = RealDomain(table.mapi(Is, function(I)
		local startHalf = math.floor((I.start + math.pi) / (2 * math.pi))
		local finishHalf = math.floor((I.finish + math.pi) / (2 * math.pi))
		if startHalf == finishHalf then
			return RealDomain(self.realFunc(I.start), self.realFunc(I.finish), I.includeStart, I.includeFinish)
		end
		-- if we cross one period then we have to include the separate infinities
		if startHalf + 1 == finishHalf then
			return RealDomain{
				{-math.huge, self.realFunc(I.finish), false, I.includeFinish},
				{self.realFunc(I.start), math.huge, I.includeStart, false},
			}
		end
		-- if we span more than one period then we are covering the entire reals
		return RealDomain()
	end))
	return self.cachedSet
end

tan.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local sin = symmath.sin
			local cos = symmath.cos
			local th = expr[1]
			return prune:apply(sin(th:clone()) / cos(th:clone()))
		end},
	},
}

return tan
