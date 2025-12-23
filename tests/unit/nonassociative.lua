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
[[simplifyAssertEq(e0 * e0, e0)]],
[[simplifyAssertEq(e1 * e1, -e0)]],
[[simplifyAssertEq(e1 * e2, e3)]],
[[simplifyAssertEq(e2 * e1, -e3)]],


[[simplifyAssertEq((e1 * e2) * e3, -e0) -- zero-associator]],
[[simplifyAssertEq(e1 * (e2 * e3), -e0)]],

[[simplifyAssertEq((e1 * e2) * e4, e7) -- nonzero associator]],
[[simplifyAssertEq(e1 * (e2 * e4), -e7)]],

-- had a problem with flatten but it's fixed now...
[[simplifyAssertEq( (var'a' * e1) * var'a', var'a'^2 * e1)]],
[[simplifyAssertEq( (var'a' * e1 * e2) * var'a', var'a'^2 * e3)]],
[[simplifyAssertEq( var'a' * (var'a' * e1 * e2) , var'a'^2 * e3)]],
[[simplifyAssertEq( (var'a' * e1 * e2) * e4, var'a' * e7 )]],

[[simplifyAssertEq((var'a' * e1 * e2) * e4, var'a' * e7) -- with coefficients:]],

-- stack overflowing when you mix add, mul, and mulNonAssociative
[[print((((e1 + e2) * e2) * e2)()) -- should equal -e1 - e2 ]],

-- trying to prevent add/Factor from shifting around non-commutative / non-associative terms
-- without breaking everything
-- Expression.__eq will non-commutative compare nodes
[[assert.eq(true, Expression.__eq((2 * e0)(), 2 * e0))]],
[[assert.eq(false, Expression.__eq((2 * e0)(), e0 * 2))]],
-- so lets make sure that our commutative & associative number coefficients go left
[[assert.eq(true, Expression.__eq((e0 * 2)(), 2 * e0))]],
-- this is a commutative compare so it will pass
[[assert.eq( (e0 * 2)(), (2 * e0)() )]],
-- and same with variables
[[
print((var'a' * e0)())
print((e0 * var'a')())
assert.eq(true, Expression.__eq(
	(var'a' * e0)(),
	(e0 * var'a')()
))
]],
-- this is a commutative compare so it will pass
[[assert.eq( (e0 * var'a')(), (var'a' * e0)() )]],

} do
	env.exec(line)
end

--[==[ verify associativity matches the original library
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
--]==]

env.done()
end)
