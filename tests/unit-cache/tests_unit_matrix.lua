{
	{
		code="printbr(Array(1,2,3))",
		comment="",
		duration=0.00015800000000001,
		simplifyStack={}
	},
	{
		code="printbr(Array(1,2) + Array(3,4))",
		comment="",
		duration=0.00049399999999999,
		simplifyStack={}
	},
	{
		code="printbr((Array(1,2) + Array(3,4))())",
		comment="",
		duration=0.001738,
		simplifyStack={"Init", "+:Prune:combineConstants", "+:Prune:combineConstants", "+:Prune:Array.pruneAdd", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((Array(1,2) + Array(3,4))(), Array(4,6))",
		comment="",
		duration=0.002706,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Matrix({1,2},{3,4}))",
		comment="",
		duration=0.000274,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({1,2},{3,4}):inverse())",
		comment="",
		duration=0.015925,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "/:Prune:xOverMinusOne", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({1,2},{3,4}):inverse(), Matrix({-2,1},{frac(3,2),-frac(1,2)}))",
		comment="",
		duration=0.012646,
		simplifyStack={"Init", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(Matrix({a,b},{c,d}))",
		comment="",
		duration=0.00018,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({a,b},{c,d}):inverse())",
		comment="",
		duration=0.072577,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:factorDenominators", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({a,b},{c,d}):inverse(), Matrix( {frac(d, a*d-b*c), frac(-b, a*d-b*c)}, {frac(-c, a*d-b*c), frac(a, a*d-b*c)} ))",
		comment="",
		duration=0.106263,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}))",
		comment="",
		duration=0.00063000000000002,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse())",
		comment="",
		duration=0.012698,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse(), Matrix({1,0,0,-t_x},{0,1,0,-t_y},{0,0,1,-t_z},{0,0,0,1}))",
		comment="",
		duration=0.011207,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m + mInv)",
		comment="",
		duration=0.001029,
		simplifyStack={}
	},
	{
		code="printbr((m + mInv)())",
		comment="",
		duration=0.006181,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:flattenAddMul", "*:Prune:apply", "+:Prune:flattenAddMul", "+:Prune:Array.pruneAdd", "*:Prune:apply", "+:Prune:flattenAddMul", "+:Prune:flattenAddMul", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(m * mInv)",
		comment="",
		duration=0.00108,
		simplifyStack={}
	},
	{
		code="printbr((m * mInv)())",
		comment="",
		duration=0.008676,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (m*mInv)(), Matrix({1,0},{0,1}) )",
		comment="",
		duration=0.016146,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m*m)",
		comment="",
		duration=0.00059599999999999,
		simplifyStack={}
	},
	{
		code="printbr((m*m)())",
		comment="",
		duration=0.027817,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "+:Prune:combineMultipliedConstants", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "+:Factor:apply", "+:Factor:apply", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m1)",
		comment="",
		duration=8.9999999999979e-05,
		simplifyStack={}
	},
	{
		code="printbr(m2)",
		comment="",
		duration=4.8999999999966e-05,
		simplifyStack={}
	},
	{
		code="printbr((m1*m2):eq((m1*m2)()))",
		comment="",
		duration=0.002454,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m2*m1):eq((m2*m1)()))",
		comment="",
		duration=0.002352,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(m1:eq(m2))",
		comment="",
		duration=0.00032199999999999,
		simplifyStack={}
	},
	{
		code="simplifyAssertNe(m1, m2)",
		comment="",
		duration=0.00047799999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m2*m1))",
		comment="",
		duration=0.00057299999999999,
		simplifyStack={}
	},
	{
		code="simplifyAssertNe(m1*m2, m2*m1)",
		comment="",
		duration=0.004022,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m1*m2))",
		comment="",
		duration=0.00041000000000002,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(m1*m2, m1*m2)",
		comment="",
		duration=0.004087,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m2*m1)())",
		comment="",
		duration=0.003873,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe((m1*m2)(), (m2*m1)())",
		comment="",
		duration=0.004261,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((Matrix({a},{b}) + Matrix({c},{d})) / t)",
		comment="",
		duration=0.00042700000000001,
		simplifyStack={}
	},
	{
		code="printbr(((Matrix({a},{b}) + Matrix({c},{d})) / t)())",
		comment="",
		duration=0.00843,
		simplifyStack={"Init", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( ((Matrix({a},{b}) + Matrix({c},{d})) / t)(), Matrix({frac(a+c,t)}, {frac(b+d,t)}) )",
		comment="",
		duration=0.014137,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="printbr(Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))",
		comment="",
		duration=0.005967,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr((Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))())",
		comment="",
		duration=0.009601,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))(), Matrix({5},{6}) )",
		comment="",
		duration=0.007955,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}