#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tidyIndexes')

timer(nil, function()

env.a = var'a'
env.b = var'b'
env.c = var'c'
env.d = var'd'
env.e = var'e'
env.f = var'f'

-- some specific tests for Kaluza-Klein
env.phi_K = var'\\phi_K'
env.A = var'A'
env.F = var'F'
env.R = var'R'

for _,line in ipairs(string.split(string.trim([=[
asserteq((a'^b' * b'^in_n' * c'^a_ab'):tidyIndexes(), a'^a' * b'^ib_b' * c'^c_ca')

asserteq((a'^a' * b'^b_ba'):tidyIndexes(), a'^a' * b'^b_ba')
asserteq((a'^i_i' * b'^j_j'):tidyIndexes(), a'^a_a' * b'^b_b')

asserteq(a'^i_i^j_j':tidyIndexes(), a'^a_a^b_b')
asserteq((a'^i_i' + a'^j_j'):tidyIndexes(), 2 * a'^a_a')
asserteq((a'^ij' * (b'_jk' + c'_jk')):tidyIndexes(), a'^ia' * (b'_ak' + c'_ak'))
asserteq((a'_ijk' * b'^jk' + a'_ilm' * b'^lm'):tidyIndexes(), 2 * a'_iab' * b'^ab')
asserteq((a'_ajk' * b'^jk' + a'_alm' * b'^lm'):tidyIndexes(), 2 * a'_abc' * b'^bc')
asserteq((c'^pq' * (d'_ipqj' + d'_jpqi') - c'^mr' * (d'_imrj' + d'_jmri')):tidyIndexes(), 0)
asserteq(((a'^k' + b'^k') * (c'_k' + d'_k')):tidyIndexes(), (a'^a' + b'^a') * (c'_a' + d'_a'))
asserteq((a'^i' * (b'_i' + c'_i^j' * d'_j')):tidyIndexes(), a'^a' * (b'_a' + c'_a^b' * d'_b'))
asserteq(((a'^i' + b'^i_j' * c'^j') * (d'_i' + e'_i^k' * f'_k')):tidyIndexes(), a'^a' * d'_a' + c'^a' * b'^b_a' * d'_b' + a'^a' * f'_b' * e'_a^b' + c'^a' * f'_b' * b'^c_a' * e'_c^b')
asserteq((-a'_i' * a'_j' + (d'_ji^k' + d'_ij^k' - d'^k_ij') * (a'_k' + c'_k' - d'^l_lk')):tidyIndexes(), -a'_i' * a'_j' + (d'_ji^a' + d'_ij^a' - d'^a_ij') * (a'_a' + c'_a' - d'^b_ba') )
asserteq((a'^j_aj' * b'^a' - a'^k_jk' * b'^j'):tidyIndexes(), 0)

asserteq((2 * phi_K^4 * A' _\\alpha' * F' _\\gamma ^\\beta' * F' _\\beta ^\\gamma' * A' ^\\alpha' + phi_K^2 * F' _\\beta ^\\alpha' * F' _\\alpha ^\\beta' + 4 * R - 2 * phi_K^4 * F' _\\beta ^\\alpha' * A' _\\gamma' * F' _\\alpha ^\\beta' * A' ^\\gamma')():tidyIndexes()(), 4 * R + F'_a^b' * F'_b^a' * phi_K^2)	-- should tidyIndexes automatically simplify()?  or at least add.Factor?  otherwise mul terms don't get sorted.

asserteq((a'^i' * b'^j_ji'):tidyIndexes(), a'^a' * b'^b_ba')		-- this uses the first available indexes
]=]), '\n')) do
	env.exec(line)
end

end)
