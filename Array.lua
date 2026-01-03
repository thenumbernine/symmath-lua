--[[
n-dimensional array
basis of all vectors, matrices, tensors, etc
--]]

local table = require 'ext.table'
local range = require 'ext.range'
local assert = require 'ext.assert'
local tolua = require 'ext.tolua'
local Expression = require 'symmath.Expression'
local symmath

local Array = Expression:subclass()
Array.name = 'Array'
Array.mulNonCommutative = true
Array.precedence = 10

-- allow/expect `A[i][j] = whatever` expressions
Array.mutable = true

Array.unpack = table.unpack

-- static method
function Array:fixctorargs(...)
	local n = select('#', ...)
	if n == 0 then return end
	local x = ...
	local mt = getmetatable(self)

	-- same as in Expression:init but for regular tables, wrap them with this class type
	local Constant = require 'symmath.Constant'
	if Constant.isNumber(x) then
		x = Constant(x)
	elseif not Expression:isa(x) then
		local prevmt = getmetatable(x)
		assert(prevmt == nil or prevmt == table)
		x = mt(table.unpack(x))
	end

	return x, self:fixctorargs(select(2, ...))
end

--[[
valid ctors:
	Array(x1, x2, ..., xN)
	if you want to use a lambda constructor, check out Array:lambda

TODO if I instead required a table constructor, it would make passing Arrays as arguments much easier
	as well as easier for subclasses (Matrix, Tensor, etc)
--]]
function Array:init(...)
	--[[ using tail-call I hope ... but in large matrices i'm getting stack overflow here ...
	Array.super.init(self, self:fixctorargs(...))
	--]]
	-- [[ not using tail-call, but allocating one extra table...
	local Constant = require 'symmath.Constant'
	local mt = getmetatable(self)
	local args = table.pack(...)
	for i=1,args.n do
		local x = args[i]
		-- same as in Expression:init but for regular tables, wrap them with this class type
		if Constant.isNumber(x) then
			x = Constant(x)
		elseif not Expression:isa(x) then
			local prevmt = getmetatable(x)
			assert(prevmt == nil or prevmt == table)
			x = mt(table.unpack(x))
		end
		args[i] = x
	end
	Array.super.init(self, args:unpack())
	--]]
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

-- too useful not to have here
-- dim = array of numbers to iterate across
-- TODO turn Array:iter() into something that just uses this?  or would that go too slow?
-- TODO put this in ext? because it's so useful?  I think matrix-lua has a similar loop inside of it.
function Array.iterForDim(dim)
	local n = #dim
	if n == 0 then return coroutine.wrap(function() end) end

	local index = {}
	for i=1,n do
		index[i] = 1
	end

	return coroutine.wrap(function()
		while true do
			coroutine.yield(index)
			for i=n,1,-1 do
				index[i] = index[i] + 1
				if index[i] <= dim[i] then break end
				index[i] = 1
				if i == 1 then return end
			end
		end
	end)
end

--[[
returns a for loop iterator that cycles across all indexes and values within the array
usage: for index,value in t:iter() do ... end
where #index == t:degree() and contains elements 1 <= index[i] <= t:dim()[i]
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


-- calculated degree was a great idea, except when the Array is dynamically constructed
function Array:degree()
	-- note to self: empty Array objects means no way of representing empty degree>1 objects
	-- ... which means special case of type assertion of the determinant being always degree-2 (except for empty matrices)
	-- ... unless I also introduce "shallow" arrays vs "deep" arrays ... "shallow" being represented only by their indices and contra-/co-variance (and "deep" being these)
	if #self == 0 then return 0 end

	-- hmm, how should we determine degree?
	local minDegree, maxDegree
	for i=1,#self do
		local degree = self[i].degree and self[i]:degree() or 0
		if i == 1 then
			minDegree = degree
			maxDegree = degree
		else
			minDegree = math.min(minDegree, degree)
			maxDegree = math.max(maxDegree, degree)
		end
	end
	if minDegree ~= maxDegree then
		error("I found an array as an element within an array.  At the moment I don't allow mixed-degree elements in arrays.  I might lighten up on this later.\nminRank: "..minDegree.." maxDegree: "..maxDegree)
	end

	return minDegree + 1
end

--[[
Why does :dim() return symmath.Constant instead of lua number?
Right now it must be a fixed size
Maybe in the future I will have 'shallow' Array objects with no internal value,
but only external properties (degree, index, etc) from which I can perform index gymnastics.
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

	if not Array:isa(self) then return dim end

	local degreeFunc = self.degree or Array.degree
	local degree = degreeFunc(self)
	if degree == 1 then
		dim[1] = #self
		return dim
	end

	if #self == 0 then return table() end

	-- get first child's dim
	local subdim_1 = self[1]:dim()

	assert(#subdim_1 == degree-1, "array has subarray with inequal degree")

	-- make sure they're equal for all children
	for j=2,#self do
		local subdim_j = self[j]:dim()
		assert(#subdim_j == degree-1, "array has subarray with inequal degree")

		for k=1,#subdim_1 do
			if subdim_1[k] ~= subdim_j[k] then
				error("array has subarray with inequal dimensions: "
					..tostring(subdim_1)..' vs '..tostring(subdim_j))
			end
		end
	end

	-- copy subrank into
	for i=1,degree-1 do
		dim[i+1] = subdim_1[i]
	end
	dim[1] = #self

	return dim
end

function Array.pruneAdd(a,b)
	if not Array:isa(a) or not Array:isa(b) then return end
	-- else array+scalar?  nah, too ambiguous.  are you asking for adding to all elements, or just the diagonals? idk.
	if #a ~= #b then return end
	local result = a:clone()
	for i=1,#result do
		result[i] = result[i] + b[i]
	end

	symmath = symmath or require 'symmath'
	local prune = symmath.prune

	return prune(result)
end

-- TODO should all arrays perform matrix multiplciations?
--  or should only matrix/vectors?
-- should non-matrix arrays perform per-element scalar multiplications instead?  or none?
-- how about do this like my matrix library? inner the last index of the left and the first index of the right.
local function matrixMatrixMul(a,b,aj,bj)
	local sa = a:dim()
	local sb = b:dim()
	local dega = #sa -- a:degree()
	local degb = #sb -- b:degree()
	--[[ only support matrix/matrix multiplication
	if dega ~= 2 or degb ~= 2 then return end
	--]]
	if aj then
		assert.le(1, aj)
		assert.le(aj, dega)
	else
		aj = dega
	end
	if bj then
		assert.le(1, bj)
		assert.le(bj, degb)
	else
		bj = 1
	end
	local ssa = table(sa)
	local saj = ssa:remove(aj)
	local ssb = table(sb)
	local sbj = ssb:remove(bj)
	assert.eq(saj, sbj, "inner dimensions must be equal")
	local sc = table(ssa):append(ssb)
	symmath = symmath or require 'symmath'

	-- if we are doing a degree-0 * degree-0 then
	-- Array:lambda can't handle it so I have to do a special case somehow.
	-- should I even bother wrap the results in a matrix?
	-- or should I return it as an expression early?
	-- I"ll do that ...
	if #sc == 0 then
		local sum = table()
		for i=1,saj do
			sum:insert(a[i] * b[i])
		end
		return symmath.tableToAdd(sum)
	end


	-- TODO should it be an Array or a Matrix or a Vector ...
	-- ... or should I just merge them all into this class?
	-- Vector has nothing different except its metatable.
	-- Matrix just has a bunch of extra functions inherited.

	-- How about I use the result type unless its a Vector, because that has connotation that its just degree-1, whereas Array, and Tensor don't.
	-- Granted I am letting Matrix sneak by, being degree 2...
	-- But oh wait there is no Vector class, it's just a wrapper for Array ...
	local resultType = getmetatable(a)
	if resultType == Array then resultType = getmetatable(b) end
	return resultType:lambda(sc, function(...)
		local i = {...}
		local ia = table{table.unpack(i,1,#sa-1)}
		ia:insert(aj, 'false')
		local ib = table{table.unpack(i,#sa)}
		ib:insert(bj, 'false')
		local sum = table()
		for u=1,saj do
			ia[aj] = u
			ib[bj] = u
			local ai = a[ia]
			local bi = b[ib]
			sum:insert(ai * bi)
		end
		return symmath.tableToAdd(sum)
	end)
end


-- TODO only map the elements of the array
-- TODO array getter, setter, and iterator
local function arrayScalarMul(m,s)
	local result = m:clone()
	for i=1,#result do
		result[i] = result[i] * s
	end

	symmath = symmath or require 'symmath'
	local prune = symmath.prune

	return prune:apply(result)
end

local function scalarArrayMul(s,m)
	local result = m:clone()
	for i=1,#result do
		result[i] = s * result[i]
	end

	symmath = symmath or require 'symmath'
	return symmath.prune(result)
end

function Array.pruneMul(lhs,rhs)
	local lhsIsArray = Array:isa(lhs)
	local rhsIsArray = Array:isa(rhs)
	assert(lhsIsArray or rhsIsArray)

	-- hmm but this converts the result to a Matrix ... not whatever class the members are
	if lhsIsArray and rhsIsArray then
		return matrixMatrixMul(lhs, rhs)
	end

	-- matrix-scalar multiplication
	-- notice I'm not handling Matrix/Array multiplication.
	-- My rule of thumb for now is "don't instanciate RowVectors -- instanciate nx1 Matrices instead"
	-- I'm sure that will change once I start introducing tensors.
	-- See the tests/alcubierre.lua file for thoughts on this.
	if lhsIsArray then
		return arrayScalarMul(lhs, rhs)
	elseif rhsIsArray then
		return scalarArrayMul(lhs, rhs)
	end
end


-- creates an array of zeroes
-- static, uses :
function Array:zeros(dims)
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	dims = range(#dims):map(function(i)
		local x = dims[i]
		if Constant.isNumber(x) then return x end
		if Constant:isa(x) then return x.value end
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
	symmath = symmath or require 'symmath'
	local clone = symmath.clone
	local m = self:zeros(dims)
	for i in m:iter() do
		m[i] = clone(f(table.unpack(i)))
	end
	return m
end

-- Forbenius norm
function Array:normSq()
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	local sum = table()
	for i,x in self:iter() do
		sum:insert(x * x)
	end
	return symmath.tableToAdd(sum)()
end

-- L2 norm
function Array:norm()
	symmath = symmath or require 'symmath'
	return symmath.sqrt(self:normSq())()
end

function Array:unit()
	return (self / self:norm())()
end

--[[
a bit different from Matrix mul in that Matrix assumes degree-2
TODO maybe merge this and Matrix mul like my matrix-lua numeric library uses, and just merge inner-degrees of Arrays
TODO :hadamardMul() ? and then merge that with :normSq() ?
--]]
function Array.dot(a,b)
	symmath = symmath or require 'symmath'
	local na, nb = #a, #b
	if na ~= nb then
		error("Array.dot expects Arrays of equal length, found "..#a.." and "..#b)
	end
	return symmath.tableToAdd(table.mapi(a, function(ai,i)
		return ai * b[i]
	end))
end

-- special-case for R3
-- I do have Levi-Civita in Tensor. TODO generalize?
function Array.cross(a, b)
	assert(#a == 3)
	assert(#b == 3)
	return (getmetatable(a) or getmetatable(b) or Array)(
		a[2] * b[3] - a[3] * b[2],
		a[3] * b[1] - a[1] * b[3],
		a[1] * b[2] - a[2] * b[1])()
end

--[[
merge each set of dimensions into one dimension by interleaving
How to specify?
	mergeDims({i1,...}, {j1,...}, ...)
	so mergeDims({1,3},{2,4}) is for 2x2x2x2 => 4x4
	to specify which groups of dims to merge
	and in what interleaved order
	but this doesn't allow specifying where to put them
	and we'd need an extra test to make sure a dimension isn't specified twice

	should I reverse the arg map?
	mergeDims(1,1,2,2)
	then no need to check if no dims are duplicated - just require as many args as dims
	and we can now specify exactly the interleaved dim's destinations
	but we lose the ability to change the order of interleaving

-- TODO the name, Equation already has :unravel()
-- also maybe call this reshape() like matlab, but matlab reshape works different
--]]
--[=[
function Array:mergeDims(...)
	local merges = table{...}

	local dim = self:dim()

	-- new dims = old dims, remove each grouping, replace the first
	-- mapping from old dim index to new dim index
	local newDimMap = range(#dim)

	local newDims = dim:mapi(function(n,i) return dim[newDimMap[i]] end)

	error'TODO'
end
--]=]

return Array
