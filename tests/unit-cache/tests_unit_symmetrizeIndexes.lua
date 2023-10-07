{
	{code="", comment="fundamentally, is this a function to simplify symmetries that are obvious? such as derivative symmetries, i.e. a_,ji == a_,ij", duration=7.000000000007e-06},
	{code="", comment="or is this meant to dictate symmetries of non-derivative tensor values (but not derivatives)?  i.e. g_ji,lk = g_ij,kl", duration=5.000000000005e-06},
	{code="", comment="or is this meant to dictate values anyhow anywhere?  i.e. a_i,j == a_j,i", duration=4.9999999999911e-06},
	{code="", comment="I'm leaning towards #1 and #2 but not #3", duration=3.9999999999901e-06},
	{code="", comment="so use this for symmetries of derivatives and non-derivatives", duration=4.9999999999911e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="SO THE TAKE-AWAY ...", duration=4.9999999999911e-06},
	{code="", comment="1) swap variance with symbol.", duration=4.9999999999911e-06},
	{code="", comment="2) assert the derivative type of the index match, error if they don't.", duration=5.000000000005e-06},
	{code="", comment="2.5) if all indexes have commas then error if any are upper (unless all are covariant derivatives)", duration=5.000000000005e-06},
	{code="", comment="3) allow an override for non-matching commas ... don't swap comma.  still do swap variance.", duration=5.000000000005e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq( a'_ji':symmetrizeIndexes(a,{1,2}), a'_ij')",
		comment="",
		duration=0.005867,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=8.000000000008e-06},
	{code="", comment="TODO in the case of 3 this isn't used so often", duration=5.9999999999782e-06},
	{
		code="simplifyAssertEq( a'_kji':symmetrizeIndexes(a,{1,2,3}), a'_ijk')",
		comment="",
		duration=0.003107,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'_jki':symmetrizeIndexes(a,{1,2,3}), a'_ijk')",
		comment="",
		duration=0.003449,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'_jik':symmetrizeIndexes(a,{1,2,3}), a'_ijk')",
		comment="",
		duration=0.002294,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=7.000000000007e-06},
	{code="", comment="TODO make sure this works when?", duration=6.000000000006e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="maintain raise/lower", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq( a'_j^i':symmetrizeIndexes(a,{1,2}), a'^i_j')",
		comment="",
		duration=0.002915,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="don't symmetrize a comma and a non-comma (should I restrict this?)", duration=4.9999999999772e-06},
	{
		code="assertError(function() a'_j,i':symmetrizeIndexes(a,{1,2}) end)",
		comment="",
		duration=0.00045699999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="do allow with override", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq(a'_j,i':symmetrizeIndexes(a,{1,2},true), a'_i,j')",
		comment="",
		duration=0.002496,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="do symmetrize two commas", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq( a'_,ji':symmetrizeIndexes(a,{1,2}), a'_,ij')",
		comment="",
		duration=0.002519,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'_,kji':symmetrizeIndexes(a,{1,2,3}), a'_,ijk')",
		comment="",
		duration=0.001782,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'_,jki':symmetrizeIndexes(a,{1,2,3}), a'_,ijk')",
		comment="",
		duration=0.002565,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'_,jik':symmetrizeIndexes(a,{1,2,3}), a'_,ijk')",
		comment="",
		duration=0.00232,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq( a'_ji,lk':symmetrizeIndexes(a,{1,2}):symmetrizeIndexes(a,{3,4}), a'_ij,kl')",
		comment="",
		duration=0.002398,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertError(function() a'_ji,lk':symmetrizeIndexes(a,{2,3}) end)",
		comment="",
		duration=0.00036,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(a'_jl,ik':symmetrizeIndexes(a,{2,3},true), a'_ji,lk')",
		comment="",
		duration=0.002435,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=7.000000000007e-06},
	{code="", comment="if a_ij = a_ji", duration=8.000000000008e-06},
	{code="", comment="then a^i_j = g^ik a_kj = g^ik a_jk = a_j^i", duration=6.000000000006e-06},
	{code="", comment="and a^i_j,k = (g^im a_mj)_,k = g^im_,k a_mj + g^im a_mj,k = g^im_,k a_jm + g^im a_jm,k = (g^im a_jm)_,k = a_j^i_,k", duration=6.000000000006e-06},
	{code="", comment="so even symmetries with non-matching variance that are wrapped in derivatives can be symmetrized", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq( a'_j^i_,k':symmetrizeIndexes(a,{1,2}), a'^i_j,k')",
		comment="",
		duration=0.00385,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'_ji,k':symmetrizeIndexes(a,{1,2}), a'_ij,k')",
		comment="",
		duration=0.002231,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'^ji_,k':symmetrizeIndexes(a,{1,2}), a'^ij_,k')",
		comment="",
		duration=0.001947,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="same if the comma is raised? a_ij==a_ji <=> a_i^j,k==a^j_i^,k ?", duration=5.000000000005e-06},
	{code="", comment="how about if multiple commas are upper?  <=> a^i,jk == a^i,kj ?", duration=5.000000000005e-06},
	{code="", comment="a^i,jk = (g^im a_m)^,jk = ((g^im a_m)_,n g^nj)_,p g^pk", duration=4.9999999999772e-06},
	{code="", comment="= ((g^im a_m)_,np g^nj + (g^im a_m)_,n g^nj_,p) g^pk", duration=4.9999999999772e-06},
	{code="", comment="= (g^im a_m)_,np g^pk g^nj + (g^im a_m)_,n g^nj_,p g^pk", duration=4.9999999999772e-06},
	{code="", comment="= (g^im_,n a_m + g^im a_m,n)_,p g^pk g^nj + (g^im_,n a_m + g^im a_m,n) g^nj_,p g^pk", duration=5.000000000005e-06},
	{code="", comment="= g^im_,np g^pk g^nj a_m + g^im_,n a_m,p g^pk g^nj + g^im_,p a_m,n g^pk g^nj + g^im_,n a_m g^nj_,p g^pk + g^im a_m,n g^nj_,p g^pk + a_m,np g^im g^pk g^nj", duration=5.000000000005e-06},
	{code="", comment="so it doesn't look like these match", duration=5.000000000005e-06},
	{code="", comment="= g^im_,np g^pk g^nj a_m + g^im_,n a_m,p g^pk g^nj + g^im_,p a_m,n g^pk g^nj + g^im_,n a_m g^nk_,p g^pj + g^im a_m,n g^nk_,p g^pj + a_m,np g^im g^pk g^nj", duration=5.000000000005e-06},
	{code="", comment="= a_m g^im_,np g^pj g^nk + g^im_,n a_m,p g^pj g^nk + g^im_,p a_m,n g^pj g^nk + g^im a_m,np g^pj g^nk + g^im_,n a_m g^nk_,p g^pj + g^im a_m,n g^nk_,p g^pj", duration=5.000000000005e-06},
	{code="", comment="= a^i,kj", duration=5.000000000005e-06},
	{code="", comment="this looks like a job for my CAS ... but it isn't looking like upper commas can be assumed to be symmetric", duration=5.000000000005e-06},
	{code="", comment="so commas can only be symmetrized if they are all lowered", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq(a'_i,kj':symmetrizeIndexes(a,{2,3}), a'_i,jk')",
		comment="",
		duration=0.001722,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="but if they are upper then cause an error", duration=5.000000000005e-06},
	{
		code="assertError(function() a'_i^,jk':symmetrizeIndexes(a,{2,3}) end)",
		comment="",
		duration=0.00057599999999999,
		simplifyStack={}
	},
	{code="", comment="unless explicitly overridden", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(a'_i^,kj':symmetrizeIndexes(a,{2,3},true), a'_i^,jk')",
		comment="",
		duration=0.002449,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="if you symmetrize non-lower-matching that are encased in deriv indexes ... still fine. (even if the derivs are upper?)", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq( a'^j_i,kl':symmetrizeIndexes(a,{1,2}), a'_i^j_,kl')",
		comment="",
		duration=0.002192,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="TODO test for also sort any multiplied tensors?", duration=5.000000000005e-06},
	{code="", comment="another thing symmetrizing can do ...", duration=5.000000000005e-06},
	{code="", comment="g^kl (d_klj + d_jlk - d_ljk)  symmetrize g {1,2}", duration=5.000000000005e-06},
	{code="", comment="... not only sort g^kl", duration=4.9999999999772e-06},
	{code="", comment="but also sort all indexes in all multiplied expressions which use 'k' or 'l'", duration=4.9999999999772e-06},
	{code="", comment="so this would become", duration=4.9999999999772e-06},
	{code="", comment="g^kl (d_klj + d_jkl - d_kjl)", duration=5.000000000005e-06},
	{code="", comment="then another symmetrize d {2,3} gives us", duration=5.000000000005e-06},
	{code="", comment="g^kl (d_kjl + d_jkl - d_kjl)", duration=5.000000000005e-06},
	{code="", comment="g^kl d_jkl", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq( (g'^kl' * (d'_klj' + d'_jlk' - d'_ljk')):symmetrizeIndexes(g, {1,2}), g'^kl' * (d'_klj' + d'_jkl' - d'_kjl') )",
		comment="",
		duration=0.028582,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:flatten", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'^kl' * (d'_klj' + d'_jlk' - d'_ljk')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}), g'^kl' * (d'_kjl' + d'_jkl' - d'_kjl') )",
		comment="",
		duration=0.011769,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:flattenAddMul", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'^kl' * (d'_klj' + d'_jlk' - d'_ljk')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3})(), g'^kl' * d'_jkl' )",
		comment="",
		duration=0.010709,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="same with all-lower", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq( (g'_kl' * (d'^kl_j' + d'_j^lk' - d'^l_j^k')):symmetrizeIndexes(g, {1,2}), g'_kl' * (d'^kl_j' + d'_j^kl' - d'^k_j^l') )",
		comment="",
		duration=0.020058,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:flatten", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'_kl' * (d'^kl_j' + d'_j^lk' - d'^l_j^k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}), g'_kl' * (d'^k_j^l' + d'_j^kl' - d'^k_j^l') )",
		comment="",
		duration=0.009787,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:flattenAddMul", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'_kl' * (d'^kl_j' + d'_j^lk' - d'^l_j^k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3})(), g'_kl' * d'_j^kl' )",
		comment="",
		duration=0.007566,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{code="", comment="same with mixed upper/lower", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq( (delta'_k^l' * (d'^k_lj' + d'_jl^k' - d'_lj^k')):symmetrizeIndexes(delta, {1,2}), delta'_k^l' * (d'^k_lj' + d'_j^k_l' - d'^k_jl') )",
		comment="",
		duration=0.020038,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:flatten", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (delta'_k^l' * (d'^k_lj' + d'_jl^k' - d'_lj^k')):symmetrizeIndexes(delta, {1,2}):symmetrizeIndexes(d, {2,3}), delta'_k^l' * (d'^k_jl' + d'_j^k_l' - d'^k_jl') )",
		comment="",
		duration=0.006605,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:flattenAddMul", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (delta'_k^l' * (d'^k_lj' + d'_jl^k' - d'_lj^k')):symmetrizeIndexes(delta, {1,2}):symmetrizeIndexes(d, {2,3})(), delta'_k^l' * d'_j^k_l' )",
		comment="",
		duration=0.003941,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{code="", comment="how about with commas?  don't forget, you can't exchange comma positions, even if you override errors, because commas cannot precede non-comma indexes.", duration=4.000000000004e-06},
	{code="", comment="in fact, I vote yes, because of exchaning labels of indexes. g^ab t_a,b = g^ab t_b,a regardless of any symmetry between t_a,b and t_b,a.", duration=5.0000000000328e-06},
	{code="", comment="assertError(function() (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}) end)", duration=5.0000000000328e-06},
	{code="", comment="assertError(function() (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}) end)", duration=4.000000000004e-06},
	{code="", comment="assertError(function() (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3})() end)", duration=4.9999999999772e-06},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq( (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}), g'^kl' * (d'_kl,j' + d'_jk,l' - d'_kj,l') )",
		comment="",
		duration=0.017799,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:flatten", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}, true), g'^kl' * (d'_kj,l' + d'_jk,l' - d'_kj,l') )",
		comment="",
		duration=0.006925,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:flattenAddMul", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'^kl' * (d'_kl,j' + d'_jl,k' - d'_lj,k')):symmetrizeIndexes(g, {1,2}):symmetrizeIndexes(d, {2,3}, true)(), g'^kl' * d'_jk,l' )",
		comment="",
		duration=0.005763,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq( (d'^d_dc'):symmetrizeIndexes(d, {2,3}), d'^d_cd')",
		comment="this is working",
		duration=0.001231,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (a'^c' * d'^d_dc'):symmetrizeIndexes(d, {2,3}), a'^c' * d'^d_cd')",
		comment="this is failing",
		duration=0.002958,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq( (g'_ab' * a'^bac'):symmetrizeIndexes(g, {1,2}), g'_ab' * a'^abc')",
		comment="",
		duration=0.005044,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'_ab' * a'^bac' * g'_ef' * b'^feg' ):symmetrizeIndexes(g, {1,2}), g'_ab' * a'^abc' * g'_ef' * b'^efg')",
		comment="",
		duration=0.011691,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{
		code="assertError(function() ( g'^ab' * b'_a,b' ):symmetrizeIndexes(b, {1,2}) end)",
		comment="can't symmetrize b_a,b without override",
		duration=0.00025500000000001,
		simplifyStack={}
	},
	{
		code="assertError(function() ( b'^a_,b' ):symmetrizeIndexes(b, {1,2}) end)",
		comment="can't symmetrize b^a_,b without override",
		duration=0.00017699999999998,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq( ( g'^ba' * b'_a,b' ):symmetrizeIndexes(g, {1,2}), g'^ab' * b'_a,b' )",
		comment="you can indirectly symmetrize b_a,b without override",
		duration=0.002372,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="simplifyAssertEq(( d'^ab' * b'_b,a' ):symmetrizeIndexes(d, {1,2}), d'^ab' * b'_a,b')",
		comment="fine",
		duration=0.00202,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(( d'_ab' * b'^b,a' ):symmetrizeIndexes(d, {1,2}), d'_ab' * b'^a,b')",
		comment="fine",
		duration=0.00366,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(( d'^a_b' * b'^b_,a' ):symmetrizeIndexes(d, {1,2}), d'^a_b' * b'^b_,a')",
		comment="you can't indirectly symmetrize b^a_,b without override ... but because it's indirect, don't cause an error, just skip it.",
		duration=0.002319,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(( d'^a_b' * b'^b_,a' ):symmetrizeIndexes(d, {1,2}, true), d'^a_b' * b'_a^,b')",
		comment="if you override, then fine , but maybe care about the commas and upper/lower a bit more? maybe not, it's overridden anyways",
		duration=0.0037,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	}
}