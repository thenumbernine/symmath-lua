local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'
local symmath

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

-- TODO technically this is the reals minus holes at {(n+1/2) pi, n in Z}
-- but I don't have any way to represent this yet
tan.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real

function tan:getRealRange()
	if self.cachedSet then return self.cachedSet end
	-- (-inf,inf) => (-inf,inf) increasing, periodic
	local Is = self[1]:getRealRange()
	if Is == nil then 
		self.cachedSet = nil
		return nil 
	end

	symmath = symmath or require 'symmath'
	local RealSubset = symmath.set.RealSubset
	
	self.cachedSet = RealSubset(table.mapi(Is, function(I)
		local startHalf = math.floor((I.start + math.pi) / (2 * math.pi))
		local finishHalf = math.floor((I.finish + math.pi) / (2 * math.pi))
		if startHalf == finishHalf then
			return RealSubset(self.realFunc(I.start), self.realFunc(I.finish), I.includeStart, I.includeFinish)
		end
		-- if we cross one period then we have to include the separate infinities
		if startHalf + 1 == finishHalf then
			return RealSubset{
				{-math.huge, self.realFunc(I.finish), false, I.includeFinish},
				{self.realFunc(I.start), math.huge, I.includeStart, false},
			}
		end
		-- if we span more than one period then we are covering the entire reals
		return RealSubset()
	end))
	return self.cachedSet
end

-- no need for evaluateLimit if we are immediately converting tan() to sin()/cos()
-- so instead you can find that code in op.div's evaluateLimit()

tan.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local sin = symmath.sin
			local cos = symmath.cos
			
			local th = expr[1]

			if th == symmath.inf 
			or th == Constant(-1) * symmath.inf
			then
				return symmath.invalid
			end

			return prune:apply(sin(th:clone()) / cos(th:clone()))
		end},
	},
}

return tan
