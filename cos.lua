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

function cos:getRealDomain()
	local RealDomain = require 'symmath.set.RealDomain'
	-- (-inf,inf) => (-1,1)
	local Is = self[1]:getRealDomain()
	if Is == nil then return nil end
	return RealDomain(table.mapi(Is, function(I)
		if I.start == -math.huge or I.finish == math.huge then return RealDomain(-1, 1, true, true) end
		-- here I'm going to add pi/2 and then just copy the sin:getRealDomain() code
		I.start = I.start + math.pi/2
		I.finish = I.finish + math.pi/2
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
					if require 'symmath.set.sets'.evenInteger:contains(theta[1]) then return Constant(1) end
					-- cos(k * pi) for odd k => -1
					if require 'symmath.set.sets'.oddInteger:contains(theta[1]) then return Constant(-1) end
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
					and require 'symmath.set.sets'.oddInteger:contains(theta[1][1])
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
