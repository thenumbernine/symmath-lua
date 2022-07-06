{
	{
		code="simplifyAssertEq(#{x:eq(0):solve(x)}, 1)",
		comment="",
		duration=0.001163,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x:eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.002737,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(#{x:eq(1):solve(x)}, 1)",
		comment="",
		duration=0.000915,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x:eq(1):solve(x), x:eq(1))",
		comment="",
		duration=0.001409,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(#{(x+1):eq(0):solve(x)}, 1)",
		comment="",
		duration=0.001156,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1):eq(0):solve(x), x:eq(-1))",
		comment="",
		duration=0.001948,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(#{(x^2):eq(1):solve(x)}, 2)",
		comment="",
		duration=0.003072,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(1):solve(x), x:eq(1))",
		comment="",
		duration=0.00357,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(1):solve(x)), x:eq(-1))",
		comment="",
		duration=0.004294,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(#{(x^2):eq(-1):solve(x)}, 2)",
		comment="",
		duration=0.004179,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(-1):solve(x), x:eq(i))",
		comment="",
		duration=0.004839,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(-1):solve(x)), x:eq(-i))",
		comment="",
		duration=0.004644,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="print((x^2):eq(0):solve(x))",
		comment="",
		duration=0.001741,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^2):eq(0):solve(x)}, 2)",
		comment="",
		duration=0.002745,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.003294,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^2):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.001801,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with 3 ...", duration=0},
	{
		code="print((x^3):eq(0):solve(x))",
		comment="",
		duration=0.037595,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.031708,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^3):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.026919,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^3):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.027604,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x^3):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.021281,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with 4 ...", duration=1.000000000001e-06},
	{
		code="print((x^4):eq(0):solve(x))",
		comment="",
		duration=0.006038,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:zeroToTheX", "*:Prune:apply", "*:Prune:flatten", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^4):eq(0):solve(x)}, 4)",
		comment="",
		duration=0.004405,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^4):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.00624,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.006614,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.007597,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(4, (x^4):eq(0):solve(x)), x:eq(0))",
		comment="",
		duration=0.004228,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="Deterministic order of roots?", duration=9.9999999997324e-07},
	{code="", comment="For quadratics it is plus sqrt(discr) first then minus", duration=9.9999999997324e-07},
	{code="", comment="For x^n times P(x) it is the zeroes first (TODO how about instead of enumerating all roots, we provide multiplicity, so (x^n):eq(0):solve(x) can return (for n != 0, x=0 n-times)", duration=0},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="distinguish between x*(x^2 + 2x + 1) and (x^3 + 2x^2 + x) , because the solver handles one but not the other", duration=0},
	{
		code="printbr( (x * (x^2 + 2*x + 1)):eq(0):solve(x)  )",
		comment="",
		duration=0.003623,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:zeroToTheX", "sqrt:Prune:apply", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x * (x^2 + 2*x + 1)):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.004746,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + 2*x + 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.004409,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.004143,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.004323,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="printbr( (x^3 + 2*x^2 + x):eq(0):solve(x) )",
		comment="",
		duration=0.003866,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:zeroToTheX", "sqrt:Prune:apply", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3 + 2*x^2 + x):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.0030559999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + 2*x + 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.003334,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.003159,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + 2*x + 1)):eq(0):solve(x)), x:eq(-1))",
		comment="",
		duration=0.0044,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="same with x^3 + x^2 - x", duration=9.9999999997324e-07},
	{
		code="printbr( (x * (x^2 + x - 1)):eq(0):solve(x)  )",
		comment="",
		duration=0.011002,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x * (x^2 + x - 1)):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.012321,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + x - 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.012174,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 + sqrt(5))/2 ))",
		comment="",
		duration=0.016097,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 - sqrt(5))/2 ))",
		comment="",
		duration=0.014574,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Tidy:replacePowerOfFractionWithRoots", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="printbr( (x^3 + x^2 - x):eq(0):solve(x) )",
		comment="",
		duration=0.008687,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "^:Prune:simplifyConstantPowers", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(#{(x^3 + x^2 - x):eq(0):solve(x)}, 3)",
		comment="",
		duration=0.009204,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x * (x^2 + x - 1)):eq(0):solve(x), x:eq(0))",
		comment="",
		duration=0.012784,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(2, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 + sqrt(5))/2 ))",
		comment="",
		duration=0.015292,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(select(3, (x * (x^2 + x - 1)):eq(0):solve(x)), x:eq( -(1 - sqrt(5))/2 ))",
		comment="",
		duration=0.013156,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Tidy:replacePowerOfFractionWithRoots", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}