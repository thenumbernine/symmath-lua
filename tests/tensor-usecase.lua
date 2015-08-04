#! /usr/bin/env luajit
local symmath = require 'symmath'
local Tensor = require 'symmath.Tensor'
local TensorIndex = require 'symmath.tensor.TensorIndex'
-- no metric:

-- rank-1
local n = 4
local test = function(t)
	for i=1,n do
		assert(t:get{n}:equals(n):isTrue())
	end
end
for _,indexes in ipairs{
	-- empty indexes
	{},
	-- string indexes
	{'_i'}, {'^i'},
	-- index objects 
	{{TensorIndex{symbol='i'}}},
	{{TensorIndex{symbol='i', lower=true}}},
} do
	-- data-only constructor:
	local args = range(n)
	if indexes[1] then args = {indexes[1], unpack(args)} end
	test(Tensor(unpack(args)))
	-- value-only constructor
	test(Tensor{
		dim = {n},
		indexes = indexes[1],
		values = function(i) return i end,
	})
end

-- rank-2
local m = 3
local function test(t)
	for i=1,m do
		for j=1,n do
			-- if only Lua could overload the compare for primitives of differing types ... 
			assert(t:get{i,j}:equals((i-1)*n+j):isTrue())		
		end
	end
end
for _,indexes in ipairs{
	--empty indexes
	{},
	-- string indexes
	{'_ij'}, {'_i^j'}, {'^i_j'}, {'^ij'}
	-- index objects (TODO)
} do
	-- data-only constructor:
	local args = range(m):map(function(i)
		return range(n):map(function(j)
			return j + n * (i-1)
		end)
	end)
	if indexes[1] then args = {indexes[1], unpack(args)} end
	test(Tensor(unpack(args)))
	-- value-only constructor
	test(Tensor{
		dim = {m, n},
		indexes = indexes[1],
		values = function(i,j) return j + n * (i-1) end,
	})
end

-- rank-3
local p = 5
local function test(t)
	for i=1,m do
		for j=1,n do
			for k=1,p do
				assert(t:get{i,j,k}:equals(k + p*((j-1) + n*(i-1))):isTrue())
			end
		end
	end
end
for _,indexes in ipairs{
	-- empty indexes
	{},
	-- string indexes
	{'_ijk', '_ij^k', '_i^j_k', '^i_jk', '_i^jk', '^i_j^k', '^ij_k', '^ijk'}
	-- index objects (TODO)
} do
	-- data-only constructor:
	local args = range(m):map(function(i)
		return range(n):map(function(j)
			return range(p):map(function(k)
				return k + p * ((j-1) + n * (i-1))
			end)
		end)
	end)
	if indexes[1] then args = {indexes[1], unpack(args)} end
	test(Tensor(unpack(args)))
	-- value-only constructor:
	test(Tensor{
		dim = {m, n, p},
		indexes = indexes[1],
		values = function(i,j,k) return k + p * ((j-1) + n * (i-1)) end,
	})
end

-- constructing an index-based tensor without a metric or without data gives an error
assert(not pcall(function() Tensor('_i') end))
assert(not pcall(function() Tensor('_ij') end))

-- setting metric without a coordinate basis gives an error
assert(not pcall(function() Tensor.metric{{1,0}, {0,1}} end))

-- setting coordinate basis
local x,y,z = symmath.vars('x', 'y', 'z')
Tensor.coords({variables={x,y,z}})

-- now assigning by index only should work
for _,indexes in ipairs{'_i', '^i', '_ij', '^ij', '_ijk', '^ijk'} do
	Tensor(indexes)
end
