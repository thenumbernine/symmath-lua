local class = require 'ext.class'
local Function = require 'symmath.Function'

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
	-- (-inf,inf) => (-inf,inf) increasing, periodic
	local RealInterval = require 'symmath.set.RealInterval'
	local I = self[1]:getRealDomain()
	if I == nil then return nil end
	local startHalf = math.floor(I.start + math.pi, 2 * math.pi)
	local finishHalf = math.floor(I.finish + math.pi, 2 * math.pi)
	if startHalf == finishHalf then
		return RealInterval(self.realFunc(I.start), self.realFunc(I.finish), I.includeStart, I.includeFinish)
	end
	if startHalf + 1 == finishHalf then
		-- TODO return a disjoint interval from [I.finish, inf) union (-inf, I.start]
	end
	-- if we span more than one period then we are covering the entire reals
	return RealInterval(-math.huge, math.huge)
end

tan.rules = {
	Prune = {
		{apply = function(prune, expr)
			local sin = require 'symmath.sin'
			local cos = require 'symmath.cos'
			local th = expr[1]
			return prune:apply(sin(th:clone()) / cos(th:clone()))
		end},
	},
}

return tan
