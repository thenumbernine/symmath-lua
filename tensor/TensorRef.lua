local class = require 'ext.class'
local Expression = require 'symmath.Expression'
local TensorRef = class(Expression)
TensorRef.name = 'TensorRef'
function TensorRef:init(tensor, ...)
	TensorRef.super.init(self, tensor, ...)
	
	-- not necessarily true, for comma derivatives of scalars/expressions
	--assert(Tensor.is(tensor))	

	-- make sure the rest of the arguments are tensor indexes
	local TensorIndex = require 'symmath.tensor.TensorIndex'
	for _,index in ipairs{...} do
		assert(TensorIndex.is(index))
	end
end

return TensorRef
