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


-- put some constants here as static members
local Variable = require 'symmath.Variable'
Constant.e = Variable('e', nil, math.exp(1))
Constant.pi = Variable('\\pi', nil, math.pi)
Constant.inf = Variable('\\infty', nil, math.huge)

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

-- this won't be called if a prim is used ...
function Constant.__eq(a,b)
	-- if either is a constant then get the value 
	-- (which should not be an expression of its own)
	if Constant.is(a) then a = a.value end
	if Constant.is(b) then b = b.value end
	-- if it is an expression then it must not have been a constant
	-- so we can assume it differs
	if Expression.is(a) or Expression.is(b) then return false end
	-- if either is complex then convert the other to complex
	if complex.is(a) or complex.is(b) then
		return complex.__eq(a,b)
	end
	-- by here they both should be numbers
	return a == b
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

-- helper

function Constant.isInteger(x)
	return Constant.is(x)
	and x.value == math.floor(x.value)
end

function Constant.isEven(x)
	return Constant.is(x)
	and x.value / 2 == math.floor(x.value / 2)
end

function Constant.isOdd(x)
	return Constant.is(x)
	and (x.value + 1) / 2 == math.floor((x.value + 1) / 2)
end

return Constant
