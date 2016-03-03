#! /usr/bin/env luajit
local symmath = require 'symmath'
local TensorIndex = require 'symmath.tensor.TensorIndex'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

local Matrix = symmath.Matrix
local Tensor = symmath.Tensor

local maxN = 3

local function setDim(n)
	Tensor.coords{
		{
			variables = range(n):map(function(i)
				return symmath.var('x'..i)
			end),
		}
	}
	return n
end

-- no metric:

local function assertEqn(eqn)
	if not eqn:simplify():isTrue() then
		error("expected "..(eqn:lhs()).." to equal "..(eqn:rhs()))
	end
end

-- rank-1
for n=1,maxN do
	local test = function(t)
		for i=1,n do
			assertEqn(t:get{n}:eq(n))
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
		if indexes[1] then args = {indexes[1], table.unpack(args)} end
		test(Tensor(table.unpack(args)))
		-- value-only constructor
		test(Tensor{
			dim = {n},
			indexes = indexes[1],
			values = function(i) return i end,
		})
	end

	-- rank-2
	for m=1,maxN do
		local function test(t)
			for i=1,m do
				for j=1,n do
					-- if only Lua could overload the compare for primitives of differing types ... 
					assertEqn(t:get{i,j}:eq((i-1)*n+j))
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
			if indexes[1] then args = {indexes[1], table.unpack(args)} end
			test(Tensor(table.unpack(args)))
			-- value-only constructor
			test(Tensor{
				dim = {m, n},
				indexes = indexes[1],
				values = function(i,j) return j + n * (i-1) end,
			})
		end

		-- rank-3
		for p=1,maxN do
			local function test(t)
				for i=1,m do
					for j=1,n do
						for k=1,p do
							assertEqn(t:get{i,j,k}:eq(k + p*((j-1) + n*(i-1))))
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
				if indexes[1] then args = {indexes[1], table.unpack(args)} end
				test(Tensor(table.unpack(args)))
				-- value-only constructor:
				test(Tensor{
					dim = {m, n, p},
					indexes = indexes[1],
					values = function(i,j,k) return k + p * ((j-1) + n * (i-1)) end,
				})
			end
		end
	end
end

-- constructing an index-based tensor without a metric or without data gives an error
for _,indexes in ipairs{'_i', '^i', '_ij', '^ij', '_ijk', '^ijk'} do
	-- without named parameters: 
	assert(not pcall(function() Tensor(indexes) end))
	-- with named parameters:
	assert(not pcall(function() Tensor{indexes=indexes} end))
end

-- setting metric without a coordinate basis gives an error
assert(not pcall(function() Tensor.metric{{1,0}, {0,1}} end))

-- setting coordinate basis
for n=1,maxN do
	setDim(n)

	-- now assigning by index only should work
	local indexesComplement = {'^i', '_i', '^ij', '_ij', '^ijk', '_ijk'}
	for i,indexes in ipairs{'_i', '^i', '_ij', '^ij', '_ijk', '^ijk'} do
		-- without named parameters
		local t = Tensor(indexes)
		-- with named parameters
		local t = Tensor{indexes=indexes}

	-- however raising/lowering will still fail without defining a metric
		assert(not pcall(function()
			local t = Tensor(indexes)
			-- perform the raise/lower... and error
			t(indexesComplement[i])()
		end))
	end

	-- testing tensor transpose
	local t = Tensor('_ij', function(i,j) return i + n*(j-1) end)
	for i=1,n do for j=1,n do assertEqn(t[{i,j}]:eq(i+n*(j-1))) end end
	t['_ij'] = t'_ji'()	-- TODO fixme
	for i=1,n do for j=1,n do assertEqn(t[{i,j}]:eq(j+n*(i-1))) end end

	-- testing contraction to a scalar:
	local expected = 0
	for i=1,n do
		expected = expected + i + n*(i-1)
	end
	assertEqn(t'_ii':eq(expected))

	-- testing contraction to a vector
	local t = Tensor('_ijk', function(i,j,k) return i + n*(j-1 + n*(k-1)) end)
	local expected = Tensor'_k'
	for k=1,n do
		expected[k] = 0
		for i=1,n do
			expected[k] = expected[k] + i + n*(k-1 + n*(i-1))
		end
		expected[k] = symmath.Constant(expected[k])
	end
	assertEqn(t'_iki':eq(expected))
end


-- testing 3-point rotation (to verify that the mapping between indexes is the correct direction -- 2-point (i.e. transpose) won't pick up on this)
local n = setDim(3)
local epsilon = Tensor'_ijk'
epsilon[1][2][3] = symmath.Constant(1)
assertEqn(epsilon[{1,2,3}]:eq(1))
-- now rotate
epsilon['_ijk'] = epsilon'_jki'()
assertEqn(epsilon[{3,1,2}]:eq(1))
assertEqn(epsilon[{2,3,1}]:eq(0))	-- this will be 1 if the index remapping is done backwards

-- testing raising/lowering
	-- testing scale of raising/lowering
local n = setDim(3)
Tensor.metric(Tensor('_ij', {1, 0, 0}, {0, 2, 0}, {0, 0, 3}))
	-- testing raising
local t = Tensor('_i', 1,2,3)
assertEqn(t'^i':eq(Tensor('^i', 1, 1, 1)))
	-- variance of index doesn't matter -- a^u == a_u is true so long as a^1==a_1 && a^2==a_2 ... etc
assertEqn(t'^i':eq(Tensor('_i', 1, 1, 1)))	
	-- testing lower
local t = Tensor('^i', 1,2,3)
assertEqn(t'_i':eq(Tensor('_i', 1, 4, 9)))
assertEqn(t'_i':eq(Tensor('^i', 1, 4, 9)))
	-- testing skew of raising/lowering (assuring that the linear transform is using the correct index into the metric matrix)
local basis = Tensor.metric(Tensor('_ij', {1, 1, 0}, {0, 1, 0}, {0, 0, 1}))
	-- assert that the inverse was calculated correctly
assertEqn(basis.metricInverse[1]:eq(Tensor('^j', 1, -1, 0)))

assertEqn(basis.metricInverse[1]:eq(Tensor('^j', 1, -1, 0)))
assertEqn(basis.metricInverse[2]:eq(Tensor('^j', 0, 1, 0)))
assertEqn(basis.metricInverse[3]:eq(Tensor('^j', 0, 0, 1)))

assertEqn(basis.metricInverse:eq(Tensor('^ij', {1, -1, 0}, {0, 1, 0}, {0, 0, 1})))
local t = Tensor('^i', 1,2,3)
--[[
[1 1 0] [1]   [3]
[0 1 0] [2] = [2]
[0 0 1] [3]   [3]
--]]
assertEqn(t'_i':eq(Tensor('_i', 3,2,3)))

print(MathJax.footer)
