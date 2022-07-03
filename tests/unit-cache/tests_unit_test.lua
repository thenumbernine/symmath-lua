{
	{code="", comment="operation construction", duration=9.9999999999753e-07},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="assert flattening construction works:", duration=1.000000000001e-06},
	{
		code="local expr = a + b + c\9simplifyAssertAllEq(expr, {a,b,c})",
		comment="",
		duration=0.00114,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="local expr = a * b * c\9simplifyAssertAllEq(expr, {a,b,c})",
		comment="",
		duration=0.00036199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="assert flattening after replace() works", duration=1.000000000001e-06},
	{
		code="local expr = (a + d):replace(d, b + c)\9simplifyAssertAllEq(expr, {a,b,c})",
		comment="",
		duration=0.000417,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="local expr = (a * d):replace(d, b * c)\9simplifyAssertAllEq(expr, {a,b,c})",
		comment="",
		duration=0.00023400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="assert flatten of add after mul works", duration=0},
	{
		code="local expr = (f * (a + d)):replace(d, b + c):flatten() print(Verbose(expr)) assertEq(#expr[2], 3)",
		comment="",
		duration=8.1999999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="TODO just call all this simplify()", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="constant simplificaiton", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(1, (Constant(1)*Constant(1))())",
		comment="multiply by 1",
		duration=0.000105,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(1, (Constant(1)/Constant(1))())",
		comment="divide by 1",
		duration=5.7000000000001e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-1, (-Constant(1)/Constant(1))())",
		comment="divide by -1",
		duration=0.000348,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(1, (Constant(1)/(Constant(1)*Constant(1)))())",
		comment="multiply and divide by 1",
		duration=0.000144,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="commutativity", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(x+y, y+x)",
		comment="add commutative",
		duration=0.001119,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x*y, y*x)",
		comment="mul commutative",
		duration=0.000757,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="pruning operations", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(x, (1*x)())",
		comment="prune 1*",
		duration=2.6000000000005e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(x, (x*1)())",
		comment="prune *1",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(0, (0*x)())",
		comment="prune *0",
		duration=0.000322,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x/x)(), 1)",
		comment="",
		duration=0.000132,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(x^2, (x*x)())",
		comment="",
		duration=0.001193,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="simplify(): div add mul", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(((x+1)*y)(), (x*y + y)())",
		comment="",
		duration=0.00396,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(((x+1)*(y+1))(), (x*y + x + y + 1)())",
		comment="",
		duration=0.003819,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((2/(2*x*y))(), (1/(x*y))())",
		comment="",
		duration=0.004644,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((1-(1-x))(), x)",
		comment="",
		duration=0.002003,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "+:Prune:combineConstants", "+:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(((1-(1-x))/x)(), 1)",
		comment="",
		duration=0.001468,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((1 + 1/x + 1/x)(), (1 + 2/x)())",
		comment="",
		duration=0.008798,
		simplifyStack={"Init", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((1 + 1/x + 2/x)(), (1 + 3/x)())",
		comment="",
		duration=0.007735,
		simplifyStack={"Init", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="factoring integers", duration=0},
	{
		code="simplifyAssertEq((Constant(2)/Constant(2))(), Constant(1))",
		comment="",
		duration=0.000153,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((Constant(2)/Constant(4))(), (Constant(1)/Constant(2))())",
		comment="",
		duration=0.002499,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(((2*x + 2*y)/2)(), (x+y)())",
		comment="",
		duration=0.002944,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(((-2*x + 2*y)/2)(), (-x+y)())",
		comment="",
		duration=0.004052,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(-1-x, -(1+x))",
		comment="",
		duration=0.002855,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((-x)/x, -1)",
		comment="",
		duration=0.00029,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x/(-x)), -1)",
		comment="",
		duration=0.000583,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((-x-1)/(x+1), -1)",
		comment="",
		duration=0.002754,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x-1)/(1-x), -1)",
		comment="",
		duration=0.002079,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (x*y)/(x*y)^2, 1/(x*y) )",
		comment="",
		duration=0.00206,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "/:Factor:polydiv", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="origin of the error:", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( 1/(1-x), -1/(x-1) )",
		comment="",
		duration=0.003474,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="without needing to factor the polynomial", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(((x-1)*(x+1))/(x+1), x-1)",
		comment="",
		duration=0.00096299999999999,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(((x-1)*(x+1))/(x-1), x+1)",
		comment="",
		duration=0.001209,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x-1)/((x+1)*(x-1)), 1/(x+1))",
		comment="",
		duration=0.001593,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1)/((x+1)*(x-1)), 1/(x-1))",
		comment="",
		duration=0.001237,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="with needing to factor the polynomial", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((x^2-1)/(x+1), x-1)",
		comment="",
		duration=0.00503,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x^2-1)/(x-1), x+1)",
		comment="",
		duration=0.005449,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x-1)/(x^2-1), 1/(x+1))",
		comment="",
		duration=0.010609,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1)/(x^2-1), 1/(x-1))",
		comment="",
		duration=0.005297,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="... and with signs flipped", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((1-x^2)/(x+1), -(x-1))",
		comment="",
		duration=0.004224,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((1-x^2)/(x-1), -(x+1))",
		comment="",
		duration=0.005107,
		simplifyStack={"Init", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x-1)/(1-x^2), -1/(x+1))",
		comment="",
		duration=0.00588,
		simplifyStack={"Init", "+:Prune:combineConstants", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "/:Prune:xOverMinusOne", "*:Prune:apply", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+1)/(1-x^2), -1/(x-1))",
		comment="",
		duration=0.005151,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "*:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="make sure sorting of expression terms works", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(y-a, -a+y)",
		comment="",
		duration=0.00073999999999999,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (y-a)/(b-a) , y/(b-a) - a/(b-a) )",
		comment="",
		duration=0.034195,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:flatten", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:factorOutDivs", "Prune", "Expand", "Prune", "+:Factor:apply", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="print((a^2 * x^2 - a^2)())",
		comment="just printing this, i was getting simplification loops",
		duration=0.005256,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "*:Factor:combineMulOfLikePow", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "+:Factor:apply", "Factor", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:flatten", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "*:Expand:apply", "*:Expand:apply", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:flattenAddMul", "+:Prune:flatten", "Prune", "*:Factor:combineMulOfLikePow", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (t - r) / (-r^2 - t^2 + 2 * r * t), -1 / (t - r))",
		comment="this won't simplify correctly unless you negative , simplify, negative again ...",
		duration=0.009416,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "*:Prune:flatten", "*:Prune:apply", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "/:Prune:negOverNeg", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "*:Prune:flatten", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (-128 + 64*sqrt(5))/(64*sqrt(5)), -2 / sqrt(5) + 1 )",
		comment="",
		duration=0.050258,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{code="", comment="expand(): add div mul", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="factor(): mul add div", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="trigonometry", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq((sin(x)^2+cos(x)^2)(), 1)",
		comment="",
		duration=0.000968,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((y*sin(x)^2+y*cos(x)^2)(), y)",
		comment="",
		duration=0.001977,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((y+y*sin(x)^2+y*cos(x)^2)(), 2*y)",
		comment="",
		duration=0.001967,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((1+y*sin(x)^2+y*cos(x)^2)(), 1+y)",
		comment="",
		duration=0.002122,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq(1+cos(x)^2+cos(x)^2, 1+2*cos(x)^2)",
		comment="",
		duration=0.006602,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-1+cos(x)^2+cos(x)^2, -1+2*cos(x)^2)",
		comment="",
		duration=0.005091,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq( cos(x)^2 + sin(x)^2, 1)",
		comment="",
		duration=0.000778,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (cos(x)*y)^2 + (sin(x)*y)^2, y^2)",
		comment="",
		duration=0.003134,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyLHSAssertEq( (sin(x)^2)(), sin(x)^2)",
		comment="",
		duration=0.006314,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "^:Expand:integerPower", "unm:Expand:apply", "+:Prune:combineConstants", "*:Prune:apply", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=3.0000000000308e-06},
	{
		code="simplifyLHSAssertEq( (cos(b)^2 - 1)(), -sin(b)^2)",
		comment="",
		duration=0.002341,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyLHSAssertEq( (1 - cos(b)^2)(), sin(b)^2)",
		comment="",
		duration=0.001438,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{
		code="simplifyLHSAssertEq( (a * cos(b)^2 - a)(), -(a * sin(b)^2))",
		comment="",
		duration=0.003526,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyLHSAssertEq( (a - a * cos(b)^2)(), a * sin(b)^2)",
		comment="",
		duration=0.003628,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{
		code="simplifyLHSAssertEq( (a^2 * cos(b)^2 - a^2)(), -(a^2 * sin(b)^2))",
		comment="the only one that doesn't work",
		duration=0.01583,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:122: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:122: in function 'simplifyLHSAssertEq'\n\9[string \"simplifyLHSAssertEq( (a^2 * cos(b)^2 - a^2)()...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9test.lua:182: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9test.lua:8: in main chunk\n\9[C]: at 0x5623f0d9b3e0",
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "*:Factor:combineMulOfLikePow", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "+:Factor:apply", "Factor", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:flatten", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "*:Expand:apply", "*:Expand:apply", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:flattenAddMul", "+:Prune:flatten", "Prune", "*:Factor:combineMulOfLikePow", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyLHSAssertEq( (a^2 - a^2 * cos(b)^2)(), a^2 * sin(b)^2)",
		comment="also the only one that doesn't work",
		duration=0.010368,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:122: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:122: in function 'simplifyLHSAssertEq'\n\9[string \"simplifyLHSAssertEq( (a^2 - a^2 * cos(b)^2)()...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9test.lua:182: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9test.lua:8: in main chunk\n\9[C]: at 0x5623f0d9b3e0",
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "*:Factor:combineMulOfLikePow", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "+:Factor:apply", "Factor", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:flatten", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "*:Expand:apply", "*:Expand:apply", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:flatten", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:flatten", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:flattenAddMul", "+:Prune:flatten", "Prune", "*:Factor:combineMulOfLikePow", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "/:Prune:xOverX", "^:Prune:xToTheOne", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "+:Factor:apply", "Factor", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:flatten", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="simplifyLHSAssertEq( (a^3 * cos(b)^2 - a^3)(), -(a^3 * sin(b)^2))",
		comment="",
		duration=0.006728,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyLHSAssertEq( (a^3 - a^3 * cos(b)^2)(), a^3 * sin(b)^2)",
		comment="",
		duration=0.006417,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="simplifyLHSAssertEq( (a^4 * cos(b)^2 - a^4)(), -(a^4 * sin(b)^2))",
		comment="",
		duration=0.006688,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyLHSAssertEq( (a^4 - a^4 * cos(b)^2)(), a^4 * sin(b)^2)",
		comment="",
		duration=0.012177,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="some more stuff", duration=9.9999999997324e-07},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq((y-x)/(x-y), -1)",
		comment="",
		duration=0.00261,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x+y)/(x+y)^2, 1/(x+y))",
		comment="",
		duration=0.00094899999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((-x+y)/(-x+y)^2, 1/(-x+y))",
		comment="",
		duration=0.001207,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "/:Factor:polydiv", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq( gUxy * (gUxy^2 - gUxx*gUyy) / (gUxx * gUyy - gUxy^2), -gUxy)",
		comment="",
		duration=0.008444,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( gUxy * (gUxy - gUxx*gUyy) / (gUxx * gUyy - gUxy), -gUxy)",
		comment="",
		duration=0.007759,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( gUxy * (gUxy - gUxx) / (gUxx - gUxy), -gUxy)",
		comment="",
		duration=0.003647,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=3.0000000000308e-06},
	{
		code="assert( not( Constant(0) == x * y ) )",
		comment="",
		duration=3.8000000000038e-05,
		simplifyStack={}
	},
	{
		code="assert( Constant(0) ~= x * y )",
		comment="",
		duration=1.6999999999989e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq( Constant(0):subst( (v'^k' * v'^l' * g'_kl'):eq(var'vsq') ), Constant(0) )",
		comment="",
		duration=0.00017100000000003,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq( Constant(0):replace( v'^k' * v'^l' * g'_kl', var'vsq' ), Constant(0) )",
		comment="",
		duration=4.4999999999962e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq( Constant(0):replace( v'^k' * v'^l', var'vsq' ), Constant(0) )",
		comment="",
		duration=5.0999999999968e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq( Constant(0):replace( v'^k', var'vsq' ), Constant(0) )",
		comment="",
		duration=1.1999999999956e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="fixed this bug with op.div.rules.Prune.negOverNeg", duration=0},
	{
		code="simplifyAssertEq(-f * a^2 + f^3 * a^2 - f^5 * a^2, -f * a^2 * (1 - f^2 + f^4))",
		comment="'a' var lexically before 'f' var, squared, times -1's, simplification loop.  oscillates between factoring out the -1 or not.",
		duration=0.00982,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:flatten", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-f * g^2 + f^3 * g^2 - f^5 * g^2, -f * g^2 * (1 - f^2 + f^4))",
		comment="'g' var lexically before 'f' var, no simplification loop",
		duration=0.008491,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:flatten", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(f * a^2 + f^3 * a^2 + f^5 * a^2, f * a^2 * (1 + f^2 + f^4))",
		comment="replace -1's with +1's, no simplification loop",
		duration=0.005338,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:integerPower", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-f * a + f^3 * a - f^5 * a, -f * a * (1 - f^2 + f^4))",
		comment="replace a^2 with a, no simplification loop",
		duration=0.0071,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:flatten", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(-f * a^2 + f^2 * a^2 - f^3 * a^2, -f * a^2 * (1 - f  + f^2))",
		comment="replace f * quadratic of f^2 with f * quadratic of f, no simplification loop",
		duration=0.006126,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "*:Prune:flatten", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "*:Expand:apply", "Expand", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:flatten", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "*:Factor:combineMulOfLikePow", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{code="", comment="this runs forever (unless I push certain rules)", duration=9.9999999997324e-07},
	{code="", comment="(b^2 * (a * r^2 + (a + 3 * sqrt(b^2 + delta^2))) * (a + sqrt(b^2 + delta^2))^2 / (3 * (r^2 + (a + sqrt(b^2 + delta^2))^2)^frac(5,2) * (b^2 + delta^2)^frac(3,2)) - lambda * exp(-l^2 / 2)):diff(delta)()", duration=1.0000000000288e-06}
}