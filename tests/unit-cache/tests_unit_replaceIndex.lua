{
	{
		code="simplifyAssertEq( a:replaceIndex(a, b), b )",
		comment="if there are no indexes in the expr or in find then it falls back on 'replace'",
		duration=0.000636,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( a'_a':replaceIndex(a'^u', b'^u'), a'_a' )",
		comment="variance must match in order for the replace to work",
		duration=0.002265,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'^a':replaceIndex(a'^b', b'^b'), b'^a' )",
		comment="",
		duration=0.00159,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'^a':replaceIndex(a'^b', b'^b' + c'^b'), b'^a' + c'^a' )",
		comment="",
		duration=0.005457,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'^a':replaceIndex(a'^b', b'^bc' * c'_c'), b'^ab' * c'_b' )",
		comment="the sum indexes won't use the same symbol, because the symbols are not preserved and instead chosen among unused symbols in the result expression",
		duration=0.004229,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'^a':replaceIndex(a'^b', b'^b' + c'^bc' * d'_c'), b'^a' + c'^ab' * d'_b' )",
		comment="",
		duration=0.00632,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( a'_ab':replaceIndex(a'_uv', b'_uv'), b'_ab' )",
		comment="",
		duration=0.00158,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'_ab':replaceIndex(a'_uv', b'_vu'), b'_ba' )",
		comment="",
		duration=0.001583,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'_ba':replaceIndex(a'_uv', b'_vu'), b'_ab' )",
		comment="",
		duration=0.001072,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'_ab':replaceIndex(a'_vu', b'_uv'), b'_ba' )",
		comment="",
		duration=0.001313,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'_ba':replaceIndex(a'_vu', b'_uv'), b'_ab' )",
		comment="",
		duration=0.001286,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (g'^am' * c'_mbc'):replaceIndex( g'^am' * c'_mbc', c'^a_bc' ), c'^a_bc')",
		comment="",
		duration=0.001951,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'^am' * c'_mbc'):replaceIndex( g'^an' * c'_nbc', c'^a_bc' ), c'^a_bc')",
		comment="mapping the sum index",
		duration=0.001702,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'^am' * c'_mbc'):replaceIndex( g'^im' * c'_mjk', c'^i_jk' ), c'^a_bc')",
		comment="mapping the fixed indexes",
		duration=0.001697,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'^am' * c'_mbc'):replaceIndex( g'^id' * c'_djk', c'^i_jk' ), c'^a_bc')",
		comment="mapping both",
		duration=0.001411,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( (a'_a' + b'_ab' * c'^b'):replaceIndex(a'_u', b'_u'), b'_a' + b'_ab' * c'^b' )",
		comment="",
		duration=0.003929,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', c'_uv'), a'_a' + c'_ab' * c'^b' )",
		comment="TODO this should preserve the order of b_ab -> c_ab",
		duration=0.003968,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', d'_uv'), a'_a' + d'_ab' * c'^b' )",
		comment="TODO this should preserve the order of b_ab -> d_ab",
		duration=0.004,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( a'^a_a':replaceIndex(a'^a_a', b'^a_a'), b'^a_a')",
		comment="",
		duration=0.001072,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'^a_a':replaceIndex(a'^u_u', b'^u_u'), b'^a_a')",
		comment="",
		duration=0.00082299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{
		code="simplifyAssertEq( (a'^a_a' * a'^b_b'):replaceIndex(a'^u_u', b'^u_u'), b'^a_a' * b'^b_b')",
		comment="",
		duration=0.002387,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( a'^a_ab':replaceIndex(a'^a_ab', b'_b'), b'_b' )",
		comment="",
		duration=0.00075099999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'^a_ab':replaceIndex(a'^a_ab', b'_b' + c'_a^a_b'), b'_b' + c'_a^a_b' )",
		comment="",
		duration=0.004389,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="hmm, how to account for this?  if the fixed indexes don't match then I still want it to fall back on a plain replace()", duration=0},
	{
		code="simplifyAssertEq( a'_t':replaceIndex(a'_t', b), b)",
		comment="",
		duration=0.00027400000000001,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq( a'_t':replaceIndex(a'_t', b'_u'), b'_u')",
		comment="",
		duration=0.000514,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="but in the event of a regular replace, I still want it to not collide sum indexes", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (a'_t' * b'^a_a'):replaceIndex(a'_t', c'_u' * d'^a_a'), c'_u' * b'^a_a' * d'^b_b')",
		comment="",
		duration=0.002935,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="what does this mean? the fixed indexes shouldn't have to match ...", duration=1.000000000001e-06},
	{code="", comment="if they don't match then assume they are not correlated between the 'find' and 'replace'", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (a'_ij' + c'_,t' * b'_ij'):replaceIndex( c'_,t', c * d'^i_i' ), a'_ij' + c * d'^a_a' * b'_ij' )",
		comment="",
		duration=0.008969,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (a'_ab' + c'_,t' * b'_ab'):replaceIndex( c'_,t', c * d'^a_a' ), a'_ab' + c * d'^c_c' * b'_ab' )",
		comment="",
		duration=0.006029,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO so it looks like, when the replace expression has sum terms *AND* it is an Expression instead of just a TensorRef", duration=1.000000000001e-06},
	{code="", comment="that's when the sum indexes aren't replaced correctly", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (a'_ij' + c'_,t' * b'_ij'):replaceIndex( c'_,t', c * d'^i_i' + e'^i_i' ), a'_ij' + (c * d'^a_a' + e'^a_a') * b'_ij' )",
		comment="",
		duration=0.01435,
		simplifyStack={"Init", "Prune", "*:Expand:apply", "Expand", "*:Prune:flatten", "+:Prune:flatten", "Prune", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="printbr( g'_ij,t':eq(d * (d * b'^k_,i' * g'_kj' + d * b'^k_,j' * g'_ki' + d * b'^k' * c'_ijk' + d * b'^k' * c'_jik' + 2 * d'_,t' * g'_ij' - 2 * d * a * e'_ij') ):replaceIndex( d'_,t',  frac(1,3) * (3 * d'_,i' * b'^i' - d * b'^i_,i' - frac(1,2) * d * b'^i' * g'_,i' / g + e * d * a) ) )",
		comment="",
		duration=0.007107,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="only if extra indexes match.  in this case, extra is 'k'.", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (g'_ab,t' * g'_cd,e'):replaceIndex(g'_ij,k', c'_ij'), g'_ab,t' * g'_cd,e')",
		comment="",
		duration=0.002723,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (g'_ab,t' * g'_cd,e'):replaceIndex(g'_ij,t', c'_ij'), c'_ab' * g'_cd,e')",
		comment="",
		duration=0.001867,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO make sure summed indexes aren't matched incorreclty", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( a'^a_a':replaceIndex( a'^a_b', b'^a_b'), b'^a_a')",
		comment="replaceIndex with more general indexes should work",
		duration=0.00070299999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'^a_b':replaceIndex( a'^a_a', b'^a_a'), a'^a_b')",
		comment="replaceIndex with more specific (summed) indexes shouldn't",
		duration=0.00047999999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (a'^a_b' * a'^c_c'):replaceIndex( a'^a_a', b'^a_a'), (a'^a_b' * b'^c_c'))",
		comment="and the two should be discernable",
		duration=0.001527,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="same but replace with scalars", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( a'^a_a':replaceIndex( a'^a_b', b), a'^a_a')",
		comment="in this case, a^a_b's indexes are considered extra since they are not in b as well, so they will be exactly matched in the expression.  since no a^a_b exists, it will not match and not replace.",
		duration=0.00065099999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( a'^a_b':replaceIndex( a'^a_a', b), a'^a_b')",
		comment="",
		duration=0.000468,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (a'^a_b' * a'^c_c'):replaceIndex( a'^a_a', b), (a'^a_b' * b))",
		comment="",
		duration=0.00391,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="printbr( d'_,t':eq( frac(1,6) * ( d * ( 2 * e * a - b'^k_,i' * g'^ij' * g'_jk' - b'^k_,j' * g'_ik' * g'^ij' - b'^k' * g'^ij' * g'_ij,k' ) )):replaceIndex( g'_ij', c'_ij' / d^2  ) )",
		comment="",
		duration=0.003481,
		simplifyStack={}
	},
	{
		code="printbr( d'_,t':eq( 2 * e * a - b'^k_,i' * g'^ij' * g'_jk' - b'^k_,j' * g'_ik' * g'^ij' - b'^k' * g'^ij' * g'_ij,k' ):replaceIndex( g'_ij', c'_ij' / d^2  ) )",
		comment="",
		duration=0.002311,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq( d'_,t':eq( b'^k_,i' * g'^ij' * g'_jk' ):replaceIndex( g'_ij', c'_ij' / d^2  ), d'_,t':eq(b'^k_,i' * g'^ij' * c'_jk' / d^2) )",
		comment="",
		duration=0.018194,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "^:ExpandPolynomial:apply", "+:Prune:combineConstants", "*:Prune:combinePows", "/:Factor:polydiv", "Factor", "*:Prune:flatten", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( d'_,t':eq( g'^jk' * g'_jk' ):replaceIndex( g'_ij', c'_ij' / d^2  ), d'_,t':eq( g'^jk' * c'_jk' / d^2) )",
		comment="",
		duration=0.012928,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "^:ExpandPolynomial:apply", "+:Prune:combineConstants", "*:Prune:combinePows", "/:Factor:polydiv", "Factor", "*:Prune:flatten", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="does fixed in the find/repl to map into sums in the expr", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( a'^i_i':replaceIndex(a'^i_j', b'^i_j'), b'^i_i')",
		comment="",
		duration=0.00059200000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="why do neither of these work?  because if there are *only* sum-indexes won't match, however if there are extra indexes then it will match.  why do we have this constraint again?", duration=1.000000000001e-06},
	{code="", comment="internal sum indexes do seem to work in replaceIndex, like A^a_a, but externally shared between two tensors don't: A^a * A_a ... why distinguish?", duration=1.000000000001e-06},
	{
		code="print( (a'^a' * a'_a'):replaceIndex(a'^a' * a'_a', 2))",
		comment="",
		duration=0.000529,
		simplifyStack={}
	},
	{
		code="print( (a'^a' * a'_a'):replaceIndex(a'^a' * a'_a', b'^a' * b'_a'))",
		comment="",
		duration=0.00049099999999999,
		simplifyStack={}
	},
	{
		code="print( (c'_b' * a'^a' * a'_a'):replaceIndex(c'_b' * a'^a' * a'_a', 2))",
		comment="",
		duration=0.00046399999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=1.9999999999742e-06},
	{code="", comment="and what about when find/replace has a partial number of fixed indexes", duration=0},
	{
		code="assertError(function() return (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', c'_bv') end )",
		comment="what should this produce?  Technically it is invalid match, since the from and to don't have matching fixed indexes.  So... assert error?",
		duration=0.00037999999999999,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: expected an error, but found none\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:247: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:246>\n\9[C]: in function 'assert'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'assertError'\n\9[string \"assertError(function() return (a'_a' + b'_ab'...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:239: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:238>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function 'exec'\n\9replaceIndex.lua:136: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9replaceIndex.lua:6: in main chunk\n\9[C]: at 0x56360b4372f0",
		simplifyStack={}
	}
}