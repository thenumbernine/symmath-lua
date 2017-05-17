local class = require 'ext.class'
local table = require 'ext.table'
local Binary = require 'symmath.op.Binary'

-- equality
-- I would use binary operators for this, but Lua's overloading requires the return value be a boolean
local Equation = class(Binary)
Equation.__eq = require 'symmath.nodeCommutativeEqual'
Equation.solve = require 'symmath.solve'

function Equation:evaluateDerivative(deriv, ...)
	local result = table()
	for i=1,#self do
		result[i] = deriv(self[i]:clone(), ...)
	end
	return getmetatable(self)(result:unpack())
end

function Equation:lhs() return self[1] end
function Equation:rhs() return self[2] end

-- a = b => b = a
-- should probably overload this for >= and <= to switch the sides
function Equation:switch()
	local a,b = table.unpack(self)
	return b:clone():eq(a:clone())
end

function Equation:isTrue()
	return self[1] == self[2]
end

function Equation:simplify()
	local expr = self:clone()
	expr[1] = expr[1]:simplify()
	expr[2] = expr[2]:simplify()
	return expr
end

-- convert from array equations to a table of equations
function Equation:unravel()
	local Array = require 'symmath.Array'
	local lhs, rhs = table.unpack(self)
	local lhsIsArray = Array.is(lhs)
	local rhsIsArray = Array.is(rhs)
	if not lhsIsArray or not rhsIsArray then
		return table{lhs:eq(rhs)}
	end

	assert(lhs:dim() == rhs:dim())

	local results = table()
	for index in lhs:iter() do
		results:insert(lhs[index]:eq(rhs[index]))
	end
	return results
end

-- cause operators to apply immdiately, and to apply to both sides

-- TODO switch equality sign for non-equals equation ops? same with scaling by negatives?
function Equation.__unm(a)
	a = a:clone()
	for i=1,#a do
		a[i] = -a[i]
	end
	return a
end

for _,op in ipairs{
	{field = '__add', f = function(a,b) return a + b end},
	{field = '__sub', f = function(a,b) return a - b end},
	{field = '__mul', f = function(a,b) return a * b end},
	{field = '__div', f = function(a,b) return a / b end},
	{field = '__pow', f = function(a,b) return a ^ b end},
	{field = '__mod', f = function(a,b) return a % b end},
} do
	Equation[op.field] = function(a,b)
		local Constant = require 'symmath.Constant'
		if type(a) == 'number' then a = Constant(a) end
		if type(b) == 'number' then b = Constant(b) end
		if Equation.is(a) and not Equation.is(b) then
			a = a:clone()
			for i=1,#a do
				a[i] = op.f(a[i], b)
			end
			return a
		end
		if not Equation.is(a) and Equation.is(b) then
			b = b:clone()
			for i=1,#b do
				b[i] = op.f(a, b[i])
			end
			return b
		end
	end
end

return Equation
