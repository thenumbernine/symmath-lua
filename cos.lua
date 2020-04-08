local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Function = require 'symmath.Function'

local cos = class(Function)

cos.name = 'cos'
cos.realFunc = math.cos
cos.cplxFunc = require 'symmath.complex'.cos

function cos:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	local sin = require 'symmath.sin'
	return -deriv(x,...) * sin(x)
end

function cos:reverse(soln, index)
	return require 'symmath.acos'(soln)
end

cos.rules = {
	Prune = {
		{apply = function(prune, expr)
			local symmath = require 'symmath'
			local Constant = symmath.Constant
			local Variable = symmath.Variable
			local mul = symmath.op.mul
			local div = symmath.op.div
		
			local theta = expr[1]
				
			-- cos(pi) => -1
			if theta == symmath.pi then return Constant(-1) end

			if Constant.is(theta) then
				-- cos(0) => 1
				if theta == Constant(0) then return Constant(1) end
			elseif mul.is(theta) then
				if #theta == 2 
				and theta[2] == symmath.pi 
				then
					-- cos(k * pi) for even k => 1
					if require 'symmath.set.EvenInteger':contains(theta[1]) then return Constant(1) end
					-- cos(k * pi) for odd k => -1
					if require 'symmath.set.OddInteger':contains(theta[1]) then return Constant(-1) end
				end
			
				-- cos(-c x y z) => cos(c x y z)
				if Constant.is(theta[1])
				and theta[1].value < 0
				then
					local mulArgs = range(#theta):map(function(i)
						return theta[i]:clone()
					end)
					local c = -mulArgs:remove(1).value
					local rest = #mulArgs == 1 and mulArgs[1] or mul(mulArgs:unpack()) 
					return prune:apply(c == 1 and cos(rest) or cos(c * rest))
				end
			elseif div.is(theta) then
				if theta[2] == Constant(2) then
					-- cos(pi / 2) => 0
					if theta[1] == symmath.pi then return Constant(0) end
					-- cos((k * pi) / 2) for odd k => 0
					if mul.is(theta[1])
					and #theta[1] == 2
					and require 'symmath.set.OddInteger':contains(theta[1][1])
					and theta[1][2] == symmath.pi
					then
						return Constant(0)
					end
				end
			end
		end},
	},
}

return cos
