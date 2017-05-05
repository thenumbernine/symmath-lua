local class = require 'ext.class'
local Expression = require 'symmath.Expression'

--[[
what about complex numbers?
what about big integers?
what about infinite precision numbers?

I'll let .value hold whatever is essential to the constant - whatever class of constant it is.
--]]

-- for now I'll allow value to be ffi.typeof(...) == 'ctype<complex>' or 'ctype<complex float>'
local result, ffi = pcall(require,'ffi')
ffi = result and ffi

local complex = require 'symmath.complex'

local Constant = class(Expression)
Constant.precedence = 10	-- high since it can't have child nodes 
Constant.name = 'Constant'

function Constant:init(value)
	if type(value) ~= 'number'
	and not complex.is(value)
	then
		error('tried to init constant with non-number type '..type(value)..' value '..tostring(value))
	end
	self.value = value
end

function Constant:clone()
	return Constant(self.value)
end

local function toConstant(a)
	if getmetatable(a) == Constant then return a.value end
	if complex.is(a) then return a end 
	return complex(a,0)
end

-- this won't be called if a prim is used ...
function Constant.__eq(a,b)
	return complex(toConstant(a)) == complex(toConstant(b))
end

function Constant:evaluateDerivative(...)
	return Constant(0)
end

Constant.visitorHandler = {
	Eval = function(eval, expr)
		return expr.value
	end,

	Tidy = function(tidy, expr)
		-- for formatting's sake ...
		if expr.value == 0 then	-- which could possibly be -0 ...
			return Constant(0)
		end
		
		-- (-c) => -(c)
		if complex.unpack(expr.value) < 0 then
			return tidy:apply(-Constant(-expr.value))
		end
	end,
}

return Constant
