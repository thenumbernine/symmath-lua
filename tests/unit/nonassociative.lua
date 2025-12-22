#!/usr/bin/env luajit

-- really this is just a cayley-dickson test, but it's a non-associative test too, so

local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/nonassociative')
env.assert = require 'ext.assert'

timer(nil, function()

env.a = var'a'
env.oct = require 'symmath.CayleyDickson'(3)
env.e0, env.e1, env.e2, env.e3, env.e4, env.e5, env.e6, env.e7 = table.unpack(env.oct)

for _,line in ipairs{
[[ assert.len(oct, 8) ]],
[[
assert.len(oct, 8)
simplifyAssertEq(e0 * e0, e0)
assert.len(oct, 8)
]],
[[
assert.len(oct, 8)
simplifyAssertEq(e1 * e1, -e0)
assert.len(oct, 8)
]],
[[
assert.len(oct, 8)
simplifyAssertEq(e1 * e2, e3)
assert.len(oct, 8)
]],
[[
assert.len(oct, 8)
simplifyAssertEq(e2 * e1, -e3)
assert.len(oct, 8)
]],

-- finding a bug...
[[print((e1 * e4):prune())]],
[[print(((e1 * a) * e4):prune())]],
[[print(Vector(e1))]],
[[print(Vector(e1) * e4)]],
[[print((Vector(e1) * e4):prune())]],
[[print(((Vector(e1) * a) * e4):prune())]],
[[print((Vector{e1} * Vector(a))()[1])]],

-- fails
[[print( ((Vector{e1} * Vector(a)) * e4)() )]],
} do
assert.len(env.oct, 8)
	env.exec(line)
end

-- verify associativity matches the original library
for i,ei in ipairs(env.oct) do
	for j,ej in ipairs(env.oct) do
		for k,ek in ipairs(env.oct) do
			env.indexI = i
			env.indexJ = j
			env.indexK = k
			env.exec[[
local i = indexI
local j = indexJ
local k = indexK
assert.le(1, i)
assert.le(i, 8)
assert.le(1, j)
assert.le(j, 8)
assert.le(1, k)
assert.le(k, 8)
local ei, ej, ek = oct[i], oct[j], oct[k]
local cd = oct.impl

local cd_ei = assert.index(cd[1], i)
local cd_ej = assert.index(cd[1], j)
local cd_ek = assert.index(cd[1], k)
local cd_eij_k = (cd_ei * cd_ej) * cd_ek
local cd_ei_jk = cd_ei * (cd_ej * cd_ek)
local cd_equal = cd_eij_k == cd_ei_jk
local eij_k_doubleSimplify = ((ei * ej)() * ek)()
local ei_jk_doubleSimplify = (ei * (ej * ek)())()
local doubleSimplify_equal = eij_k_doubleSimplify == ei_jk_doubleSimplify
local eij_k_simplify = ((ei * ej) * ek)()
local ei_jk_simplify = (ei * (ej * ek))()
local simplify_equal = eij_k_simplify == ei_jk_simplify

print(ei, ej, ek,
	cd_eij_k,
	cd_ei_jk,
	cd_equal,
	eij_k_doubleSimplify,
	ei_jk_doubleSimplify,
	doubleSimplify_equal,
	eij_k_simplify,
	ei_jk_simplify,
	simplify_equal)

assert.eq(cd_equal, doubleSimplify_equal)
assert.eq(cd_equal, simplify_equal)
]]
		end
	end
end

env.done()
end)
