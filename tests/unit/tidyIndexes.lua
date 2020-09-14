#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'unit'(env, 'tidyIndexes')

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
asserteq(a'^i_i^j_j':tidyIndexes(), a'^a_a^b_b')
asserteq((a'^i_i' + a'^j_j'):tidyIndexes(), 2 * a'^a_a')
asserteq((a'^ij' * (b'_jk' + c'_jk')):tidyIndexes(), a'^ia' * (b'_ak' + c'_ak'))
asserteq((a'_ijk' * b'^jk' + a'_ilm' * b'^lm'):tidyIndexes(), 2 * a'_iab' * b'^ab')
asserteq((a'_ajk' * b'^jk' + a'_alm' * b'^lm'):tidyIndexes(), 2 * a'_abc' * b'^bc')
asserteq((c'^pq' * (d'_ipqj' + d'_jpqi') - c'^mr' * (d'_imrj' + d'_jmri')):tidyIndexes(), 0)
asserteq(((a'^k' + b'^k') * (c'_k' + d'_k')):tidyIndexes(), (a'^a' + b'^a') * (c'_a' + d'_a'))
asserteq((a'^i' * (b'_i' + c'_i^j' * d'_j')):tidyIndexes(), a'^a' * (b'_a' + c'_a^b' * d'_b'))
asserteq(((a'^i' + b'^i_j' * c'^j') * (d'_i' + e'_i^k' * f'_k')):tidyIndexes(), (a'^a' + b'^a_b' * c'^b') * (d'_a' + e'_a^c' * f'_c'))
asserteq((-a'_i' * a'_j' + (d'_ji^k' + d'_ij^k' - d'^k_ij') * (a'_k' + c'_k' - d'^l_lk')):tidyIndexes(), -a'_i' * a'_j' + (d'_ji^a' + d'_ij^a' - d'^a_ij') * (a'_a' + c'_a' - d'^b_ba') )
asserteq((a'^j_aj' * b'^a' - a'^k_jk' * b'^j'):tidyIndexes(), 0)

asserteq((2 * phi_K^4 * A' _\\alpha' * F' _\\gamma ^\\beta' * F' _\\beta ^\\gamma' * A' ^\\alpha' + phi_K^2 * F' _\\beta ^\\alpha' * F' _\\alpha ^\\beta' + 4 * R - 2 * phi_K^4 * F' _\\beta ^\\alpha' * A' _\\gamma' * F' _\\alpha ^\\beta' * A' ^\\gamma')():tidyIndexes()(), 4 * R + F'_a^b' * F'_b^a' * phi_K^2)	-- should tidyIndexes automatically simplify()?  or at least add.Factor?  otherwise mul terms don't get sorted.

asserteq((a'^i_i' * b'^j_j'):tidyIndexes(), a'^a_a' * b'^b_b')		-- TODO sum indexes should be distinct within a term, but we are regurgitating them
asserteq((a'^i' * b'^j_ji'):tidyIndexes(), a'^a' * b'^b_ba')		-- this uses the first available indexes
asserteq((a'^a' * b'^b_ba'):tidyIndexes(), a'^a' * b'^b_ba')		-- ... but if they were used as sum indexes in the source, it skips them as sum indexes in the destination TODO FIXME
]=]), '\n')) do
	env.exec(line)
end
