--[[
base class for all symmath.export options

usage with tostring serialization:
symmath.tostring = require 'symmath.export.***' for *** any subclass of Export

I made this before I made the symmath.Visitor parent class, so consider merging those.
--]]

local class = require 'ext.class'
local table = require 'ext.table'

--local Visitor = require 'symmath.visitor.Visitor'
-- Visitor...
--  (1) clones everything that passes through it (to prevent accidental/intentional in-place modifications)
--  (2) processes bottom-up (rather than Export's top-down)
-- so until these can be unified/negotiated I'm keeping Export separate

-- [[
local Export = class()

Export.name = 'Export'

Export.lookupTable = {

	-- default
	[require 'symmath.Expression'] = function(self, expr)
		return expr:nameForExporter(self)
			..'('
			..table.mapi(expr, function(x)
				return self:apply(x)
			end):concat', '
			..')'
	end,

	[require 'symmath.Invalid'] = function(self, expr)
		return expr:nameForExporter(self)
	end,

	[require 'symmath.Variable'] = function(self, expr)
		return expr:nameForExporter(self)
	end,

	[require 'symmath.Constant'] = function(self, expr)
		-- .symbol was a quick fix to give constants symbols ... keep it?
		-- TODO get rid of Constant.symbol.
		-- and just use Variable and Variable.value instead.
		local symbol = expr.symbol
		if symbol then
			local symmath = require 'symmath'
			if symmath.fixVariableNames then
				symbol = symmath.tostring:fixVariableName(symbol)
			end
			return symbol
		end

		local s = tostring(expr.value)

		if s:sub(-2) == '.0' then s = s:sub(1,-3) end

		if self.constantPeriodRequired
		and not s:find'e'
		and not s:find'%.'
		then
			s = s .. '.'
		end

		return s
	end,
}

function Export:applyForClass(lookup, expr, ...)
	-- traverse class parentwise til a key in the lookup table is found
	while lookup and not self.lookupTable[lookup] do
		lookup = lookup.super
	end
	if not lookup then
		local tolua = require 'ext.tolua'
		local mt = getmetatable(expr)
		error("in exporter "..self.name.." expected to find a lookup for "
			..(mt and ('class named '..tostring(mt.name)) or 'nil class')
				.." for expr\n"
-- can't do this if our class is MultiLine ... it'll be infinite recursion
--				..require 'symmath.export.MultiLine'(expr)..'\n'
-- still causes stack overflow
--				..require 'symmath.export.Verbose'(expr)..'\n'
				..tolua(expr)
			)
	end
	return (self.lookupTable[lookup])(self, expr, ...)
end

function Export:apply(expr, ...)
	if type(expr) ~= 'table' then return tostring(expr) end
	return self:applyForClass(expr.class, expr, ...)
end

-- separate the __call function to allow child classes to permute the final output without permuting intermediate results
-- this means internally classes should call self:apply() rather than self() to prevent extra intermediate permutations
function Export.__call(self, ...)
	return self:apply(...)
end
--]]

local function precedence(x)
	return x.precedence or 10
end

function Export:testWrapStrOfChildWithParenthesis(parent, child)
	--[[ hmm, can't do this if I'm using parent/child objects
	-- which I'm using because I've turned the sub's into add+unm's
	-- so maybe I won't need it?
	local sub = require 'symmath.op.sub'
	if sub:isa(parent) and child > 1 then
		return precedence(parent[child]) <= precedence(parent)
	else
		return precedence(parent[child]) < precedence(parent)
	end
	--]]
	-- [[
	return precedence(child) < precedence(parent)
	--]]
end

Export.parOpenSymbol = '('
Export.parCloseSymbol = ')'

function Export:wrapStrOfChildWithParenthesis(parent, child)
	local results = table.pack(self:apply(child))
	if self:testWrapStrOfChildWithParenthesis(parent, child) then
		results[1] = self.parOpenSymbol .. results[1] .. self.parCloseSymbol
	end
	return results:unpack()
end

function Export:fixVariableName(name) return name end



-- [==[ all this just to get uint8-capable bitwise _and_ working...
-- TODO looks like a job for lua-ext ...
local band
-- [=[ try the operator
do --if not band then
	local f, err = load[[return function(a,b) return a & b end]]
	if f then
--print'using operator'
		band = assert(f())
	end
end
--]=]
-- try global
for _,lib in ipairs{'bit', 'bit32'} do
	if _G[lib] then
--print('using global lib', lib)
		band = _G[lib].band
	end
end
-- try bit library
for _,lib in ipairs{'bit', 'bit32'} do
	if not band then
		local has, bit = pcall(require, lib)
		if has then
--print('using lib ', lib)
			band = bit.band
		end
	end
end
-- implement in vanilla old lua
if not band then
--print('using vanilla')
	band = function(a,b)
		local two = 2
		local res = 0
		for i=1,8 do
			local u = a % two
			local v = b % two
			if u ~= 0 and v ~= 0 then res = res + u end
			a = a - u
			b = b - v
			two = two * 2
		end
		return res
	end
end

--[[ verify
for i=0,255 do
	for j=0,255 do
		--io.write('\t',band(i,j))
		local a = band(i,j)
		local b = i & j
		assert(a == b, "failed for i="..i.." j="..j.." band(i,j)="..a.." i & j ="..b)
	end
	--print()
end
os.exit()
--]]
--]==]



-- I'm using utf8 length often enough,
-- and some builds like luajit don't always have it,
-- and I haven't found a pure lua library that I like enough to depend on yet,
-- so here's my own utf8 strlen:
function Export.strlen(s)
	assert(type(s) == 'string')
	local n = #s	-- raw len
	local len = 0
	local i = 1
	while i <= n do
		local b = s:byte(i)
		if band(b, 0x80) == 0 then	-- 0xxx:xxxx
		else
			local m
			if band(b, 0xe0) == 0xc0 then		-- 110x:xxxx
				m = 1
			elseif band(b, 0xf0) == 0xe0 then	-- 1110:xxxx
				m = 2
			elseif band(b, 0xf8) == 0xf0 then	-- 1111:0xxx
				m = 3
			else
				error'here'
			end
			for j=1,m do
				i = i + 1
				if band(s:byte(i), 0xc0) ~= 0x80 then
					error'here'
				end
			end
		end
		len = len + 1
		i = i + 1
	end
	return len
end

return Export
