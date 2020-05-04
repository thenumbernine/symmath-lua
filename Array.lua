--[[
n-dimensional array
basis of all vectors, matrices, tensors, etc
--]]

local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local tolua = require 'ext.tolua'
local Expression = require 'symmath.Expression'

local Array = class(Expression)
Array.name = 'Array'
Array.mulNonCommutative = true
Array.precedence = 10

-- allow/expect `A[i][j] = whatever` expressions
Array.mutable = true

Array.unpack = table.unpack

--[[
valid ctors:
	Array(x1, x2, ..., xN)
	if you want to use a lambda constructor, check out Array:lambda
--]]
function Array:init(...)
	Array.super.init(self, ...)
			
	for i=1,#self do
		local x = self[i]
		assert(type(x) == 'table', "arrays can only be constructed with Expressions or tables of Expressions") 
		if not Expression.is(x) then
			-- then assume it's meant to be a sub-array
			x = Array(table.unpack(x))
			self[i] = x
		end
	end
end

-- using the Array constructor is slow, since it deep copies the contents
-- here's my alternative.  don't use this.  it's especially only for internal use.
-- use it as a static function, so 'Array:convertTable' or whatever subclass of Array
-- make sure you apply all nested tables (rows, etc) just as the constructor would when deep-copying.
function Array:convertTable(t)
	return setmetatable(t, self.class)
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
		if not x then error("tried to index too deeply into array "..tostring(self).." with "..table(index):concat', ') end
		x = x[index[i]]
	end
	return x
end

function Array:set(index, value)
	assert(#index > 0, "expected something in index but got an empty table: "..tolua(index))
	local x = self
	for i=1,#index-1 do
		x = x[index[i]]
	end
	x[index[#index]] = value
	-- TODO return the old, for functionality?
	-- or just ignore it, since this is predominantly the implementation of __newindex, which has no return type?
end

--[[
returns a for loop iterator that cycles across all indexes and values within the array
usage: for index,value in t:iter() do ... end
where #index == t:rank() and contains elements 1 <= index[i] <= t:dim()[i]
cycles the first indexes (outer-most arrays) first
--]]
function Array:iter()
	local dim = self:dim()
	local n = #dim
	if n == 0 then return coroutine.wrap(function() end) end

	local index = {}
	for i=1,n do
		index[i] = 1
	end
	
	return coroutine.wrap(function()
		while true do
			coroutine.yield(index, self:get(index))
			for i=n,1,-1 do
				index[i] = index[i] + 1
				if index[i] <= dim[i] then break end
				index[i] = 1
				if i == 1 then return end
			end
		end
	end)
end

-- same as above but cycles the last indexes (inner-most arrays) first
function Array:innerIter()
	local dim = self:dim()
	local n = #dim
	
	local index = {}
	for i=1,n do
		index[i] = 1
	end
	
	return coroutine.wrap(function()
		while true do
			coroutine.yield(index, self:get(index))
			for i=n,1,-1 do
				index[i] = index[i] + 1
				if index[i] <= dim[i] then break end
				index[i] = 1
				if i == 1 then return end
			end
		end
	end)
end


-- calculated rank was a great idea, except when the Array is dynamically constructed
-- TODO, 'rank' refers to another property, so consider renaming this to 'order' or 'degree'
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

--[[
Why does :dim() return symmath.Constant instead of lua number?
Right now it must be a fixed size
Maybe in the future I will have 'shallow' Array objects with no internal value, 
but only external properties (rank, index, etc) from which I can perform index gymnastics.
In such a case, I would want to allow variable-dimension arrays:
	a = Matrix{name='a', dim={m,k}}
	print(a) => a in R^(m x k)
	b = Matrix{name='b', dim={k,n}}
	print(b) => b in R^(k x n)
	c = a * b
	print(c) => a in R^(m x k) * b in R^(k x n)
	print(c'_ij'()) => a_'ik' * b'_kj'
... maybe? who knows.
--]]
function Array:dim()
	local dim = table()
	
	if not Array.is(self) then return dim end

	local rankfunc = self.rank or Array.rank
	local rank = rankfunc(self)
	if rank == 1 then
		dim[1] = #self
		return dim
	end

	if #self == 0 then return table() end

	-- get first child's dim
	local subdim_1 = self[1]:dim()

	assert(#subdim_1 == rank-1, "array has subarray with inequal rank")

	-- make sure they're equal for all children
	for j=2,#self do
		local subdim_j = self[j]:dim()
		assert(#subdim_j == rank-1, "array has subarray with inequal rank")
		
		for k=1,#subdim_1 do
			if subdim_1[k] ~= subdim_j[k] then
				error("array has subarray with inequal dimensions: "
					..tostring(subdim_1)..' vs '..tostring(subdim_j))
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

-- works like Expression.__eq except checks for Array subclass equality rather than strictly metatable equality
function Array.__eq(a,b)
	if not Array.is(a) 
	or not Array.is(b) 
	then 
		return Array.super.__eq(a,b)
	end
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
-- how about do this like my matrix library? inner the last index of the left and the first index of the right.
local function matrixMatrixMul(a,b)
	local adim = a:dim()
	local bdim = b:dim()
	if #adim ~= 2 or #bdim ~= 2 then return end	-- only support matrix/matrix multiplication
	local ah = adim[1]
	local aw = adim[2]
	local bh = bdim[1]
	local bw = bdim[2]
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


-- creates an array of zeroes
-- static, uses :
function Array:zeros(dims)
	local Constant = require 'symmath.Constant'
	dims = range(#dims):map(function(i)
		local x = dims[i]
		if type(x) == 'number' then return x end
		if Constant.is(x) then return x.value end
		return x
	end)
	-- assert self is Array or a subclass of Array
	if #dims == 0 then return self() end
	return self(range(dims[1]):map(function()
		return #dims == 1 and 0 or self:zeros(table.sub(dims, 2))
	end):unpack())
end

-- create an Array from a function
-- static, but uses : (so I know what class is calling it)
function Array:lambda(dims, f)
	local clone = require 'symmath.clone'
	local m = self:zeros(dims)
	for i in m:iter() do
		m[i] = clone(f(table.unpack(i)))
	end
	return m
end

return Array
