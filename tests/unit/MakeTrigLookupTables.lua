#!/usr/bin/env lua
local table = require 'ext.table'
require 'symmath.setup'

local function intpow(a,b)
	local c = 1
	for i=1,b do
		c = c * a
	end
	return c
end

local function divides(p,q)
	for k=2,math.min(p,q)-1 do
		if p % k == 0 and q % k == 0 then return true end
	end
	return false
end

local costable = {
	[1] = {
		[1] = Constant(1),
	},
	[3] = {
		[1] = frac(1,2),
	},
	[5] = {
		[1] = (sqrt(5) + 1) / 4,					-- cos(π/5) = sin(3π/10)
		[2] = (sqrt(5) - 1) / 4,					-- cos(2π/5) = sin(π/10)
	},
}
local sintable = {
	[3] = {
		sqrt(3)/2,
	},
	[5] = {
		[1] = frac(1,4) * sqrt(10 - 2 * sqrt(5)),	-- sin(π/5) = cos(3π/10)
		[2] = frac(1,4) * sqrt(10 + 2 * sqrt(5)),	-- sin(2π/5) = cos(π/10)
	},
}

for q=2,10 do
	print('q='..q)
	if not (costable[q] and costable[q][1]) then
		-- sin(phi/2) = sqrt((1 - cos(phi)) / 2)
		-- cos(phi/2) = sqrt((1 + cos(phi)) / 2)
		local q_over_2 = q/2
		if q_over_2 == math.floor(q_over_2) then
			local costable_q_over_2 = assert(costable[q_over_2], "need costable for "..q_over_2)
			local cos_2_over_q = costable_q_over_2[1]
			local cos_1_over_q = sqrt((1 - cos_2_over_q) / 2)()
			local sin_1_over_q = sqrt((1 + cos_2_over_q) / 2)()
print(cos(pi / q):eq(cos_1_over_q))	
print()	
print(sin(pi / q):eq(sin_1_over_q))	
print()	
			costable[q] = costable[q] or {}
			costable[q][1] = cos_1_over_q 
			sintable[q] = sintable[q] or {}
			sintable[q][1] = sin_1_over_q 
		else
			local q_over_3 = q/3
			if q_over_3 == math.floor(q_over_3) then
				-- cos(3phi) + i sin(3 phi) = exp(3 i phi) = (cos(phi) + i sin(phi))^3 = (cos(phi) + i sin(phi)) (cos(2phi) + i sin(2phi))
				-- 
				-- (cos(phi) + i sin(phi))^3 = [cos(phi)^3 - 3 cos(phi) sin(phi)^2] + i [3 cos(phi)^2 sin(phi) - sin(phi)^3]
				-- = cos(phi) [cos(phi)^2 - 3 sin(phi)^2] + i sin(phi) [3 cos(phi)^2 - sin(phi)^2]
				-- = cos(phi) [cos(2phi) - 2 sin(phi)^2] + i sin(phi) [cos(2phi) + 2 cos(phi)^2]
				--
				-- cos(3phi) = cos(phi) [cos(phi)^2 - 3 sin(phi)^2]
				-- cos(3phi) = cos(phi) [4 cos(phi)^2 - 3]
				
			else
				print("don't know how to subdivide q="..q)
			end
		end
	end

	if costable[q] and costable[q][1] then
		local cos_1_over_q = costable[q][1]
		local sin_1_over_q = sintable[q][1]
		local cos_p_over_q = cos_1_over_q
		local sin_p_over_q = sin_1_over_q
		for p=2,q/2-.1 do
			cos_p_over_q, sin_p_over_q = (cos_1_over_q * cos_p_over_q - sin_1_over_q * sin_p_over_q)(), (cos_1_over_q * sin_p_over_q + sin_1_over_q * cos_p_over_q)()
print(cos(pi * p / q):eq(cos_p_over_q))	
print()	
print(sin(pi * p / q):eq(sin_p_over_q))	
print()	
			costable[q][p] = cos_p_over_q 
			sintable[q][p] = sin_p_over_q 
		end
	end
end
