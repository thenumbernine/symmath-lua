#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'unit'(env, 'simplifyMetrics')

env.a = var'a'
env.delta = Tensor:deltaSymbol()
env.g = Tensor:metricSymbol()

for _,line in ipairs(string.split(string.trim([=[
asserteq(a'^i':simplifyMetrics(), a'^i')
asserteq((a'^min' * delta'_i^j'):simplifyMetrics(), a'^mjn')

-- g shouldn't apply to delta, but delta should apply to g
asserteq((g'^ij' * delta'_j^k'):simplifyMetrics(), g'^ik')
asserteq((delta'_j^k' * g'^ij'):simplifyMetrics(), g'^ik')

-- delta works on mixed tensors
asserteq((a'^i' * delta'_i^j'):simplifyMetrics(), a'^j')
asserteq((a'^i' * delta'^j_i'):simplifyMetrics(), a'^j')
asserteq((delta'_i^j' * a'^i'):simplifyMetrics(), a'^j')
asserteq((delta'^j_i' * a'^i'):simplifyMetrics(), a'^j')

-- does delta work when not mixed?  it shouldn't (unless the metric is equal to identity)
asserteq((a'^i' * delta'_ij'):simplifyMetrics(), a'^i' * delta'_ij')

-- g raises and lowers
asserteq((a'^i' * g'_ij'):simplifyMetrics(), a'_j')
asserteq((g'_ij' * a'^i'):simplifyMetrics(), a'_j')
asserteq((a'_i' * g'^ij'):simplifyMetrics(), a'^j')
asserteq((g'^ij' * a'_i'):simplifyMetrics(), a'^j')

-- does g work when mixed?  technically $g^i_j == \delta^i_j$
asserteq((a'^i' * g'_i^j'):simplifyMetrics(), a'^j')

-- how about simplifying solely metrics without any non-metric tensors?
asserteq((g'^ik' * delta'_k^l'):simplifyMetrics(), g'^il')
asserteq((g'^ik' * delta'_k^l' * delta'_l^m'):simplifyMetrics(), g'^im')

-- how about simplifying from metrics to deltas? 
asserteq((g'^ik' * g'_kj'):simplifyMetrics(), delta'^i_j')
asserteq((g'^ik' * delta'_k^l' * g'_lm'):simplifyMetrics(), delta'^i_m')
asserteq((g'^ik' * delta'_k^l' * delta'_l^m' * g'_mn'):simplifyMetrics(), delta'^i_n')

-- how about derivatives?  delta should work but g should not.  
-- TODO technically g should work on the last ... technically ...  but raised partials are awkward to deal with.
-- and on that note, I might as well lower with the metric
asserteq((a'_,i' * g'^ij'):simplifyMetrics(), a'_,i' * g'^ij')
asserteq((a'^,i' * g'_ij'):simplifyMetrics(), a'^,i' * g'_ij')
asserteq((a'_,im' * g'^ij'):simplifyMetrics(), a'_,im' * g'^ij')
asserteq((a'^,im' * g'_ij'):simplifyMetrics(), a'^,im' * g'_ij')
asserteq((a'_i,m' * g'^ij'):simplifyMetrics(), a'_i,m' * g'^ij')
asserteq((a'^i,m' * g'_ij'):simplifyMetrics(), a'^i,m' * g'_ij')

-- but delta should simplify with commas
asserteq((a'_,i' * delta'^i_j'):simplifyMetrics(), a'_,j')
asserteq((a'^,i' * delta'_i^j'):simplifyMetrics(), a'^,j')
asserteq((a'_,im' * delta'^i_j'):simplifyMetrics(), a'_,jm')
asserteq((a'^,im' * delta'_i^j'):simplifyMetrics(), a'^,jm')
asserteq((a'_i,m' * delta'^i_j'):simplifyMetrics(), a'_j_,m')
asserteq((a'^i,m' * delta'_i^j'):simplifyMetrics(), a'^j^,m')

-- TODO someday: 
-- allow g_ij to raise/lower the last partial derivative
-- allow g_ij to raise/lower any covariant derivatives not enclosed in partial derivatives.

]=]), '\n')) do
	env.exec(line)
end
