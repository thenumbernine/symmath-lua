local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Function = require 'symmath.Function'

local sin = class(Function)
sin.name = 'sin'
sin.realFunc = math.sin
sin.cplxFunc = require 'symmath.complex'.sin

function sin:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	local cos = require 'symmath.cos'
	return deriv(x, ...) * cos(x)
end

function sin:reverse(soln, index)
	return require 'symmath.asin'(soln)
end

function sin:getRealDomain()
	local RealDomain = require 'symmath.set.RealDomain'
	-- (-inf,inf) => (-1,1)
	local Is = self[1]:getRealDomain()
	if Is == nil then return nil end
	return RealDomain(table.mapi(Is, function(I)	
		if I.start == -math.huge or I.finish == math.huge then return RealDomain(-1, 1, true, true) end
		-- map by quadrant
		local startQ = math.floor(I.start / (math.pi/2))
		local finishQ = math.floor(I.finish / (math.pi/2))
		local startQmod4 = startQ % 4
		local finishQmod4 = finishQ % 4
		local behavior
		if startQ == finishQ then
			if startQmod4 == 0 or startQmod4 == 3 then
				behavior = 0	-- all inc
			elseif startQmod4 == 1 or startQmod4 == 2 then
				behavior = 1	-- all dec
			else
				error'here'
			end
		elseif startQ + 1 == finishQ then
			if startQmod4 == 3 then
				behavior = 0	-- all inc
			elseif startQmod4 == 0 then	
				behavior = 2	-- inc dec
			elseif startQmod4 == 1 then	-- so finishQmod4 == 2
				behavior = 1	-- all dec
			elseif startQmod4 == 2 then
				behavior = 3	-- dec inc
			else
				error'here'
			end
		elseif startQ + 2 == finishQ then
			if startQmod4 == 3 or startQmod4 == 0 then
				behavior = 2	-- inc dec
			elseif startQmod4 == 1 or startQmod4 == 2 then
				behavior = 3	-- dec inc
			else
				error'here'
			end
		elseif startQ + 3 >= finishQ then
			return RealDomain(-1, 1, true, true)
		end
		if behavior == 0 then
			-- all increasing
			return RealDomain(math.sin(I.start), math.sin(I.finish), I.includeStart, I.includeFinish)
		elseif behavior == 1 then
			-- all decreasing
			return RealDomain(math.sin(I.finish), math.sin(I.start), I.includeFinish, I.includeStart)
		elseif behavior == 2 then
			-- increasing then decreasing
			return RealDomain(
				math.min(math.sin(I.start), math.sin(I.finish)), math.sin(math.pi/2),
				I.includeStart or I.includeFinish, true)	
		elseif behavior == 3 then
			-- decreasing then increasing
			return RealDomain(
				math.sin(3*math.pi/2), math.max(math.sin(I.start), math.sin(I.finish)),
				true, I.includeStart or I.includeFinish)
		else
			error'here'
		end
		return RealDomain(-1, 1, true, true)
	end))
end

sin.rules = {
	Prune = {
		{apply = function(prune, expr)
			local symmath = require 'symmath'
			local Constant = symmath.Constant
			local Variable = symmath.Variable
			local mul = symmath.op.mul
			local div = symmath.op.div
		
			local theta = expr[1]
			
			-- sin(pi) => 0
			if theta == symmath.pi then return Constant(0) end

			if Constant.is(theta) then
				-- sin(0) => 0
				if Constant.isValue(theta, 0) then return Constant(0) end
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
				if Constant.isValue(theta[2], 2) then
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
		end},
	},
}

return sin
