local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Function = require 'symmath.Function'

local sin = class(Function)
sin.name = 'sin'
--sin.func = math.sin
sin.func = require 'symmath.complex'.sin

function sin:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local cos = require 'symmath.cos'
	local diff = require 'symmath.Derivative'
	return diff(x,...) * cos(x)
end

function sin:reverse(soln, index)
	return require 'symmath.asin'(soln)
end

sin.visitorHandler = {
	Prune = function(prune, expr)
		local symmath = require 'symmath'
		local Constant = symmath.Constant
		local Variable = symmath.Variable
		local mul = symmath.op.mul
		local div = symmath.op.div
	
		local theta = expr[1]

		if Constant.is(theta) then
			-- sin(0) => 0
			if theta == Constant(0) then return Constant(0) end
		elseif Variable.is(theta) then
			-- sin(pi) => 0
			if theta == symmath.pi then return Constant(0) end
		elseif mul.is(theta) then
			if #theta == 2 
			and theta[2] == symmath.pi 
			then
				-- sin(k * pi) => 0
				if Constant.is(theta[1]) then return Constant(0) end
			end
		
			-- sin(-c x y z) => -sin(c x y z)
			if Constant.is(theta[1])
			and theta[1].value < 0
			then
				local mulArgs = range(#theta):map(function(i)
					return theta[i]:clone()
				end)
				local c = -mulArgs:remove(1).value
				local rest = #mulArgs == 1 and mulArgs[1] or mul(mulArgs:unpack()) 
				return prune:apply(c == 1 and -sin(rest) or -sin(c * rest))
			end
		elseif div.is(theta) then
			if theta[2] == Constant(2) then
				-- sin(pi / 2) => 1
				if theta[1] == symmath.pi then return Constant(1) end
				if mul.is(theta[1])
				and #theta[1] == 2
				and Constant.is(theta[1][1])
				and theta[1][2] == symmath.pi
				then
					-- sin((k * pi) / 2) for 1,5,9,... k => 1
					if (theta[1][1].value - 1) / 4 == math.floor((theta[1][1].value - 1) / 4) then
						return Constant(1)
					-- sin((k * pi) / 2) for 3,7,11,... k => -1
					elseif (theta[1][1].value - 3) / 4 == math.floor((theta[1][1].value - 3) / 4) then
						return Constant(-1)
					end
				end
			end
		end
	end,
}

return sin
