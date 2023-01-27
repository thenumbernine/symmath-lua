#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/simplifyMetrics')

timer(nil, function()

env.a = var'a'
env.delta = Tensor:deltaSymbol()
env.g = Tensor:metricSymbol()

for _,line in ipairs(string.split(string.trim([=[
simplifyAssertEq(a'^i':simplifyMetrics(), a'^i')
simplifyAssertEq((a'^min' * delta'_i^j'):simplifyMetrics(), a'^mjn')

-- g shouldn't apply to delta, but delta should apply to g
simplifyAssertEq((g'^ij' * delta'_j^k'):simplifyMetrics(), g'^ik')
simplifyAssertEq((delta'_j^k' * g'^ij'):simplifyMetrics(), g'^ik')

-- delta works on mixed tensors
simplifyAssertEq((a'^i' * delta'_i^j'):simplifyMetrics(), a'^j')
simplifyAssertEq((a'^i' * delta'^j_i'):simplifyMetrics(), a'^j')
simplifyAssertEq((delta'_i^j' * a'^i'):simplifyMetrics(), a'^j')
simplifyAssertEq((delta'^j_i' * a'^i'):simplifyMetrics(), a'^j')

-- does delta work when not mixed?  it shouldn't (unless the metric is equal to identity)
simplifyAssertEq((a'^i' * delta'_ij'):simplifyMetrics(), a'^i' * delta'_ij')

-- g raises and lowers
simplifyAssertEq((a'^i' * g'_ij'):simplifyMetrics(), a'_j')
simplifyAssertEq((g'_ij' * a'^i'):simplifyMetrics(), a'_j')
simplifyAssertEq((a'_i' * g'^ij'):simplifyMetrics(), a'^j')
simplifyAssertEq((g'^ij' * a'_i'):simplifyMetrics(), a'^j')

-- does g work when mixed?  technically $g^i_j == \delta^i_j$
simplifyAssertEq((a'^i' * g'_i^j'):simplifyMetrics(), a'^j')

-- how about simplifying solely metrics without any non-metric tensors?
simplifyAssertEq((g'^ik' * delta'_k^l'):simplifyMetrics(), g'^il')
simplifyAssertEq((g'^ik' * delta'_k^l' * delta'_l^m'):simplifyMetrics(), g'^im')

-- how about simplifying from metrics to deltas?
simplifyAssertEq((g'^ik' * g'_kj'):simplifyMetrics(), delta'^i_j')
simplifyAssertEq((g'^ik' * delta'_k^l' * g'_lm'):simplifyMetrics(), delta'^i_m')
simplifyAssertEq((g'^ik' * delta'_k^l' * delta'_l^m' * g'_mn'):simplifyMetrics(), delta'^i_n')

-- how about derivatives?  delta should work but g should not.
-- TODO technically g should work on the last ... technically ...  but raised partials are awkward to deal with.
-- and on that note, I might as well lower with the metric
simplifyAssertEq((a'_,i' * g'^ij'):simplifyMetrics(), a'_,i' * g'^ij')
simplifyAssertEq((a'^,i' * g'_ij'):simplifyMetrics(), a'^,i' * g'_ij')
simplifyAssertEq((a'_,im' * g'^ij'):simplifyMetrics(), a'_,im' * g'^ij')
simplifyAssertEq((a'^,im' * g'_ij'):simplifyMetrics(), a'^,im' * g'_ij')
simplifyAssertEq((a'_i,m' * g'^ij'):simplifyMetrics(), a'_i,m' * g'^ij')
simplifyAssertEq((a'^i,m' * g'_ij'):simplifyMetrics(), a'^i,m' * g'_ij')

-- but delta should simplify with commas
simplifyAssertEq((a'_,i' * delta'^i_j'):simplifyMetrics(), a'_,j')
simplifyAssertEq((a'^,i' * delta'_i^j'):simplifyMetrics(), a'^,j')
simplifyAssertEq((a'_,im' * delta'^i_j'):simplifyMetrics(), a'_,jm')
simplifyAssertEq((a'^,im' * delta'_i^j'):simplifyMetrics(), a'^,jm')
simplifyAssertEq((a'_i,m' * delta'^i_j'):simplifyMetrics(), a'_j_,m')
simplifyAssertEq((a'^i,m' * delta'_i^j'):simplifyMetrics(), a'^j^,m')

-- TODO someday:
-- allow g_ij to raise/lower the last partial derivative
-- allow g_ij to raise/lower any covariant derivatives not enclosed in partial derivatives.

]=]), '\n')) do
	env.exec(line)
end

env.done()
end)
