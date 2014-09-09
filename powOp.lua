require 'ext'

local Constant = require 'symmath.Constant'
local BinaryOp = require 'symmath.BinaryOp'
local log = require 'symmath.log'
local diff = require 'symmath.diff'
local prune = require 'symmath.prune'

local powOp = class(BinaryOp)
powOp.omitSpace = true
powOp.precedence = 5
powOp.name = '^'

--[[
d/dx(a^b)
d/dx(exp(log(a^b)))
d/dx(exp(b*log(a)))
exp(b*log(a)) * d/dx[b*log(a)]
a^b * (db/dx * log(a) + b * d/dx[log(a)])
a^b * (db/dx * log(a) + da/dx * b / a)
--]]
function powOp:diff(...)
	local a, b = unpack(self.xs)
	local x = a ^ b * (diff(b, ...) * log(a) + diff(a, ...) * b / a)
--	x = prune(x)
	return x
end

function powOp:eval()
	local a, b = unpack(self.xs)
	return a:eval() ^ b:eval()
end

function powOp:prune()
	local mulOp = require 'symmath.mulOp'
	local symmath = require 'symmath'	-- for debug flags
	for i=1,#self.xs do
		self.xs[i] = prune(self.xs[i])
	end

	if symmath.simplifyConstantPowers then
		if self.xs[1]:isa(Constant) and self.xs[2]:isa(Constant) then
			return Constant(self.xs[1].value ^ self.xs[2].value)
		end
	end
	
	-- 1^a => 1
	if self.xs[1] == Constant(1) then return Constant(1) end
	
	-- (-1)^odd = -1, (-1)^even = 1
	if self.xs[1] == Constant(-1) and self.xs[2]:isa(Constant) then
		local powModTwo = self.xs[2].value % 2
		if powModTwo == 0 then return Constant(1) end
		if powModTwo == 1 then return Constant(-1) end
	end
	
	-- a^1 => a
	if self.xs[2] == Constant(1) then return prune(self.xs[1]) end
	
	-- a^0 => 1
	if self.xs[2] == Constant(0) then return Constant(1) end
	
	-- (a ^ b) ^ c => a ^ (b * c)
	if self.xs[1]:isa(powOp) then
		return prune(self.xs[1].xs[1] ^ (self.xs[1].xs[2] * self.xs[2]))
	end
	
	-- (a * b) ^ c => a^c * b^c
	if self.xs[1]:isa(mulOp) then
		return prune(mulOp(unpack(self.xs[1].xs:map(function(v) return v ^ self.xs[2] end))))
	end
	
	--[[ for simplification's sake ... (like -a => -1 * a)
	-- x^c => x*x*...*x (c times)
	if self.xs[2]:isa(Constant)
	and self.xs[2].value > 0 
	and self.xs[2].value == math.floor(self.xs[2].value)
	then
		local m = mulOp()
		for i=1,self.xs[2].value do
			m:insertChild( self.xs[1]:clone())
		end
		
		return prune(m)
	end
	--]]

	return self
end

function powOp:expand()
	local maxPowerExpand = 10
	if self.xs[2]:isa(Constant) then
		local value = self.xs[2].value
		local absValue = math.abs(value)
		if absValue < maxPowerExpand then
			local num, frac, div
			if value < 0 then
				div = true
				frac = math.ceil(value) - value
				num = -math.ceil(value)
			elseif value > 0 then
				frac = value - math.floor(value)
				num = math.floor(value)
			else
				return Constant(1)
			end
			local terms = table()
			for i=1,num do
				terms:insert(self.xs[1]:clone())
			end
			if frac ~= 0 then
				terms:insert(self.xs[1]:clone()^frac)
			end
			if div then
				return Constant(1)/mulOp(unpack(terms))
			else
				return mulOp(unpack(terms))
			end
		end
	end
	return self
end

return powOp

