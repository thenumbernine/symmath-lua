require 'ext'
local Expression = require 'symmath.Expression'

--[[
general-purpose rank-1 (successive nesting for rank-n) structure
to be used as vectors, vectors of them as matrices, etc ...
--]]
local Tensor = class(Expression)
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

	-- note to self: empty Tensor objects means no way of representing empty rank>1 objects 
	-- ... which means special case of type assertion of the determinant being always rank-2 (except for empty matrices)
	-- ... unless I also introduce "shallow" tensors vs "deep" tensors ... "shallow" being represented only by their indices and contra-/co-variance (and "deep" being these)
	if #self == 0 then return end

	-- hmm, how should we determine rank?
	local minRank, maxRank
	for i=1,#self do
		local rank = self[i].rank or 0
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

	self.rank = minRank + 1
end

function Tensor:dim()
	local dim = Tensor()
	dim.rank = 1
	
	-- if we have no children then we can't tell any info of rank
	if #self == 0 then return dim end

	if self.rank == 1 then
		dim[1] = #self
		return dim
	end

	-- get first child's dim
	local subdim_1 = Tensor.dim(self[1])

	assert(#subdim_1 == self.rank-1, "tensor has subtensor with inequal rank")

	-- make sure they're equal for all children
	for j=2,#self do
		local subdim_j = Tensor.dim(self[j])
		assert(#subdim_j == self.rank-1, "tensor has subtensor with inequal rank")
		
		for k=1,#subdim_1 do
			if subdim_1[k] ~= subdim_j[k] then
				error("tensor has subtensor with inequal dimensions")
			end
		end
	end

	-- copy subrank into 
	for i=1,self.rank-1 do
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

