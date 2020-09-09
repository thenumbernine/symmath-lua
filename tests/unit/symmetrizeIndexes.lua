#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'unit'(env, 'symmetrizeIndexes')

env.a = var'a'
env.d = var'd'
env.g = var'g'
env.delta  = Tensor:deltaSymbol()

for _,line in ipairs(string.split(string.trim([=[

-- fundamentally, is this a function to simplify symmetries that are obvious? such as derivative symmetries, i.e. a_,ji == a_,ij
-- or is this meant to dictate symmetries of non-derivative tensor values (but not derivatives)?  i.e. g_ji,lk = g_ij,kl
-- or is this meant to dictate values anyhow anywhere?  i.e. a_i,j == a_j,i
-- I'm leaning towards #1 and #2 but not #3
-- so use this for symmetries of derivatives and non-derivatives 

-- SO THE TAKE-AWAY ...
-- 1) swap variance with symbol.
-- 2) assert the derivative type of the index match, error if they don't.
-- 2.5) if all indexes have commas then error if any are upper (unless all are covariant derivatives)
-- 3) allow an override for non-matching commas ... don't swap comma.  still do swap variance.



asserteq( a'_ji':symmetrizeIndexes(a,{1,2}), a'_ij')

-- TODO in the case of 3 this isn't used so often
asserteq( a'_kji':symmetrizeIndexes(a,{1,2,3}), a'_ijk')
asserteq( a'_jki':symmetrizeIndexes(a,{1,2,3}), a'_ijk')
asserteq( a'_jik':symmetrizeIndexes(a,{1,2,3}), a'_ijk')

-- TODO make sure this works when? 

-- maintain raise/lower
asserteq( a'_j^i':symmetrizeIndexes(a,{1,2}), a'^i_j')

-- don't symmetrize a comma and a non-comma (should I restrict this?)
asserterror(function() a'_j,i':symmetrizeIndexes(a,{1,2}) end)

-- do allow with override
asserteq(a'_j,i':symmetrizeIndexes(a,{1,2},true), a'_i,j')

-- do symmetrize two commas 
asserteq( a'_,ji':symmetrizeIndexes(a,{1,2}), a'_,ij')
asserteq( a'_,kji':symmetrizeIndexes(a,{1,2,3}), a'_,ijk')
asserteq( a'_,jki':symmetrizeIndexes(a,{1,2,3}), a'_,ijk')
asserteq( a'_,jik':symmetrizeIndexes(a,{1,2,3}), a'_,ijk')

asserteq( a'_ji,lk':symmetrizeIndexes(a,{1,2}):symmetrizeIndexes(a,{3,4}), a'_ij,kl')
asserterror(function() a'_ji,lk':symmetrizeIndexes(a,{2,3}) end)
asserteq(a'_jl,ik':symmetrizeIndexes(a,{2,3},true), a'_ji,lk')

-- if a_ij = a_ji 
-- then a^i_j = g^ik a_kj = g^ik a_jk = a_j^i
-- and a^i_j,k = (g^im a_mj)_,k = g^im_,k a_mj + g^im a_mj,k = g^im_,k a_jm + g^im a_jm,k = (g^im a_jm)_,k = a_j^i_,k
-- so even symmetries with non-matching variance that are wrapped in derivatives can be symmetrized
asserteq( a'_j^i_,k':symmetrizeIndexes(a,{1,2}), a'^i_j,k')
asserteq( a'_ji,k':symmetrizeIndexes(a,{1,2}), a'_ij,k')
asserteq( a'^ji_,k':symmetrizeIndexes(a,{1,2}), a'^ij_,k')

-- same if the comma is raised? a_ij==a_ji <=> a_i^j,k==a^j_i^,k ?
-- how about if multiple commas are upper?  <=> a^i,jk == a^i,kj ?
-- a^i,jk = (g^im a_m)^,jk = ((g^im a_m)_,n g^nj)_,p g^pk
-- = ((g^im a_m)_,np g^nj + (g^im a_m)_,n g^nj_,p) g^pk
-- = (g^im a_m)_,np g^pk g^nj + (g^im a_m)_,n g^nj_,p g^pk
-- = (g^im_,n a_m + g^im a_m,n)_,p g^pk g^nj + (g^im_,n a_m + g^im a_m,n) g^nj_,p g^pk
-- = g^im_,np g^pk g^nj a_m + g^im_,n a_m,p g^pk g^nj + g^im_,p a_m,n g^pk g^nj + g^im_,n a_m g^nj_,p g^pk + g^im a_m,n g^nj_,p g^pk + a_m,np g^im g^pk g^nj
-- so it doesn't look like these match
-- = g^im_,np g^pk g^nj a_m + g^im_,n a_m,p g^pk g^nj + g^im_,p a_m,n g^pk g^nj + g^im_,n a_m g^nk_,p g^pj + g^im a_m,n g^nk_,p g^pj + a_m,np g^im g^pk g^nj
-- = a_m g^im_,np g^pj g^nk + g^im_,n a_m,p g^pj g^nk + g^im_,p a_m,n g^pj g^nk + g^im a_m,np g^pj g^nk + g^im_,n a_m g^nk_,p g^pj + g^im a_m,n g^nk_,p g^pj
-- = a^i,kj
-- this looks like a job for my CAS ... but it isn't looking like upper commas can be assumed to be symmetric
-- so commas can only be symmetrized if they are all lowered
asserteq(a'_i,kj':symmetrizeIndexes(a,{2,3}), a'_i,jk')
-- but if they are upper then cause an error
asserterror(function() a'_i^,jk':symmetrizeIndexes(a,{2,3}) end)
-- unless explicitly overridden
asserteq(a'_i^,kj':symmetrizeIndexes(a,{2,3},true), a'_i^,jk')

-- if you symmetrize non-lower-matching that are encased in deriv indexes ... still fine. (even if the derivs are upper?)
asserteq( a'^j_i,kl':symmetrizeIndexes(a,{1,2}), a'_i^j_,kl')

-- TODO test for also sort any multiplied tensors?
-- another thing symmetrizing can do ...
-- g^kl (d_klj + d_jlk - d_ljk)  symmetrize g {1,2}
-- ... not only sort g^kl
-- but also sort all indexes in all multiplied expressions which use 'k' or 'l'
-- so this would become
-- g^kl (d_klj + d_jkl - d_kjl)
-- then another symmetrize d {2,3} gives us
-- g^kl (d_kjl + d_jkl - d_kjl)
-- g^kl d_jkl
asserteq( (g'^kl' * (d'_klj' + d'_jlk' - d'_ljk')):symmetrizeIndexes(g, {1,2}), g'^kl' * (d'_klj' + d'_jkl' - d'_kjl') )
asserteq( (g'^kl' * (d'_klj' + d'_jlk' - d'_ljk')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}), g'^kl' * (d'_kjl' + d'_jkl' - d'_kjl') )
asserteq( (g'^kl' * (d'_klj' + d'_jlk' - d'_ljk')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3})(), g'^kl' * d'_jkl' )

-- same with all-lower
asserteq( (g'_kl' * (d'^kl_j' + d'_j^lk' - d'^l_j^k')):symmetrizeIndexes(g, {1,2}), g'_kl' * (d'^kl_j' + d'_j^kl' - d'^k_j^l') )
asserteq( (g'_kl' * (d'^kl_j' + d'_j^lk' - d'^l_j^k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}), g'_kl' * (d'^k_j^l' + d'_j^kl' - d'^k_j^l') )
asserteq( (g'_kl' * (d'^kl_j' + d'_j^lk' - d'^l_j^k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3})(), g'_kl' * d'_j^kl' )

-- same with mixed upper/lower
asserteq( (delta'_k^l' * (d'^k_lj' + d'_jl^k' - d'_lj^k')):symmetrizeIndexes(delta, {1,2}), delta'_k^l' * (d'^k_lj' + d'_j^k_l' - d'^k_jl') )
asserteq( (delta'_k^l' * (d'^k_lj' + d'_jl^k' - d'_lj^k')):symmetrizeIndexes(delta, {1,2}):symmetrizeIndexes(d, {2,3}), delta'_k^l' * (d'^k_jl' + d'_j^k_l' - d'^k_jl') )
asserteq( (delta'_k^l' * (d'^k_lj' + d'_jl^k' - d'_lj^k')):symmetrizeIndexes(delta, {1,2}):symmetrizeIndexes(d, {2,3})(), delta'_k^l' * d'_j^k_l' )

-- how about with commas?  don't forget, you can't exchange comma positions, even if you override errors, because commas cannot precede non-comma indexes.
asserterror(function() (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}) end)
asserterror(function() (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}) end)
asserterror(function() (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3})() end)

asserteq( (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}, true), g'^kl' * (d'_kl,j' + d'_jk,l' - d'_kj,l') )
asserteq( (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}, true):symmetrizeIndexes(d, {2,3}, true), g'^kl' * (d'_kj,l' + d'_jk,l' - d'_kj,l') )
asserteq( (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}, true):symmetrizeIndexes(d, {2,3}, true)(), g'^kl' * d'_jk,l' )

]=]), '\n')) do
	env.exec(line)
end
