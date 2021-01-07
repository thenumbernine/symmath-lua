-- TensorIndex represents an entry in the Tensor.variance list
local class = require 'ext.class'
local table = require 'ext.table'
local string = require 'ext.string'
local Expression = require 'symmath.Expression'


local TensorIndex = class(Expression)

TensorIndex.name = 'TensorIndex'

-- valid derivative symbols for parseIndexes
TensorIndex.derivativeSymbols = table{',', ';', '|'}

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
	if self.derivative then
		s = self.derivative .. s
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

--[[
helper function
static function

accepts tensor string with ^, _, a-z, 1-9 
returns table of the following fields for each index:
	- whether this index is contra- (upper) or co-(lower)-variant
	- whether this index is a variable, or a range of variables
	- whether there is a particular kind of derivative associated with this index?  (i.e. comma, semicolon, projection, etc?)

space separated for multi-char symbols/numbers
	However space-separated means you *must* provide upper/lower prefix before *each* symbol/number
	(TODO fix this)
	Also how to tell a multi-char symbol that has just a single symbol and doesn't require a space?
--]]
function TensorIndex.parseIndexes(indexes)
	local function handleTable(indexes)
		indexes = {table.unpack(indexes)}
		local derivative = nil
		for i=1,#indexes do
			if type(indexes[i]) == 'number' then
				indexes[i] = {
					symbol = indexes[i],
					derivative = derivative,
				}
			elseif type(indexes[i]) == 'table' and getmetatable(indexes[i]) == TensorIndex then
				indexes[i] = indexes[i]:clone()
			elseif type(indexes[i]) ~= 'string' then
				print("got an index that was not a number or string: "..type(indexes[i]))
			else
				local function removeIfFound(sym)
					local symIndex = indexes[i]:find(sym,1,true)
					if not symIndex then return false end
					indexes[i] = indexes[i]:sub(1,symIndex-1) .. indexes[i]:sub(symIndex+#sym)
					return true
				end
				-- if the expression is upper/lower..comma then switch order so comma is first
				
				for _,d in ipairs(TensorIndex.derivativeSymbols) do
					if removeIfFound(d) then 
						derivative = d 
						break
					end
				end
				
				local lower = not not removeIfFound('_')
				if removeIfFound('^') then
					--print('removing upper denotation from index table (it is default for tables of indices)')
				end
				-- if it has a '_' prefix then just leave it.  that'll be my denotation passed into TensorRepresentation
				if #indexes[i] == 0 then
					print('got an index without a symbol')
				end

				if removeIfFound'$' then
					indexes[i] = require 'symmath.Wildcard'{
						index = assert(tonumber(indexes[i])),
						tensorIndexLower = lower,
						tensorIndexDerivative = derivative,
					}
				elseif tonumber(indexes[i]) ~= nil then
					indexes[i] = TensorIndex{
						symbol = tonumber(indexes[i]),
						lower = lower,
						derivative = derivative,
					}
				else
					indexes[i] = TensorIndex{
						symbol = indexes[i],
						lower = lower,
						derivative = derivative,
					}
				end
			end
		end
		return indexes	
	end

	if type(indexes) == 'string' then
		local indexString = indexes
		-- space means multi-character
		if indexString:find(' ') then
			-- special exception for the first space used to tell the parser it is multi-char even without multiple symbols, so trim the string
			indexes = handleTable(string.split(string.trim(indexString),' '))
		else
			local lower
			local derivative = nil
			indexes = {}
			for i=1,#indexString do
				local ch = indexString:sub(i,i)
				if ch == '^' then
					lower = false 
				elseif ch == '_' then
					lower = true
				elseif TensorIndex.derivativeSymbols:find(ch) then
					derivative = ch
				else
					-- if the first index is a derivative the default to lower
					if #indexes == 0 and derivative and lower == nil then lower = true end
					-- otherwise default to upper
					if lower == nil then lower = false end

					if tonumber(ch) ~= nil then
						table.insert(indexes, TensorIndex{
							symbol = tonumber(ch),
							lower = lower,
							derivative = derivative,
						})
					else
						table.insert(indexes, TensorIndex{
							symbol = ch,
							lower = lower,
							derivative = derivative,
						})
					end
				end
			end
		end
	elseif type(indexes) == 'table' then
		indexes = handleTable(indexes)
	else
		error('indexes had unknown type: '..type(indexes))
	end
	
	for i,index in ipairs(indexes) do
		assert(index.symbol, "index missing symbol")
	end
	
	return indexes
end

return TensorIndex
