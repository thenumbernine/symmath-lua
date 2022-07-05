{
	{
		code="simplifyAssertEq(#{x:eq(0):solve(x)}, 1)",
		comment="",
		duration=0.001242,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x:eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.002424,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{x:eq(1):solve(x)}, 1)",
		comment="",
		duration=0.00064,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x:eq(1):solve(x), x:eq(1))",
		comment="",
		duration=0.000983,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{(x+1):eq(0):solve(x)}, 1)",
		comment="",
		duration=0.001069,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1):eq(0):solve(x), x:eq(-1))",
		comment="",
		duration=0.001696,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{(x^2):eq(1):solve(x)}, 2)",
		comment="",
		duration=0.003243,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(1):solve(x), x:eq(1))",
		comment="",
		duration=0.002784,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(1):solve(x)), x:eq(-1))",
		comment="",
		duration=0.003488,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{
		code="simplifyAssertEq(#{(x^2):eq(-1):solve(x)}, 2)",
		comment="",
		duration=0.003363,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(-1):solve(x), x:eq(i))",
		comment="",
		duration=0.003143,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(-1):solve(x)), x:eq(-i))",
		comment="",
		duration=0.003708,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="print((x^2):eq(0):solve(x))",
		comment="",
		duration=0.001834,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^2):eq(0):solve(x)}, 2)",
		comment="",
		duration=0.002463,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.002546,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.002112,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with 3 ...", duration=0},
	{
		code="print((x^3):eq(0):solve(x))",
		comment="",
		duration=0.039026,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.031249,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^3):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.02646,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^3):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.026757,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x^3):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.020611,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with 4 ...", duration=1.000000000001e-06},
	{
		code="print((x^4):eq(0):solve(x))",
		comment="",
		duration=0.004997,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "*:Prune:flatten", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^4):eq(0):solve(x)}, 4)",
		comment="",
		duration=0.004746,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^4):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.004953,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.005676,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.005075,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(4, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.004914,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="Deterministic order of roots?", duration=0},
	{code="", comment="For quadratics it is plus sqrt(discr) first then minus", duration=0},
	{code="", comment="For x^n times P(x) it is the zeroes first (TODO how about instead of enumerating all roots, we provide multiplicity, so (x^n):eq(0):solve(x) can return (for n != 0, x=0 n-times)", duration=0},
	{code="", comment="", duration=0},
	{code="", comment="distinguish between x*(x^2 + 2x + 1) and (x^3 + 2x^2 + x) , because the solver handles one but not the other", duration=1.0000000000288e-06},
	{
		code="printbr( (x * (x^2 + 2*x + 1)):eq(0):solve(x)  )",
		comment="",
		duration=0.004251,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:zeroToTheX", "sqrt:Prune:apply", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x * (x^2 + 2*x + 1)):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.00565,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + 2*x + 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.007223,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.004415,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.004308,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="printbr( (x^3 + 2*x^2 + x):eq(0):solve(x) )",
		comment="",
		duration=0.004254,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:zeroToTheX", "sqrt:Prune:apply", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3 + 2*x^2 + x):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.003159,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + 2*x + 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.003767,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.003535,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.004482,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="same with x^3 + x^2 - x", duration=9.9999999997324e-07},
	{
		code="printbr( (x * (x^2 + x - 1)):eq(0):solve(x)  )",
		comment="",
		duration=0.010088,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x * (x^2 + x - 1)):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.00788,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + x - 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.007888,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 + sqrt(5))/2 ))",
		comment="",
		duration=0.016343,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 - sqrt(5))/2 ))",
		comment="",
		duration=0.017926,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Tidy:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="printbr( (x^3 + x^2 - x):eq(0):solve(x) )",
		comment="",
		duration=0.012353,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3 + x^2 - x):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.007813,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + x - 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.007071,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 + sqrt(5))/2 ))",
		comment="",
		duration=0.011969,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 - sqrt(5))/2 ))",
		comment="",
		duration=0.014063,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Tidy:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}