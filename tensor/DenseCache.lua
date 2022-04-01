--[[
cache of dense/component-tensors (Tensor).
used for associating TensorRef's with Tensors
which itself is used for Expression:makeDense()
--]]

local class = require 'ext.class'
local table = require 'ext.table'

local DenseCache = class()

function DenseCache:init()
	self.cache = table()
end

-- for Tensor.Ref x, returns associated Tensor
function DenseCache:get(x)
	local Tensor = require 'symmath.Tensor'
	local Variable = require 'symmath.Variable'

	assert(Tensor.Ref:isa(x) and Variable:isa(x[1]))
	
--printbr('dense tensor cache has', cachedDenseTensors:mapi(function(t) return t[1] end):mapi(tostring):concat';')
	local _, t = self.cache:find(nil, function(t)
		return Tensor.Ref.matchesIndexForm(t[1], x)
	end)
	if not t then return end
	return t[2], t[1]
end

--[[
add an entry for Tensor.Ref 'x' and Tensor 'dense'
--]]
function DenseCache:add(x, dense)
	self.cache:insert{x:clone(), dense}
end

return DenseCache
