{
	{code="", comment="operation construction", duration=5.000000000005e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="assert flattening construction works:", duration=4.000000000004e-06},
	{
		code="local expr = a + b + c\9simplifyAssertAllEq(expr, {a,b,c})",
		comment="",
		duration=0.005721,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="local expr = a * b * c\9simplifyAssertAllEq(expr, {a,b,c})",
		comment="",
		duration=0.00328,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="assert flattening after replace() works", duration=4.000000000004e-06},
	{
		code="local expr = (a + d):replace(d, b + c)\9simplifyAssertAllEq(expr, {a,b,c})",
		comment="",
		duration=0.00265,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="local expr = (a * d):replace(d, b * c)\9simplifyAssertAllEq(expr, {a,b,c})",
		comment="",
		duration=0.002446,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="assert flatten of add after mul works", duration=5.000000000005e-06},
	{
		code="local expr = (f * (a + d)):replace(d, b + c):flatten() print(Verbose(expr)) assertEq(#expr[2], 3)",
		comment="",
		duration=0.000623,
		simplifyStack={}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="TODO just call all this simplify()", duration=4.000000000004e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="constant simplificaiton", duration=5.4999999999999e-05},
	{
		code="simplifyAssertEq(1, (Constant(1)*Constant(1))())",
		comment="multiply by 1",
		duration=0.000776,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1, (Constant(1)/Constant(1))())",
		comment="divide by 1",
		duration=0.000831,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-1, (-Constant(1)/Constant(1))())",
		comment="divide by -1",
		duration=0.002806,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(1, (Constant(1)/(Constant(1)*Constant(1)))())",
		comment="multiply and divide by 1",
		duration=0.000391,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=3.9999999999901e-06},
	{code="", comment="commutativity", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(x+y, y+x)",
		comment="add commutative",
		duration=0.007586,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x*y, y*x)",
		comment="mul commutative",
		duration=0.00273,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="pruning operations", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq(x, (1*x)())",
		comment="prune 1*",
		duration=0.00024199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x, (x*1)())",
		comment="prune *1",
		duration=0.00015800000000002,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(0, (0*x)())",
		comment="prune *0",
		duration=0.00098700000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x/x)(), 1)",
		comment="",
		duration=0.001042,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(x^2, (x*x)())",
		comment="",
		duration=0.008384,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=7.5999999999993e-05},
	{code="", comment="simplify(): div add mul", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq(((x+1)*y)(), (x*y + y)())",
		comment="",
		duration=0.012051,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(((x+1)*(y+1))(), (x*y + x + y + 1)())",
		comment="",
		duration=0.016233,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((2/(2*x*y))(), (1/(x*y))())",
		comment="",
		duration=0.013926,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((1-(1-x))(), x)",
		comment="",
		duration=0.00373,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "+:Prune:combineConstants", "+:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(((1-(1-x))/x)(), 1)",
		comment="",
		duration=0.005526,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((1 + 1/x + 1/x)(), (1 + 2/x)())",
		comment="",
		duration=0.03221,
		simplifyStack={"Init", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((1 + 1/x + 2/x)(), (1 + 3/x)())",
		comment="",
		duration=0.032932,
		simplifyStack={"Init", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{code="", comment="factoring integers", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq((Constant(2)/Constant(2))(), Constant(1))",
		comment="",
		duration=0.000722,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((Constant(2)/Constant(4))(), (Constant(1)/Constant(2))())",
		comment="",
		duration=0.008136,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq(((2*x + 2*y)/2)(), (x+y)())",
		comment="",
		duration=0.00672,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(((-2*x + 2*y)/2)(), (-x+y)())",
		comment="",
		duration=0.011616,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="simplifyAssertEq(-1-x, -(1+x))",
		comment="",
		duration=0.007697,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="simplifyAssertEq((-x)/x, -1)",
		comment="",
		duration=0.002439,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x/(-x)), -1)",
		comment="",
		duration=0.003702,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((-x-1)/(x+1), -1)",
		comment="",
		duration=0.009323,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x-1)/(1-x), -1)",
		comment="",
		duration=0.008128,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq( (x*y)/(x*y)^2, 1/(x*y) )",
		comment="",
		duration=0.007163,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{code="", comment="origin of the error:", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq( 1/(1-x), -1/(x-1) )",
		comment="",
		duration=0.012172,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="without needing to factor the polynomial", duration=5.0000000000328e-06},
	{
		code="simplifyAssertEq(((x-1)*(x+1))/(x+1), x-1)",
		comment="",
		duration=0.004055,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(((x-1)*(x+1))/(x-1), x+1)",
		comment="",
		duration=0.005315,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x-1)/((x+1)*(x-1)), 1/(x+1))",
		comment="",
		duration=0.00556,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1)/((x+1)*(x-1)), 1/(x-1))",
		comment="",
		duration=0.006202,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="with needing to factor the polynomial", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq((x^2-1)/(x+1), x-1)",
		comment="",
		duration=0.016991,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2-1)/(x-1), x+1)",
		comment="",
		duration=0.022713,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x-1)/(x^2-1), 1/(x+1))",
		comment="",
		duration=0.024641,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1)/(x^2-1), 1/(x-1))",
		comment="",
		duration=0.023167,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="... and with signs flipped", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq((1-x^2)/(x+1), -(x-1))",
		comment="",
		duration=0.01488,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((1-x^2)/(x-1), -(x+1))",
		comment="",
		duration=0.016731,
		simplifyStack={"Init", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x-1)/(1-x^2), -1/(x+1))",
		comment="",
		duration=0.020945,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1)/(1-x^2), -1/(x-1))",
		comment="",
		duration=0.016748,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{code="", comment="make sure sorting of expression terms works", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq(y-a, -a+y)",
		comment="",
		duration=0.001954,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (y-a)/(b-a) , y/(b-a) - a/(b-a) )",
		comment="",
		duration=0.043521,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:flatten", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:factorOutDivs", "Prune", "Expand", "Prune", "+:Factor:apply", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "*:Prune:flatten", "unm:Prune:doubleNegative", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "*:Prune:factorDenominators", "+:Prune:combineConstants", "*:Prune:combinePows", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "/:Prune:divToPowSub", "/:Prune:qIsDiv", "Prune", "*:Expand:apply", "*:Expand:apply", "Expand", "*:Prune:apply", "*:Prune:flatten", "*:Prune:apply", "*:Prune:flatten", "Prune", "+:Factor:apply", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Expand", "Prune", "+:Factor:apply", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="print((a^2 * x^2 - a^2)())",
		comment="just printing this, i was getting simplification loops",
		duration=0.017387,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "*:Factor:combineMulOfLikePow", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "+:Factor:apply", "Factor", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:flatten", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "*:Expand:apply", "*:Expand:apply", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:flattenAddMul", "+:Prune:flatten", "Prune", "*:Factor:combineMulOfLikePow", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="simplifyAssertEq( (t - r) / (-r^2 - t^2 + 2 * r * t), -1 / (t - r))",
		comment="this won't simplify correctly unless you negative , simplify, negative again ...",
		duration=0.056224,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "*:Prune:flatten", "*:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "*:Prune:flatten", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="simplifyAssertEq( (-128 + 64*sqrt(5))/(64*sqrt(5)), -2 / sqrt(5) + 1 )",
		comment="",
		duration=0.139442,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="expand(): add div mul", duration=4.000000000004e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="factor(): mul add div", duration=4.000000000004e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="trigonometry", duration=4.000000000004e-06},
	{code="", comment="", duration=3.999999999893e-06},
	{
		code="simplifyAssertEq((sin(x)^2+cos(x)^2)(), 1)",
		comment="",
		duration=0.003699,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((y*sin(x)^2+y*cos(x)^2)(), y)",
		comment="",
		duration=0.0099440000000001,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((y+y*sin(x)^2+y*cos(x)^2)(), 2*y)",
		comment="",
		duration=0.008666,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((1+y*sin(x)^2+y*cos(x)^2)(), 1+y)",
		comment="",
		duration=0.0083129999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999505e-06},
	{
		code="simplifyAssertEq(1+cos(x)^2+cos(x)^2, 1+2*cos(x)^2)",
		comment="",
		duration=0.017456,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-1+cos(x)^2+cos(x)^2, -1+2*cos(x)^2)",
		comment="",
		duration=0.014595,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999505e-06},
	{
		code="simplifyAssertEq( cos(x)^2 + sin(x)^2, 1)",
		comment="",
		duration=0.00473,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (cos(x)*y)^2 + (sin(x)*y)^2, y^2)",
		comment="",
		duration=0.011801,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.0000000000615e-06},
	{
		code="simplifyLHSAssertEq( (sin(x)^2)(), sin(x)^2)",
		comment="",
		duration=0.0063460000000001,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "^:Expand:integerPower", "unm:Expand:apply", "+:Prune:combineConstants", "*:Prune:combinePows", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.9999999999792e-06},
	{
		code="simplifyLHSAssertEq( (cos(b)^2 - 1)(), -sin(b)^2)",
		comment="",
		duration=0.0045810000000001,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyLHSAssertEq( (1 - cos(b)^2)(), sin(b)^2)",
		comment="",
		duration=0.004215,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyLHSAssertEq( (a * cos(b)^2 - a)(), -(a * sin(b)^2))",
		comment="",
		duration=0.017045,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyLHSAssertEq( (a - a * cos(b)^2)(), a * sin(b)^2)",
		comment="",
		duration=0.015449,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="simplifyLHSAssertEq( (a^2 * cos(b)^2 - a^2)(), -(a^2 * sin(b)^2))",
		comment="the only one that doesn't work",
		duration=0.053272,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:141: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:246: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:245>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:141: in function 'simplifyLHSAssertEq'\n\9[string \"simplifyLHSAssertEq( (a^2 * cos(b)^2 - a^2)()...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:237: in function 'exec'\n\9test.lua:182: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:54: in function 'timer'\n\9test.lua:8: in main chunk\n\9[C]: at 0x564111b703e0",
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "*:Factor:combineMulOfLikePow", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "+:Factor:apply", "Factor", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:flatten", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "*:Expand:apply", "*:Expand:apply", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:flattenAddMul", "+:Prune:flatten", "Prune", "*:Factor:combineMulOfLikePow", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyLHSAssertEq( (a^2 - a^2 * cos(b)^2)(), a^2 * sin(b)^2)",
		comment="also the only one that doesn't work",
		duration=0.046933,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:141: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:246: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:245>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:141: in function 'simplifyLHSAssertEq'\n\9[string \"simplifyLHSAssertEq( (a^2 - a^2 * cos(b)^2)()...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:237: in function 'exec'\n\9test.lua:182: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:54: in function 'timer'\n\9test.lua:8: in main chunk\n\9[C]: at 0x564111b703e0",
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "*:Factor:combineMulOfLikePow", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "+:Factor:apply", "Factor", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:flatten", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "*:Expand:apply", "*:Expand:apply", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:flatten", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:flatten", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:flattenAddMul", "+:Prune:flatten", "Prune", "*:Factor:combineMulOfLikePow", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "+:Factor:apply", "Factor", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:flatten", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="simplifyLHSAssertEq( (a^3 * cos(b)^2 - a^3)(), -(a^3 * sin(b)^2))",
		comment="",
		duration=0.02137,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyLHSAssertEq( (a^3 - a^3 * cos(b)^2)(), a^3 * sin(b)^2)",
		comment="",
		duration=0.022173,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999505e-06},
	{
		code="simplifyLHSAssertEq( (a^4 * cos(b)^2 - a^4)(), -(a^4 * sin(b)^2))",
		comment="",
		duration=0.01838,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyLHSAssertEq( (a^4 - a^4 * cos(b)^2)(), a^4 * sin(b)^2)",
		comment="",
		duration=0.022264,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999505e-06},
	{code="", comment="", duration=5.9999999999505e-06},
	{code="", comment="some more stuff", duration=5.0000000000328e-06},
	{code="", comment="", duration=5.9999999999505e-06},
	{
		code="simplifyAssertEq((y-x)/(x-y), -1)",
		comment="",
		duration=0.0048429999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+y)/(x+y)^2, 1/(x+y))",
		comment="",
		duration=0.004575,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-x+y)/(-x+y)^2, 1/(-x+y))",
		comment="",
		duration=0.006928,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999505e-06},
	{
		code="simplifyAssertEq( gUxy * (gUxy^2 - gUxx*gUyy) / (gUxx * gUyy - gUxy^2), -gUxy)",
		comment="",
		duration=0.036674,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( gUxy * (gUxy - gUxx*gUyy) / (gUxx * gUyy - gUxy), -gUxy)",
		comment="",
		duration=0.020967,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( gUxy * (gUxy - gUxx) / (gUxx - gUxy), -gUxy)",
		comment="",
		duration=0.013131,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=6.9999999998682e-06},
	{
		code="assert( not( Constant(0) == x * y ) )",
		comment="",
		duration=6.6000000000122e-05,
		simplifyStack={}
	},
	{
		code="assert( Constant(0) ~= x * y )",
		comment="",
		duration=4.2000000000098e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq( Constant(0):subst( (v'^k' * v'^l' * g'_kl'):eq(var'vsq') ), Constant(0) )",
		comment="",
		duration=0.00076500000000013,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq( Constant(0):replace( v'^k' * v'^l' * g'_kl', var'vsq' ), Constant(0) )",
		comment="",
		duration=0.00028899999999998,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq( Constant(0):replace( v'^k' * v'^l', var'vsq' ), Constant(0) )",
		comment="",
		duration=0.00023799999999996,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq( Constant(0):replace( v'^k', var'vsq' ), Constant(0) )",
		comment="",
		duration=0.00017699999999987,
		simplifyStack={}
	},
	{code="", comment="", duration=5.9999999999505e-06},
	{code="", comment="fixed this bug with op.div.rules.Prune.negOverNeg", duration=6.9999999998682e-06},
	{
		code="simplifyAssertEq(-f * a^2 + f^3 * a^2 - f^5 * a^2, -f * a^2 * (1 - f^2 + f^4))",
		comment="'a' var lexically before 'f' var, squared, times -1's, simplification loop.  oscillates between factoring out the -1 or not.",
		duration=0.035747,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:flatten", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-f * g^2 + f^3 * g^2 - f^5 * g^2, -f * g^2 * (1 - f^2 + f^4))",
		comment="'g' var lexically before 'f' var, no simplification loop",
		duration=0.03875,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:flatten", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(f * a^2 + f^3 * a^2 + f^5 * a^2, f * a^2 * (1 + f^2 + f^4))",
		comment="replace -1's with +1's, no simplification loop",
		duration=0.023672,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-f * a + f^3 * a - f^5 * a, -f * a * (1 - f^2 + f^4))",
		comment="replace a^2 with a, no simplification loop",
		duration=0.022569,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:flatten", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-f * a^2 + f^2 * a^2 - f^3 * a^2, -f * a^2 * (1 - f  + f^2))",
		comment="replace f * quadratic of f^2 with f * quadratic of f, no simplification loop",
		duration=0.020757,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "*:Prune:flatten", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "*:Factor:combineMulOfLikePow", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999505e-06},
	{code="", comment="this runs forever (unless I push certain rules)", duration=5.9999999999505e-06},
	{code="", comment="(b^2 * (a * r^2 + (a + 3 * sqrt(b^2 + delta^2))) * (a + sqrt(b^2 + delta^2))^2 / (3 * (r^2 + (a + sqrt(b^2 + delta^2))^2)^frac(5,2) * (b^2 + delta^2)^frac(3,2)) - lambda * exp(-l^2 / 2)):diff(delta)()", duration=5.9999999999505e-06}
}