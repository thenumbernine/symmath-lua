require 'ext'

local Expression = require 'symmath.Expression'
local Constant = require 'symmath.Constant'

local Variable = class(Expression)
Variable.precedence = 10	-- high since it will never have nested members 
Variable.name = 'Variable'
variable = Variable	-- shorthand / case convention

function Variable:init(name, value, deferDiff)
	self.name = name
	if not (type(value) == 'number' or type(value) == 'nil') then
		error("got a bad value "..tostring(value))
	end
	self.value = value
	self.deferDiff = deferDiff
end

function Variable:clone()
	return Variable(self.name, self.value, self.deferDiff)
end

function Variable:diff(...)
	local diffs = table{...}
	if #diffs == 1 and diffs[1] == self then
		return Constant(1)
	end
	if self.deferDiff then
		-- deferDiff is set
		-- we know we have more than one diffs
		-- and one of them is 1 ... so d/danything[1] = 0
		if diffs:find(self) then return Constant(0) end
		return Derivative(self, ...)	-- preserve
	end
	return Constant(0)
end

function Variable:eval()
	local v = tonumber(self.value)
	if not v then
		error("tried to evaluate a variable "..self.." without a value set")
	end
	return v
end

function Variable.__eq(a,b)
	if getmetatable(a) ~= getmetatable(b) then return false end
	return a.name == b.name
end

return Variable

