{
	{
		code="printbr(Array(1,2,3))",
		comment="",
		duration=0.00021500000000001,
		simplifyStack={}
	},
	{
		code="printbr(Array(1,2) + Array(3,4))",
		comment="",
		duration=0.000735,
		simplifyStack={}
	},
	{
		code="printbr((Array(1,2) + Array(3,4))())",
		comment="",
		duration=0.003575,
		simplifyStack={"Init", "+:Prune:combineConstants", "+:Prune:combineConstants", "+:Prune:Array.pruneAdd", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((Array(1,2) + Array(3,4))(), Array(4,6))",
		comment="",
		duration=0.004156,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Matrix({1,2},{3,4}))",
		comment="",
		duration=0.00051999999999999,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({1,2},{3,4}):inverse())",
		comment="",
		duration=0.01579,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "/:Prune:xOverMinusOne", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "*:Prune:matrixMul", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:matrixMul", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({1,2},{3,4}):inverse(), Matrix({-2,1},{frac(3,2),-frac(1,2)}))",
		comment="",
		duration=0.021343,
		simplifyStack={"Init", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(Matrix({a,b},{c,d}))",
		comment="",
		duration=0.00053,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({a,b},{c,d}):inverse())",
		comment="",
		duration=0.106323,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:factorDenominators", "*:Prune:matrixMul", "*:Prune:factorDenominators", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:matrixMul", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({a,b},{c,d}):inverse(), Matrix( {frac(d, a*d-b*c), frac(-b, a*d-b*c)}, {frac(-c, a*d-b*c), frac(a, a*d-b*c)} ))",
		comment="",
		duration=0.173512,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}))",
		comment="",
		duration=0.001043,
		simplifyStack={}
	},
	{
		code="printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse())",
		comment="",
		duration=0.024833,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse(), Matrix({1,0,0,-t_x},{0,1,0,-t_y},{0,0,1,-t_z},{0,0,0,1}))",
		comment="",
		duration=0.030313,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m + mInv)",
		comment="",
		duration=0.002304,
		simplifyStack={}
	},
	{
		code="printbr((m + mInv)())",
		comment="",
		duration=0.010911,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:flattenAddMul", "*:Prune:apply", "+:Prune:flattenAddMul", "+:Prune:Array.pruneAdd", "*:Prune:apply", "+:Prune:flattenAddMul", "+:Prune:flattenAddMul", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(m * mInv)",
		comment="",
		duration=0.0020429999999999,
		simplifyStack={}
	},
	{
		code="printbr((m * mInv)())",
		comment="",
		duration=0.010678,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "*:Prune:apply", "+:Prune:combineMultipliedConstants", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:matrixMul", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (m*mInv)(), Matrix({1,0},{0,1}) )",
		comment="",
		duration=0.020799,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m*m)",
		comment="",
		duration=0.0011639999999999,
		simplifyStack={}
	},
	{
		code="printbr((m*m)())",
		comment="",
		duration=0.050064,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineMultipliedConstants", "+:Prune:combineMultipliedConstants", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:matrixMul", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "+:Factor:apply", "+:Factor:apply", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(m1)",
		comment="",
		duration=0.00033899999999998,
		simplifyStack={}
	},
	{
		code="printbr(m2)",
		comment="",
		duration=0.00012400000000001,
		simplifyStack={}
	},
	{
		code="printbr((m1*m2):eq((m1*m2)()))",
		comment="",
		duration=0.0048819999999999,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:matrixMul", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m2*m1):eq((m2*m1)()))",
		comment="",
		duration=0.005313,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:matrixMul", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr(m1:eq(m2))",
		comment="",
		duration=0.00019400000000003,
		simplifyStack={}
	},
	{
		code="simplifyAssertNe(m1, m2)",
		comment="",
		duration=0.001278,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m2*m1))",
		comment="",
		duration=0.001448,
		simplifyStack={}
	},
	{
		code="simplifyAssertNe(m1*m2, m2*m1)",
		comment="",
		duration=0.0071359999999999,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:matrixMul", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m1*m2))",
		comment="",
		duration=0.00051900000000005,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(m1*m2, m1*m2)",
		comment="",
		duration=0.010008,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:matrixMul", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((m1*m2):eq(m2*m1)())",
		comment="",
		duration=0.0090290000000001,
		simplifyStack={"Init", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:combineConstants", "*:Prune:matrixMul", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe((m1*m2)(), (m2*m1)())",
		comment="",
		duration=0.013657,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="printbr((Matrix({a},{b}) + Matrix({c},{d})) / t)",
		comment="",
		duration=0.00092000000000003,
		simplifyStack={}
	},
	{
		code="printbr(((Matrix({a},{b}) + Matrix({c},{d})) / t)())",
		comment="",
		duration=0.01985,
		simplifyStack={"Init", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "+:Prune:Array.pruneAdd", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:matrixMul", "*:Prune:apply", "*:Prune:factorDenominators", "*:Prune:matrixMul", "/:Prune:matrixScalar", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( ((Matrix({a},{b}) + Matrix({c},{d})) / t)(), Matrix({frac(a+c,t)}, {frac(b+d,t)}) )",
		comment="",
		duration=0.020398,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Tidy"}
	},
	{
		code="printbr(Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))",
		comment="",
		duration=0.008832,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr((Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))())",
		comment="",
		duration=0.013951,
		simplifyStack={"Init", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "*:Prune:matrixMul", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))(), Matrix({5},{6}) )",
		comment="",
		duration=0.010058,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}