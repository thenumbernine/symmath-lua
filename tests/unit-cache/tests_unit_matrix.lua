{
	{
		code="printbr(Array(1,2,3))",
		comment="",
		duration=8.1000000000001e-05,
		simplifyStack={}
	},
	{
		code="printbr(Array(1,2) + Array(3,4))",
		comment="",
		duration=7.3e-05,
		simplifyStack={}
	},
	{
		code="printbr((Array(1,2) + Array(3,4))())",
		comment="",
		duration=0.000928,
		simplifyStack={"Init", "+:Prune:combineConstants", "+:Prune:combineConstants", "+:Prune:Array.pruneAdd", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((Array(1,2) + Array(3,4))(), Array(4,6))",
		comment="",
		duration=0.001128,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Matrix({1,2},{3,4}))",
		comment="",
		duration=9.3999999999997e-05,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({1,2},{3,4}):inverse())",
		comment="",
		duration=0.007055,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "/:Prune:xOverMinusOne", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({1,2},{3,4}):inverse(), Matrix({-2,1},{frac(3,2),-frac(1,2)}))",
		comment="",
		duration=0.008714,
		simplifyStack={"Init", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(Matrix({a,b},{c,d}))",
		comment="",
		duration=8.4999999999995e-05,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({a,b},{c,d}):inverse())",
		comment="",
		duration=0.039161,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:factorDenominators", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "+:Factor:apply", "/:Factor:polydiv", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({a,b},{c,d}):inverse(), Matrix( {frac(d, a*d-b*c), frac(-b, a*d-b*c)}, {frac(-c, a*d-b*c), frac(a, a*d-b*c)} ))",
		comment="",
		duration=0.056694,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Tidy:apply", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}))",
		comment="",
		duration=0.00047799999999998,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse())",
		comment="",
		duration=0.006084,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse(), Matrix({1,0,0,-t_x},{0,1,0,-t_y},{0,0,1,-t_z},{0,0,0,1}))",
		comment="",
		duration=0.008067,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m + mInv)",
		comment="",
		duration=0.00047800000000001,
		simplifyStack={}
	},
	{
		code="printbr((m + mInv)())",
		comment="",
		duration=0.00575,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:flattenAddMul", "*:Prune:apply", "+:Prune:flattenAddMul", "+:Prune:Array.pruneAdd", "*:Prune:apply", "+:Prune:flattenAddMul", "+:Prune:flattenAddMul", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(m * mInv)",
		comment="",
		duration=0.001122,
		simplifyStack={}
	},
	{
		code="printbr((m * mInv)())",
		comment="",
		duration=0.006965,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (m*mInv)(), Matrix({1,0},{0,1}) )",
		comment="",
		duration=0.006317,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m*m)",
		comment="",
		duration=0.00039800000000001,
		simplifyStack={}
	},
	{
		code="printbr((m*m)())",
		comment="",
		duration=0.017829,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "+:Prune:combineMultipliedConstants", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "+:Factor:apply", "+:Factor:apply", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m1)",
		comment="",
		duration=0.00014600000000001,
		simplifyStack={}
	},
	{
		code="printbr(m2)",
		comment="",
		duration=5.2999999999997e-05,
		simplifyStack={}
	},
	{
		code="printbr((m1*m2):eq((m1*m2)()))",
		comment="",
		duration=0.002167,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m2*m1):eq((m2*m1)()))",
		comment="",
		duration=0.002947,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(m1:eq(m2))",
		comment="",
		duration=0.000197,
		simplifyStack={}
	},
	{
		code="simplifyAssertNe(m1, m2)",
		comment="",
		duration=0.00028,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m2*m1))",
		comment="",
		duration=0.00043200000000002,
		simplifyStack={}
	},
	{
		code="simplifyAssertNe(m1*m2, m2*m1)",
		comment="",
		duration=0.001907,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m1*m2))",
		comment="",
		duration=0.000275,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(m1*m2, m1*m2)",
		comment="",
		duration=0.001588,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m2*m1)())",
		comment="",
		duration=0.002115,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe((m1*m2)(), (m2*m1)())",
		comment="",
		duration=0.003016,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((Matrix({a},{b}) + Matrix({c},{d})) / t)",
		comment="",
		duration=0.00017,
		simplifyStack={}
	},
	{
		code="printbr(((Matrix({a},{b}) + Matrix({c},{d})) / t)())",
		comment="",
		duration=0.005357,
		simplifyStack={"Init", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( ((Matrix({a},{b}) + Matrix({c},{d})) / t)(), Matrix({frac(a+c,t)}, {frac(b+d,t)}) )",
		comment="",
		duration=0.009274,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="printbr(Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))",
		comment="",
		duration=0.002933,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr((Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))())",
		comment="",
		duration=0.005517,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))(), Matrix({5},{6}) )",
		comment="",
		duration=0.004215,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}