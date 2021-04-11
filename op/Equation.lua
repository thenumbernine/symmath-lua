local class = require 'ext.class'
local table = require 'ext.table'
local Binary = require 'symmath.op.Binary'

-- equality
-- but subclasses are also inequalities
-- what's the term for operators that are either equalities or inequalities?
-- I would use binary operators for this, but Lua's overloading requires the return value be a boolean
local Equation = class(Binary)

-- TODO make this the same as op/add and op/mul
function Equation.match(a, b, matches)
	matches = matches or table()
	if b.wildcardMatches then
		if not b:wildcardMatches(a, matches) then return false end
		return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
	end	
	if getmetatable(a) ~= getmetatable(b) then return false end
	
	-- order-independent
	local a = table(a)
	local b = table(b)
	for ai=#a,1,-1 do
		-- table.find uses == uses __eq which ... should ... only pick bi if it is mulNonCommutative as well (crossing fingers, it's based on the equality implementation)
		--local bi = b:find(a[ai])
		local bi
		for _bi=1,#b do
			if b[_bi]:match(a[ai], matches) then
				bi = _bi
				break
			end
		end
		if bi then
			a:remove(ai)
			b:remove(bi)
		end
	end
	
	-- now compare what's left in-order (since it's non-commutative)
	local n = #a
	if n ~= #b then return false end
	for i=1,n do
		if not a[i]:match(b[i], matches) then return false end
	end
	
	return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
end

function Equation.__eq(a,b)
	if getmetatable(a) ~= getmetatable(b) then return false end
	
	-- order-independent
	local a = table(a)
	local b = table(b)
	for ai=#a,1,-1 do
		local bi
		for _bi=1,#b do
			if b[_bi] == a[ai] then
				bi = _bi
				break
			end
		end
		if bi then
			a:remove(ai)
			b:remove(bi)
		end
	end
	
	-- now compare what's left in-order (since it's non-commutative)
	local n = #a
	if n ~= #b then return false end
	for i=1,n do
		if a[i] ~= b[i] then return false end
	end
	
	return true
end

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

-- TODO how about using eval() ?
function Equation:isTrue()
	error'not implemented'
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
	local lhsIsArray = Array:isa(lhs)
	local rhsIsArray = Array:isa(rhs)
	if not lhsIsArray or not rhsIsArray then
		return table{lhs:eq(rhs)}
	end

	local ldim = lhs:dim()
	local rdim = rhs:dim()
	assert(#ldim == #rdim)
	for i=1,#ldim do
		assert(ldim[i] == rdim[i])
	end
	local Tensor = require 'symmath.Tensor'
	if Tensor:isa(lhs) and Tensor:isa(rhs) then
		rhs = rhs:permute(lhs.variance)
	end

	local results = table()
	for index in lhs:innerIter() do
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

-- TODO only do this on simplify()
-- [[
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
		if Equation:isa(a) and not Equation:isa(b) then
			a = a:clone()
			for i=1,#a do
				a[i] = op.f(a[i], b)
			end
			return a
		end
		if not Equation:isa(a) and Equation:isa(b) then
			b = b:clone()
			for i=1,#b do
				b[i] = op.f(a, b[i])
			end
			return b
		end
		if op.field == '__add' or op.field == '__sub' then
			if Equation:isa(a) and Equation:isa(b) then
				assert(#a == #b)
				a = a:clone()
				for i=1,#a do
					a[i] = op.f(a[i], b[i])
				end
				return a
			end
		end
	end
end
--]]

return Equation
