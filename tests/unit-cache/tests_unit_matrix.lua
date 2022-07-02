{
	{
		code="printbr(Array(1,2,3))",
		comment="",
		duration=0.000122,
		simplifyStack={}
	},
	{
		code="printbr(Array(1,2) + Array(3,4))",
		comment="",
		duration=0.000114,
		simplifyStack={}
	},
	{
		code="printbr((Array(1,2) + Array(3,4))())",
		comment="",
		duration=0.001026,
		simplifyStack={"Init", "+:Prune:combineConstants", "+:Prune:combineConstants", "+:Prune:Array.pruneAdd", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((Array(1,2) + Array(3,4))(), Array(4,6))",
		comment="",
		duration=0.00125,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Matrix({1,2},{3,4}))",
		comment="",
		duration=0.000106,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({1,2},{3,4}):inverse())",
		comment="",
		duration=0.006741,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "/:Prune:xOverMinusOne", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({1,2},{3,4}):inverse(), Matrix({-2,1},{frac(3,2),-frac(1,2)}))",
		comment="",
		duration=0.00621,
		simplifyStack={"Init", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(Matrix({a,b},{c,d}))",
		comment="",
		duration=0.0001,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({a,b},{c,d}):inverse())",
		comment="",
		duration=0.038092,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:factorDenominators", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({a,b},{c,d}):inverse(), Matrix( {frac(d, a*d-b*c), frac(-b, a*d-b*c)}, {frac(-c, a*d-b*c), frac(a, a*d-b*c)} ))",
		comment="",
		duration=0.060056,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Tidy:apply", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}))",
		comment="",
		duration=0.000338,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse())",
		comment="",
		duration=0.007028,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse(), Matrix({1,0,0,-t_x},{0,1,0,-t_y},{0,0,1,-t_z},{0,0,0,1}))",
		comment="",
		duration=0.00641,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m + mInv)",
		comment="",
		duration=0.00054299999999999,
		simplifyStack={}
	},
	{
		code="printbr((m + mInv)())",
		comment="",
		duration=0.003177,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:flattenAddMul", "*:Prune:apply", "+:Prune:flattenAddMul", "+:Prune:Array.pruneAdd", "*:Prune:apply", "+:Prune:flattenAddMul", "+:Prune:flattenAddMul", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(m * mInv)",
		comment="",
		duration=0.00065899999999999,
		simplifyStack={}
	},
	{
		code="printbr((m * mInv)())",
		comment="",
		duration=0.003755,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (m*mInv)(), Matrix({1,0},{0,1}) )",
		comment="",
		duration=0.008058,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m*m)",
		comment="",
		duration=0.00048000000000001,
		simplifyStack={}
	},
	{
		code="printbr((m*m)())",
		comment="",
		duration=0.016486,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "+:Prune:combineMultipliedConstants", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "+:Factor:apply", "+:Factor:apply", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m1)",
		comment="",
		duration=0.00020899999999999,
		simplifyStack={}
	},
	{
		code="printbr(m2)",
		comment="",
		duration=0.000247,
		simplifyStack={}
	},
	{
		code="printbr((m1*m2):eq((m1*m2)()))",
		comment="",
		duration=0.00302,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m2*m1):eq((m2*m1)()))",
		comment="",
		duration=0.00173,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(m1:eq(m2))",
		comment="",
		duration=7.4999999999992e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertNe(m1, m2)",
		comment="",
		duration=0.00023099999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m2*m1))",
		comment="",
		duration=0.00034300000000001,
		simplifyStack={}
	},
	{
		code="simplifyAssertNe(m1*m2, m2*m1)",
		comment="",
		duration=0.001626,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m1*m2))",
		comment="",
		duration=0.00053,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(m1*m2, m1*m2)",
		comment="",
		duration=0.001992,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m2*m1)())",
		comment="",
		duration=0.002059,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe((m1*m2)(), (m2*m1)())",
		comment="",
		duration=0.002085,
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
		duration=0.003535,
		simplifyStack={"Init", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( ((Matrix({a},{b}) + Matrix({c},{d})) / t)(), Matrix({frac(a+c,t)}, {frac(b+d,t)}) )",
		comment="",
		duration=0.007343,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="printbr(Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))",
		comment="",
		duration=0.003003,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr((Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))())",
		comment="",
		duration=0.002793,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))(), Matrix({5},{6}) )",
		comment="",
		duration=0.003602,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}