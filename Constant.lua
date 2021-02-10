local class = require 'ext.class'
local table = require 'ext.table'
local Expression = require 'symmath.Expression'
local complex = require 'symmath.complex'
local RealDomain 

--[[
what about complex numbers?
what about big integers?
what about infinite precision numbers?

I'll let .value hold whatever is essential to the constant - whatever class of constant it is.
--]]

local Constant = class(Expression)
Constant.precedence = 10	-- high since it can't have child nodes 
Constant.name = 'Constant'

-- [[ override 'new' operator and fall back on caching
-- saves 25% of time on the 'metric catalog' test
local cache = {}
local oldcall = getmetatable(Constant).__call
local mt = {}
function mt:__call(value, ...)
	if type(value) == 'number'		-- it could be a complex ...
	and value == math.floor(value)
	and value >= -100
	and value <= 100
	then
		local obj = cache[value]
		if obj == nil then 
			obj = oldcall(self, value, ...)
			cache[value] = obj
		end
		return obj
	else
		return oldcall(self, value, ...)
	end
end
setmetatable(Constant, mt)
--]]

--[[
value = value of your constant
symbol = override display of the constant (i.e. 'pi', 'e', etc)
--]]
function Constant:init(value, symbol)
	if type(value) ~= 'number'
	and not complex:isa(value)
	then
		error('tried to init constant with non-number type '..type(value)..' value '..tostring(value))
	end
	value = value * 1.0	-- convert from long to double
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

function Constant:getRealDomain()
	if self.cachedSet then return self.cachedSet end
	RealDomain = RealDomain or require 'symmath.set.RealDomain'
	
	if type(self.value) == 'number' then
		-- should a Constant's domain be the single value of the constant?
		self.cachedSet = RealDomain(self.value, self.value, true, true)
		return self.cachedSet
	end
	
	if complex:isa(self.value) then 
		if self.im ~= 0 then 
			self.cachedSet = nil
			return nil 
		end
		self.cachedSet = RealDomain(self.re, self.re, true, true)
		return self.cachedSet
	end
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

-- static method
-- Constant:isa(x) and x.value == value, combined
function Constant.isValue(x, value)
	return Constant:isa(x) and x.value == value
end

return Constant
