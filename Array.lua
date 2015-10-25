--[[
n-dimensional array
basis of all vectors, matrices, tensors, etc
--]]

local class = require 'ext.class'
local Expression = require 'symmath.Expression'

local Array = class(Expression)
Array.name = 'Array'
Array.mulNonCommutative = true
Array.precedence = 10

--[[
valid ctors:
	Array(x1, x2, ..., xN)
	
	maybe this one too?
	Array{dim={dim1, dim2, ...}, values=function(i1, ..., in) ... end}}
--]]
function Array:init(...)
	Array.super.init(self, ...)
			
	for i=1,#self do
		local x = self[i]
		assert(type(x) == 'table', "arrays can only be constructed with Expressions or tables of Expressions") 
		if not (x.isa and x:isa(Expression)) then
			-- then assume it's meant to be a sub-array
			x = Array(table.unpack(x))
			self[i] = x
		end
	end
end

Array.__index = function(self, key)
	-- parent class access
	local metavalue = getmetatable(self)[key]
	if metavalue then return metavalue end

	-- get a nested element
	if type(key) == 'table' then
		return self:get(key)
	end

	-- self class access
	return rawget(self, key)
end

Array.__newindex = function(self, key, value)
	
	-- I don't think I do much assignment-by-table ...
	--  except for in the Visitor.lookupTable ...
	-- otherwise, looks like it's not allowed in Arrays, where I've overridden it to be the setter
	if type(key) == 'table' then
		self:set(key, value)
		return
	end

	rawset(self, key, value)
end

function Array:get(index)
	local x = self
	for i=1,#index do
		if not x then error("tried to index too deeply into array "..tostring(self).." with "..table(table.unpack(index)):concat', ') end
		x = x[index[i]]
	end
	return x
end

function Array:set(index, value)
	local x = self
	for i=1,#index-1 do
		x = x[index[i]]
	end
	x[index[#index]] = value
	-- TODO return the old, for functionality?
	-- or just ignore it, since this is predominantly the implementation of __newindex, which has no return type?
end

-- returns a for loop iterator that cycles across all indexes and values within the array
-- usage: for index,value in t:iter() do ... end
-- where #index == t:rank() and contains elements 1 <= index[i] <= t:dim()[i]
function Array:iter()
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
				if index[i] <= dim[i].value then break end
				index[i] = 1
				if i == n then return end
			end
		end
	end)
end

-- calculated rank was a great idea, except when the Array is dynamically constructed
function Array:rank()
	-- note to self: empty Array objects means no way of representing empty rank>1 objects 
	-- ... which means special case of type assertion of the determinant being always rank-2 (except for empty matrices)
	-- ... unless I also introduce "shallow" arrays vs "deep" arrays ... "shallow" being represented only by their indices and contra-/co-variance (and "deep" being these)
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
		error("I found an array as an element within an array.  At the moment I don't allow mixed-rank elements in arrays.  I might lighten up on this later.\nminRank: "..minRank.." maxRank: "..maxRank)
	end

	return minRank + 1
end

function Array:dim()
	local Constant = require 'symmath.Constant'
	
	local dim = Array()
	
	-- if we have no children then we can't tell any info of rank
	if #self == 0 then return dim end

	local rank = self:rank()
	if rank == 1 then
		dim[1] = Constant(#self)
		return dim
	end

	-- get first child's dim
	local subdim_1 = Array.dim(self[1])

	assert(#subdim_1 == rank-1, "array has subarray with inequal rank")

	-- make sure they're equal for all children
	for j=2,#self do
		local subdim_j = Array.dim(self[j])
		assert(#subdim_j == rank-1, "array has subarray with inequal rank")
		
		for k=1,#subdim_1 do
			if subdim_1[k] ~= subdim_j[k] then
				error("array has subarray with inequal dimensions")
			end
		end
	end

	-- copy subrank into 
	for i=1,rank-1 do
		dim[i+1] = subdim_1[i]
	end
	dim[1] = Constant(#self)
	return dim
end

-- works like Expression.__eq except checks for Array subclass equality rather than strictly metatable equality
function Array.__eq(a,b)
	if not (type(a) == 'table' and a.isa and a:isa(Array)) then return false end
	if not (type(b) == 'table' and b.isa and b:isa(Array)) then return false end
	if a and b then
		if #a ~= #b then return false end
		for i=1,#a do
			if a[i] ~= b[i] then return false end
		end
		return true
	end
end

function Array.pruneAdd(a,b)
	if not Array.is(a) or not Array.is(b) then return end
	-- else array+scalar?  nah, too ambiguous.  are you asking for adding to all elements, or just the diagonals? idk.
	if #a ~= #b then return end
	local result = a:clone()
	for i=1,#result do
		result[i] = result[i] + b[i]
	end
	local prune = require 'symmath.prune'
	return prune(result)
end

-- TODO should all arrays perform matrix multiplciations?
--  or should only matrix/vectors?
-- should non-matrix arrays perform per-element scalar multiplications instead?  or none?
local function matrixMatrixMul(a,b)
	local adim = a:dim()
	local bdim = b:dim()
	if #adim ~= 2 or #bdim ~= 2 then return end	-- only support matrix/matrix multiplication
	local ah = adim[1].value
	local aw = adim[2].value
	local bh = bdim[1].value
	local bw = bdim[2].value
	if aw ~= bh then return end
	return require 'symmath.Matrix'(range(ah):map(function(i)
		return range(bw):map(function(j)
			local s
			for k=1,aw do
				if not s then
					s = a[i][k] * b[k][j]
				else
					s = s + a[i][k] * b[k][j]
				end
			end
			return s
		end)
	end):unpack())
end

-- TODO only map the elements of the array
-- TODO array getter, setter, and iterator
local function arrayScalarMul(m,s)
	local result = m:clone()
	for i=1,#result do
		result[i] = result[i] * s
	end
	local prune = require 'symmath.prune'
	return prune:apply(result)
end

local function scalarArrayMul(s,m)
	local result = m:clone()
	for i=1,#result do
		result[i] = s * result[i]
	end
	local prune = require 'symmath.prune'
	return prune(result)
end

function Array.pruneMul(lhs,rhs)
	local lhsIsArray = Array.is(lhs)
	local rhsIsArray = Array.is(rhs)
	assert(lhsIsArray or rhsIsArray)
	if lhsIsArray and rhsIsArray then
		return matrixMatrixMul(lhs, rhs)
	end

	-- matrix-scalar multiplication
	-- notice I'm not handling Matrix/Array multiplication.  
	-- My rule of thumb for now is "don't instanciate RowVectors -- instanciate nx1 Matrices instead"
	-- I'm sure that will change once I start introducing tensors.
	-- See the tests/alcubierre.lua file for thoughts on this.
	local result 
	if lhsIsArray then
		return arrayScalarMul(lhs, rhs)
	elseif rhsIsArray then
		return scalarArrayMul(lhs, rhs)
	end
end

return Array
