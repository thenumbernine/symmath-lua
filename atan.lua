local class = require 'ext.class'
local Function = require 'symmath.Function'
local symmath

local atan = class(Function)
atan.name = 'atan'
atan.realFunc = math.atan
atan.cplxFunc = require 'complex'.atan

function atan:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	return deriv(x, ...) / (1 + x^2)
end

function atan:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.tan(soln)
end

atan.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real

-- technically this is a Riemann surface, and the codomain repeats every pi
atan.getRealRange = require 'symmath.set.RealSubset'.getRealRange_inc

atan.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

atan.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			
			if expr[1] == symmath.inf then
				return symmath.pi / 2
			end
			
			if expr[1] == Constant(-1) * symmath.inf then
				return (Constant(-1) * symmath.pi) / 2
			end

--[[ TODO this should be on all Function's prune()'s
-- but in this case it is the reals
			if expr:getRealDomain():complement():open():contains(x) then
				return symmath.invalid
			end
--]]
		end},
	},
}

return atan
