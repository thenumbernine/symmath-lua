-- TensorIndex represents an entry in the Tensor.variance list
local class = require 'ext.class'
local table = require 'ext.table'
local Expression = require 'symmath.Expression'


local TensorIndex = class(Expression)

TensorIndex.name = 'TensorIndex'

function TensorIndex:init(args)
	self.lower = args.lower or false
	self.derivative = args.derivative
	self.symbol = args.symbol
	assert(type(self.symbol) == 'string' or type(self.symbol) == 'number' or type(self.symbol) == 'nil')
end

function TensorIndex.clone(...)
	return TensorIndex(...)	-- convert our type(x) from 'table' to 'function'
end


-- TODO what about wildcards for specific upper or lowre?
-- I guess I would need to make a Wildcard subclass for that, and have it instanciated by special string indexes like x' ^$1 _$2' etc
function TensorIndex.match(a, b, matches)
	matches = matches or table()
	if b.wildcardMatches then
		if not b:wildcardMatches(a, matches) then return false end
		return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
	end
	if getmetatable(a) ~= getmetatable(b) then return false end
	
	if not (a.lower == b.lower
		and a.derivative == b.derivative
		and a.symbol == b.symbol
	) then
		return false
	end
	
	return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
end


-- TODO put this in each export/* like everything else?
function TensorIndex:__tostring()
	local s = ''
	if self.derivative == 'covariant' then
		s = ';' .. s
	elseif self.derivative then
		s = ',' .. s
	end
	if self.lower then s = '_' .. s else s = '^' .. s end
	if self.symbol then
		local name = self.symbol
		if type(name) == 'string' then
			local symmath = require 'symmath'
			if symmath.fixVariableNames then
				name = symmath.tostring:fixVariableName(name)
			end
		end
		return s .. name
	else
		error("TensorIndex expected a symbol or a number")
	end
end

return TensorIndex
