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

--[[
value = value of your constant
symbol = override display of the constant (i.e. 'pi', 'e', etc)
--]]
function Constant:init(value, symbol)
	if type(value) ~= 'number'
	and not complex.is(value)
	then
		error('tried to init constant with non-number type '..type(value)..' value '..tostring(value))
	end
	self.value = value * 1.0	-- convert from long to double
	self.symbol = symbol
end

function Constant:clone()
	return Constant(self.value, self.symbol)
end

-- this won't be called if a Lua number is used ...
-- only when a Lua table is used
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

function Constant:evaluateDerivative(deriv, ...)
	return Constant(0)
end

Constant.rules = {
	Eval = {
		{apply = function(eval, expr)
			return expr.value
		end},
	},

	Tidy = {
		{apply = function(tidy, expr)
			-- for formatting's sake ...
			if expr.value == 0 then	-- which could possibly be -0 ...
				return Constant(0)
			end
			
			-- (-c) => -(c)
			if complex.unpack(expr.value) < 0 then
				return tidy:apply(-Constant(-expr.value))
			end
		end},
	},
}

return Constant
