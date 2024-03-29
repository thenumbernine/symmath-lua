#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/symmetrizeIndexes')

timer(nil, function()

env.a = var'a'
env.b = var'b'
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



simplifyAssertEq( a'_ji':symmetrizeIndexes(a,{1,2}), a'_ij')

-- TODO in the case of 3 this isn't used so often
simplifyAssertEq( a'_kji':symmetrizeIndexes(a,{1,2,3}), a'_ijk')
simplifyAssertEq( a'_jki':symmetrizeIndexes(a,{1,2,3}), a'_ijk')
simplifyAssertEq( a'_jik':symmetrizeIndexes(a,{1,2,3}), a'_ijk')

-- TODO make sure this works when?

-- maintain raise/lower
simplifyAssertEq( a'_j^i':symmetrizeIndexes(a,{1,2}), a'^i_j')

-- don't symmetrize a comma and a non-comma (should I restrict this?)
assertError(function() a'_j,i':symmetrizeIndexes(a,{1,2}) end)

-- do allow with override
simplifyAssertEq(a'_j,i':symmetrizeIndexes(a,{1,2},true), a'_i,j')

-- do symmetrize two commas
simplifyAssertEq( a'_,ji':symmetrizeIndexes(a,{1,2}), a'_,ij')
simplifyAssertEq( a'_,kji':symmetrizeIndexes(a,{1,2,3}), a'_,ijk')
simplifyAssertEq( a'_,jki':symmetrizeIndexes(a,{1,2,3}), a'_,ijk')
simplifyAssertEq( a'_,jik':symmetrizeIndexes(a,{1,2,3}), a'_,ijk')

simplifyAssertEq( a'_ji,lk':symmetrizeIndexes(a,{1,2}):symmetrizeIndexes(a,{3,4}), a'_ij,kl')
assertError(function() a'_ji,lk':symmetrizeIndexes(a,{2,3}) end)
simplifyAssertEq(a'_jl,ik':symmetrizeIndexes(a,{2,3},true), a'_ji,lk')

-- if a_ij = a_ji
-- then a^i_j = g^ik a_kj = g^ik a_jk = a_j^i
-- and a^i_j,k = (g^im a_mj)_,k = g^im_,k a_mj + g^im a_mj,k = g^im_,k a_jm + g^im a_jm,k = (g^im a_jm)_,k = a_j^i_,k
-- so even symmetries with non-matching variance that are wrapped in derivatives can be symmetrized
simplifyAssertEq( a'_j^i_,k':symmetrizeIndexes(a,{1,2}), a'^i_j,k')
simplifyAssertEq( a'_ji,k':symmetrizeIndexes(a,{1,2}), a'_ij,k')
simplifyAssertEq( a'^ji_,k':symmetrizeIndexes(a,{1,2}), a'^ij_,k')

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
simplifyAssertEq(a'_i,kj':symmetrizeIndexes(a,{2,3}), a'_i,jk')
-- but if they are upper then cause an error
assertError(function() a'_i^,jk':symmetrizeIndexes(a,{2,3}) end)
-- unless explicitly overridden
simplifyAssertEq(a'_i^,kj':symmetrizeIndexes(a,{2,3},true), a'_i^,jk')

-- if you symmetrize non-lower-matching that are encased in deriv indexes ... still fine. (even if the derivs are upper?)
simplifyAssertEq( a'^j_i,kl':symmetrizeIndexes(a,{1,2}), a'_i^j_,kl')

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
simplifyAssertEq( (g'^kl' * (d'_klj' + d'_jlk' - d'_ljk')):symmetrizeIndexes(g, {1,2}), g'^kl' * (d'_klj' + d'_jkl' - d'_kjl') )
simplifyAssertEq( (g'^kl' * (d'_klj' + d'_jlk' - d'_ljk')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}), g'^kl' * (d'_kjl' + d'_jkl' - d'_kjl') )
simplifyAssertEq( (g'^kl' * (d'_klj' + d'_jlk' - d'_ljk')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3})(), g'^kl' * d'_jkl' )

-- same with all-lower
simplifyAssertEq( (g'_kl' * (d'^kl_j' + d'_j^lk' - d'^l_j^k')):symmetrizeIndexes(g, {1,2}), g'_kl' * (d'^kl_j' + d'_j^kl' - d'^k_j^l') )
simplifyAssertEq( (g'_kl' * (d'^kl_j' + d'_j^lk' - d'^l_j^k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}), g'_kl' * (d'^k_j^l' + d'_j^kl' - d'^k_j^l') )
simplifyAssertEq( (g'_kl' * (d'^kl_j' + d'_j^lk' - d'^l_j^k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3})(), g'_kl' * d'_j^kl' )

-- same with mixed upper/lower
simplifyAssertEq( (delta'_k^l' * (d'^k_lj' + d'_jl^k' - d'_lj^k')):symmetrizeIndexes(delta, {1,2}), delta'_k^l' * (d'^k_lj' + d'_j^k_l' - d'^k_jl') )
simplifyAssertEq( (delta'_k^l' * (d'^k_lj' + d'_jl^k' - d'_lj^k')):symmetrizeIndexes(delta, {1,2}):symmetrizeIndexes(d, {2,3}), delta'_k^l' * (d'^k_jl' + d'_j^k_l' - d'^k_jl') )
simplifyAssertEq( (delta'_k^l' * (d'^k_lj' + d'_jl^k' - d'_lj^k')):symmetrizeIndexes(delta, {1,2}):symmetrizeIndexes(d, {2,3})(), delta'_k^l' * d'_j^k_l' )

-- how about with commas?  don't forget, you can't exchange comma positions, even if you override errors, because commas cannot precede non-comma indexes.
-- in fact, I vote yes, because of exchaning labels of indexes. g^ab t_a,b = g^ab t_b,a regardless of any symmetry between t_a,b and t_b,a.
-- assertError(function() (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}) end)
-- assertError(function() (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}) end)
-- assertError(function() (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3})() end)

simplifyAssertEq( (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}), g'^kl' * (d'_kl,j' + d'_jk,l' - d'_kj,l') )
simplifyAssertEq( (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}, true), g'^kl' * (d'_kj,l' + d'_jk,l' - d'_kj,l') )
simplifyAssertEq( (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}, true)(), g'^kl' * d'_jk,l' )

simplifyAssertEq( (d'^d_dc'):symmetrizeIndexes(d, {2,3}), d'^d_cd')	-- this is working
simplifyAssertEq( (a'^c' * d'^d_dc'):symmetrizeIndexes(d, {2,3}), a'^c' * d'^d_cd')	-- this is failing

simplifyAssertEq( (g'_ab' * a'^bac'):symmetrizeIndexes(g, {1,2}), g'_ab' * a'^abc')
simplifyAssertEq( (g'_ab' * a'^bac' * g'_ef' * b'^feg' ):symmetrizeIndexes(g, {1,2}), g'_ab' * a'^abc' * g'_ef' * b'^efg')

assertError(function() ( g'^ab' * b'_a,b' ):symmetrizeIndexes(b, {1,2}) end)		-- can't symmetrize b_a,b without override
assertError(function() ( b'^a_,b' ):symmetrizeIndexes(b, {1,2}) end)				-- can't symmetrize b^a_,b without override
simplifyAssertEq( ( g'^ba' * b'_a,b' ):symmetrizeIndexes(g, {1,2}), g'^ab' * b'_a,b' )		-- you can indirectly symmetrize b_a,b without override

simplifyAssertEq(( d'^ab' * b'_b,a' ):symmetrizeIndexes(d, {1,2}), d'^ab' * b'_a,b')			-- fine
simplifyAssertEq(( d'_ab' * b'^b,a' ):symmetrizeIndexes(d, {1,2}), d'_ab' * b'^a,b')			-- fine
simplifyAssertEq(( d'^a_b' * b'^b_,a' ):symmetrizeIndexes(d, {1,2}), d'^a_b' * b'^b_,a')		-- you can't indirectly symmetrize b^a_,b without override ... but because it's indirect, don't cause an error, just skip it.
simplifyAssertEq(( d'^a_b' * b'^b_,a' ):symmetrizeIndexes(d, {1,2}, true), d'^a_b' * b'_a^,b')	-- if you override, then fine , but maybe care about the commas and upper/lower a bit more? maybe not, it's overridden anyways

]=]), '\n')) do
	env.exec(line)
end

env.done()
end)
