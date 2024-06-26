--[[				
TODO maybe get rid of 'complex' in Constant
instead just let symmath.i be some special value
and then change element-within-set test to look for add(const, mul(i, const))
--]]
local table = require 'ext.table'
local Expression = require 'symmath.Expression'
local complex = require 'complex'
local bignumber = require 'bignumber'
local symmath

--[[
what about complex numbers?
what about big integers?
what about infinite precision numbers?

I'll let .value hold whatever is essential to the constant - whatever class of constant it is.
--]]

local Constant = Expression:subclass()
Constant.precedence = 10	-- high since it can't have child nodes
Constant.name = 'Constant'

-- helper function
function Constant.isNumber(x)
	return type(x) == 'number'
	or bignumber:isa(x)
end

-- [[ override 'new' operator and fall back on caching
-- saves 25% of time on the 'metric catalog' test
local cache = {}
local newmember = Constant.new
function Constant:new(value, ...)	-- 'self' is the class for calls to :new()
	if type(value) == 'number'		-- it could be a complex ...
	and value == math.floor(value)
	and value >= -100
	and value <= 100
	then
		local obj = cache[value]
		if obj == nil then
			obj = newmember(self, value, ...)
			cache[value] = obj
		end
		return obj
	else
		return newmember(self, value, ...)
	end
end
--]]

--[[
value = value of your constant
symbol = override display of the constant (i.e. 'pi', 'e', etc)
--]]
function Constant:init(value, symbol)
	if not bignumber:isa(value) then
		if type(value) ~= 'number'
		and not complex:isa(value)
		then
			error('tried to init constant with non-number type '..type(value)..' value '..tostring(value))
		end
		value = value * 1.0	-- convert from long to double
	end
-- [[ read/write original behavior:
	self.value = value
	self.symbol = symbol
-- ]]
--[[ read-only:
-- if I'm going to use cached objects then I had better prevent them from being modified
-- mind you, switching to cached objects without this saved 25% of the time taken
-- but this might slow us down a bit ...
-- if caching constants improved speed by 25%, this slows us down by 8%
	rawset(self, '__private', {
		value = value,
		symbol = symbol,
	})
	--local mt = setmetatable(table(Constant), nil)	-- preserve all the operators in Constant
	-- if self[k] exists then this won't get called, so keep 'self' empty
	--setmetatable(self, mt)
--]]
end
-- TODO it is tempting to make all Expressions read-only
-- then using nested sub-expressions (like ex=x^2 ex2=ex^2+ex+1) can be assured to be more safe
--  since nothing will be able to modify a repeated-child of one expression (ex) and cause unforseen side-effects to pop up elsewhere (in ex2)
-- TODO another tempting thing, just set self's mt __index to its private
--  and set private's mt __index to Constant
--  then there would be no pure lua function for __index (and it'd go a bit faster)
--  but then you'd still need to move all Constant's other metafuncs over to self's mt
--  so it might be ugly to implement.
--[[
function Constant:__index(k)
	local private = rawget(self, '__private')
	local v
	if private then	-- pre-init we do get metatable __index calls
		v = private[k]
		if v ~= nil then return v end
	end
	v = Constant[k]
	if v ~= nil then return v end
	return nil
end
function Constant:__newindex(k,v)
	error("Constant is read-only")
end
--]]

function Constant:clone()
	return Constant(self.value, self.symbol)
end

-- this won't be called if a Lua number is used ...
-- only when a Lua table is used
function Constant.match(a, b, matches)
	-- same as in Expression.match
	matches = matches or table()

	-- this will insert muls where necessary,
	-- so Constant(2):match(Constant(2)*Wildcard()) returns (1),
	-- and Constant(2):match(Constant(1)*Wildcard()) returns Constant(2)
	-- but doesn't implicitly factor
	-- or divide? TODO Constant(2):match(Constant(2)/Wildcard())
	if b.wildcardMatches then
		if not b:wildcardMatches(a, matches) then return false end
		return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
	end

	-- if either is a constant then get the value
	-- (which should not be an expression of its own)
	if Constant:isa(a) then a = a.value end
	if Constant:isa(b) then b = b.value end
	-- if it is an expression then it must not have been a constant
	-- so we can assume it differs
	if Expression:isa(a) or Expression:isa(b) then return false end
	-- if either is complex then convert the other to complex
	if complex:isa(a) or complex:isa(b) then
		return complex.__eq(a,b)
	end

	-- by here they both should be numbers
	if a ~= b then return false end

	-- same as return true in Expression.match
	return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
end

function Constant.__eq(a,b)
	-- if either is a constant then get the value
	-- (which should not be an expression of its own)
	if Constant:isa(a) then a = a.value end
	if Constant:isa(b) then b = b.value end
	-- if it is an expression then it must not have been a constant
	-- so we can assume it differs
	if Expression:isa(a) or Expression:isa(b) then return false end
	-- if either is complex then convert the other to complex
	if complex:isa(a) or complex:isa(b) then
		return complex.__eq(a,b)
	end

	-- by here they both should be numbers
	return a == b
end

function Constant:evaluateDerivative(deriv, ...)
	return Constant(0)
end

function Constant:getRealRange()
	if self.cachedSet then return self.cachedSet end

	symmath = symmath or require 'symmath'
	local RealSubset = symmath.set.RealSubset

	if type(self.value) == 'number' then
		-- should a Constant's domain be the single value of the constant?
		self.cachedSet = RealSubset(self.value, self.value, true, true)
		return self.cachedSet
	end

	if complex:isa(self.value) then
		if self.im ~= 0 then
			self.cachedSet = nil
			return nil
		end
		self.cachedSet = RealSubset(self.re, self.re, true, true)
		return self.cachedSet
	end
end

-- static method
-- Constant:isa(x) and x.value == value, combined
function Constant.isValue(x, value)
	if not Constant:isa(x) then return false end
	if bignumber:isa(x.value) or bignumber:isa(value) then
		return bignumber(x.value) == bignumber(value)
	else
		return x.value == value
	end
end

-- lim x->a c => c
function Constant:evaluateLimit(x, a, side)
	return self
end

Constant.rules = {
	Tidy = {
		{apply = function(tidy, expr)
			if bignumber:isa(expr.value) then
				if expr.value:isZero() then
					return Constant(bignumber(0))
				end
			
				if expr.value < 0 then
					return tidy:apply(-Constant(-expr.value))
				end
			else
				-- for formatting's sake ...
				if expr.value == 0 then	-- which could possibly be -0 ...
					return Constant(0)
				end

				-- (-c) => -(c)
				if complex.unpack(expr.value) < 0 then
					return tidy:apply(-Constant(-expr.value))
				end
			end
		end},
	},
}

return Constant
