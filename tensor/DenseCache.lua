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

-- returns the index of the cache with TensorRef x
function DenseCache:find(x)
	local Tensor = require 'symmath.Tensor'
	local Variable = require 'symmath.Variable'
	assert(Tensor.Ref:isa(x) and Variable:isa(x[1]))
	return self.cache:find(nil, function(t)
		return Tensor.Ref.matchesIndexForm(t[1], x)
	end)
end

-- for Tensor.Ref x, returns associated Tensor
function DenseCache:get(x)
	local _, t = self:find(x)
	if not t then return end
	return t[2], t[1]
end

--[[
add an entry for Tensor.Ref 'x' and Tensor 'dense'
--]]
function DenseCache:add(x, dense)
	-- remove old entries with matching valence
	while true do
		local i = self:find(x)
		if not i then break end
		self.cache:remove(i)
	end
	-- add new entry
	self.cache:insert{x:clone(), dense}
end

return DenseCache
