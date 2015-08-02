-- TensorIndex represents an entry in the Tensor.variance list

local TensorIndex = class()

TensorIndex.name = 'TensorIndex'

function TensorIndex:init(args)
	self.lower = args.lower or false
	self.derivative = args.derivative or false
	self.symbol = args.symbol
	assert(type(self.symbol) == 'string' or type(self.symbol) == 'nil')
	self.number = args.number
	assert(type(self.number) == 'number' or type(self.number) == 'nil')
end

function TensorIndex.clone(...)
	return TensorIndex(...)	-- convert our type(x) from 'table' to 'function'
end

function TensorIndex.__eq(a,b)
	return a.lower == b.lower
	and a.derivative == b.derivative
	and a.symbol == b.symbol
	and a.number == b.number
end

function TensorIndex:__tostring()
	local s = ''
	if self.derivative then s = ',' .. s end
	if self.lower then s = '_' .. s else s = '^' .. s end
	if self.symbol then
		return s .. self.symbol
	elseif self.number then
		return s .. self.number
	else
		error("TensorIndex expected a symbol or a number")
	end
end

function TensorIndex.__concat(a,b)
	return tostring(a) .. tostring(b)
end

return TensorIndex
