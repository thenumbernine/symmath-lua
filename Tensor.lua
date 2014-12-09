require 'ext'
local Expression = require 'symmath.Expression'

--[[
general-purpose rank-1 (successive nesting for rank-n) structure
to be used as vectors, vectors of them as matrices, etc ...
--]]
local Tensor = class(Expression)
Tensor.name = 'Tensor'
Tensor.mulNonCommutative = true
Tensor.precedence = 10

function Tensor:init(...)
	Tensor.super.init(self, ...)

	-- now that children are stored, construct them as lower-rank objects if the arguments were provided implicitly as metatable-less tables
	-- this way we know all children (a) are Tensors and have a ".rank" field, or (b) are non-Tensor Expressions and are rank-0 
	for i=1,#self do
		local x = self[i]
		assert(type(x) == 'table', "tensors can only be constructed with Expressions or tables of Expressions") 
		if not x.isa or not x:isa(Expression) then
			-- then assume it's meant to be a sub-tensor
			x = Tensor(unpack(x))
			self[i] = x
		end
	end
end

Tensor.__index = function(self, key)
	-- parent class access
	local metavalue = getmetatable(self)[key]
	if metavalue then return metavalue end

	-- get a nested element
	if type(key) == 'table' then
		return self:get(key)
	--elseif type(key) == 'string' then	-- TODO interpret index notation
	end

	-- self class access
	return rawget(self, key)
end

Tensor.__newindex = function(self, key, value)
	
	-- I don't think I do much assignment-by-table ...
	--  except for in the Visitor.lookupTable ...
	-- otherwise, looks like it's not allowed in Tensors, where I've overridden it to be the setter
	if type(key) == 'table' then
		self:set(key, value)
		return
	end

	rawset(self, key, value)
end

function Tensor:get(index)
	local x = self
	for i=1,#index do
		x = x[index[i]]
	end
	return x
end

function Tensor:set(index, value)
	local x = self
	for i=1,#index-1 do
		x = x[index[i]]
	end
	x[index[#index]] = value
	-- TODO return the old, for functionality?
	-- or just ignore it, since this is predominantly the implementation of __newindex, which has no return type?
end

-- returns a for loop iterator that cycles across all indexes and values within the tensor
-- usage: for index,value in t:iter() do ... end
-- where #index == t:rank() and contains elements 1 <= index[i] <= t:dim()[i]
function Tensor:iter()
	local dim = self:dim()
	local n = #dim
	
	local index = {}
	for i=1,n do
		index[i] = 1
	end
	
	return coroutine.wrap(function()
		while true do
			coroutine.yield(index, self:get(index))
			for i=1,n do
				index[i] = index[i] + 1
				if index[i] <= dim[i] then break end
				index[i] = 1
				if i == n then return end
			end
		end
	end)
end

-- calculated rank was a great idea, except when the Tensor is dynamically constructed
function Tensor:rank()
	-- note to self: empty Tensor objects means no way of representing empty rank>1 objects 
	-- ... which means special case of type assertion of the determinant being always rank-2 (except for empty matrices)
	-- ... unless I also introduce "shallow" tensors vs "deep" tensors ... "shallow" being represented only by their indices and contra-/co-variance (and "deep" being these)
	if #self == 0 then return 0 end

	-- hmm, how should we determine rank?
	local minRank, maxRank
	for i=1,#self do
		local rank = self[i].rank and self[i]:rank() or 0
		if i == 1 then
			minRank = rank
			maxRank = rank
		else
			minRank = math.min(minRank, rank)
			maxRank = math.max(maxRank, rank)
		end
	end
	if minRank ~= maxRank then
		error("At the moment I don't allow mixed-rank elements in tensors.  I might lighten up on this later.")
	end

	return minRank + 1
end

function Tensor:dim()
	local dim = Tensor()
	dim.rank = 1
	
	-- if we have no children then we can't tell any info of rank
	if #self == 0 then return dim end

	local rank = self:rank()
	if rank == 1 then
		dim[1] = #self
		return dim
	end

	-- get first child's dim
	local subdim_1 = Tensor.dim(self[1])

	assert(#subdim_1 == rank-1, "tensor has subtensor with inequal rank")

	-- make sure they're equal for all children
	for j=2,#self do
		local subdim_j = Tensor.dim(self[j])
		assert(#subdim_j == rank-1, "tensor has subtensor with inequal rank")
		
		for k=1,#subdim_1 do
			if subdim_1[k] ~= subdim_j[k] then
				error("tensor has subtensor with inequal dimensions")
			end
		end
	end

	-- copy subrank into 
	for i=1,rank-1 do
		dim[i+1] = subdim_1[i]
	end
	dim[1] = #self
	return dim
end

-- works like Expression.__eq except checks for Tensor subclass equality rather than strictly metatable equality
function Tensor.__eq(a,b)
	if not (type(a) == 'table' and a.isa and a:isa(Tensor)) then return false end
	if not (type(b) == 'table' and b.isa and b:isa(Tensor)) then return false end
	if a and b then
		if #a ~= #b then return false end
		for i=1,#a do
			if a[i] ~= b[i] then return false end
		end
		return true
	end
end

return Tensor

