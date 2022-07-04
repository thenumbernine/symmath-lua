{
	{
		code="print(sqrt(-1)())",
		comment="",
		duration=0.00072,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(sqrt(-1), i)",
		comment="",
		duration=0.001015,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="make sure, when distributing sqrt()'s, that the negative signs on the inside are simplified in advance", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq( ((((-x*a - x*b)))^frac(1,2)), i * (sqrt(x) * sqrt(a+b)) )",
		comment="",
		duration=0.016414,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "Factor", "^:Prune:expandMulOfLikePow", "*:Prune:flatten", "Prune", "^:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (-(((-x*a - x*b)))^frac(1,2)), -i * (sqrt(x) * sqrt(a+b)) )",
		comment="",
		duration=0.014543,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "sqrt:Prune:apply", "sqrt:Prune:apply", "*:Prune:flatten", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "Factor", "^:Prune:expandMulOfLikePow", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "^:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( ((((-x*a - x*b)*-1))^frac(1,2)), (sqrt(x) * sqrt(a+b)) )",
		comment="",
		duration=0.0106,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "Factor", "^:Prune:expandMulOfLikePow", "Prune", "^:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (-(((-x*a - x*b)*-1))^frac(1,2)), -(sqrt(x) * sqrt(a+b)) )",
		comment="",
		duration=0.009449,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "Factor", "^:Prune:expandMulOfLikePow", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "^:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="If sqrt, -1, and mul factor run out of order then -sqrt(-x) and sqrt(-x) will end up equal.  And that isn't good for things like solve() on quadratics.", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( ((((-x*a - x*b)/-1)/y)^frac(1,2)), (sqrt(x) * sqrt(a+b)) / sqrt(y) )",
		comment="",
		duration=0.020238,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "/:Factor:polydiv", "Factor", "^:Prune:expandMulOfLikePow", "*:Prune:flatten", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "^:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "^:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (-(((-x*a - x*b)/-1)/y)^frac(1,2)), -(sqrt(x) * sqrt(a+b)) / sqrt(y) )",
		comment="",
		duration=0.026328,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "/:Factor:polydiv", "Factor", "^:Prune:expandMulOfLikePow", "*:Prune:flatten", "*:Prune:flatten", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Constant:Tidy:apply", "^:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="simplifying expressions with sqrts in them", duration=0},
	{
		code="simplifyAssertEq( 2^frac(-1,2) + 2^frac(1,2), frac(3, sqrt(2)) )",
		comment="",
		duration=0.005418,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "Prune", "^:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( 2*2^frac(-1,2) + 2^frac(1,2), 2 * sqrt(2) )",
		comment="",
		duration=0.002651,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "^:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( 4*2^frac(-1,2) + 2^frac(1,2), 3 * sqrt(2) )",
		comment="",
		duration=0.00222,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "Prune", "^:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (1 + sqrt(3))^2 + (1 - sqrt(3))^2, 8 )",
		comment="",
		duration=0.006849,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (frac(1,2)*sqrt(3))*(frac(sqrt(2),sqrt(3))) + (-frac(1,2))*(frac(1,3)*-sqrt(2)) , 2 * sqrt(2) / 3)",
		comment="",
		duration=0.016656,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "^:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( -frac(1,3)*-frac(1+sqrt(3),3) + -frac(2,3)*frac(1,3) + -frac(2,3) * frac(1-sqrt(3),3), -frac(1 - sqrt(3), 3))",
		comment="",
		duration=0.017733,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Tidy:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( -sqrt(3)*sqrt(2)/(2*sqrt(3)) + sqrt(2)/6, -sqrt(2)/3 )",
		comment="",
		duration=0.008598,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "Prune", "Constant:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( 1 + 5*sqrt(5) + sqrt(5), 1 + 6*sqrt(5) )",
		comment="",
		duration=0.003673,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( 1 + 25*sqrt(5) + sqrt(5), 1 + 26*sqrt(5) )",
		comment="powers of the sqrt sometimes get caught simplifying as merging the exponents, and don't add.",
		duration=0.002971,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( 1 + 5*sqrt(5) - 5*sqrt(5), 1 )",
		comment="",
		duration=0.001458,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( -(1 + sqrt(5))/(2*sqrt(3)) , frac(1,2)*(-frac(1,sqrt(3)))*(1 + sqrt(5)) )",
		comment="",
		duration=0.025811,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "*:Prune:apply", "^:Prune:sqrtFix4", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "*:Prune:factorDenominators", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "Constant:Tidy:apply", "Constant:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (-(1-sqrt(3))/3)*(frac(1,3)) + ((2+sqrt(3))/6)*(-(1-sqrt(3))/3) + (-(1+2*sqrt(3))/6)*(-(1+sqrt(3))/3) , (1 + sqrt(3))/3 )",
		comment="",
		duration=0.031854,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq( (-sqrt(sqrt(5) + 1) * (1 - sqrt(5))) / (4 * sqrt(sqrt(5) - 1)) , frac(1,2))",
		comment="",
		duration=0.018081,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="simplifyAssertNe( 6 + 6 * sqrt(3), 12)",
		comment="ok this is hard to explain ..",
		duration=0.004658,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq( (sqrt(5) + 1) * (sqrt(5) - 1), 4)",
		comment="",
		duration=0.004578,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( sqrt((sqrt(5) + 1) * (sqrt(5) - 1)), 2)",
		comment="",
		duration=0.004994,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq( (1 + 2 / sqrt(3)) / (2 * sqrt(3)), (2 + sqrt(3)) / 6 )",
		comment="",
		duration=0.003911,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq( (frac(1,3)*(-(1-sqrt(3)))) * (frac(1,3)*(-(1-sqrt(3)))) + (frac(1,6)*(2+sqrt(3))) * (frac(1,3)*(1+sqrt(3))) + (frac(1,6)*-(1+2*sqrt(3))) * frac(1,3), (4 - sqrt(3))/6 )",
		comment="",
		duration=0.025924,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq( 1/sqrt(6) + 1/sqrt(6), 2/sqrt(6) )",
		comment="",
		duration=0.003307,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "/:Prune:divToPowSub", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "^:Tidy:apply", "^:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq( (32 * sqrt(3) + 32 * sqrt(15)) / 384, (sqrt(3) + sqrt(15)) / 12 )",
		comment="",
		duration=0.056249,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq( sqrt(5)/(2*sqrt(3)), sqrt(15)/6 )",
		comment="",
		duration=0.009646,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "^:Tidy:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "^:Tidy:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "^:Tidy:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "^:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq( -1/(2*sqrt(3)), -sqrt(frac(1,12)) )",
		comment="",
		duration=0.010046,
		simplifyStack={"Init", "sqrt:Prune:apply", "^:Prune:oneToTheX", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Constant:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe( -sqrt(frac(1,12)), sqrt(frac(1,12)) )",
		comment="",
		duration=0.016412,
		simplifyStack={"Init", "sqrt:Prune:apply", "Prune", "^:Expand:frac", "Expand", "^:Prune:oneToTheX", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "^:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq( (sqrt(2)*sqrt(frac(1,3))) * -frac(1,3) + (-frac(1,2)) * (sqrt(2)/sqrt(3)) + (frac(1,2)*1/sqrt(3)) * (-sqrt(2)/3), -sqrt(2) / sqrt(3) )",
		comment="",
		duration=0.014092,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Constant:Tidy:apply", "^:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "^:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq( 1 + ( -(7 - 3*sqrt(5)) / (3*(3 - sqrt(5))) )*(1 + frac(1,2)), (1 + sqrt(5))/4 )",
		comment="",
		duration=0.009869,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{
		code="simplifyAssertEq( (-(sqrt(5)-1)/2)/sqrt((-(sqrt(5)-1)/2)^2 + 1), -sqrt( (sqrt(5) - 1) / (2 * sqrt(5)) ))",
		comment="",
		duration=0.068974,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "Constant:Tidy:apply", "^:Tidy:apply", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "Constant:Tidy:apply", "^:Tidy:apply", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "Constant:Tidy:apply", "^:Tidy:apply", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "+:Prune:combineConstants", "*:Prune:apply", "^:Prune:distributePow", "^:Prune:expandMulOfLikePow", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:frac", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq(sqrt(frac(15,16)) * sqrt(frac(2,3)), sqrt(5)/(2*sqrt(2)))",
		comment="",
		duration=0.004596,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "*:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "Prune", "^:Tidy:apply", "^:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="these go bad when I don't have mul/Prune/combineMulOfLikePow_mulPowAdd", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq( ( sqrt(f) * (g + f * sqrt(g)) )() , sqrt(f) * sqrt(g) * (sqrt(g) + f))",
		comment="",
		duration=0.024828,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:flattenAddMul", "^:Prune:xToTheOne", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( ( sqrt(f) * (g + sqrt(g)) )() , sqrt(f) * sqrt(g) * (sqrt(g) + 1))",
		comment="",
		duration=0.008775,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "sqrt:Prune:apply", "+:Prune:combineConstants", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:flattenAddMul", "^:Prune:xToTheOne", "*:Prune:apply", "Prune", "*:Factor:combineMulOfLikePow", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.0000000000288e-06},
	{code="", comment="these are in simplification loops", duration=0},
	{code="", comment="", duration=0},
	{code="", comment="start with -1 / ( (√√5 √(√5 - 1)) / √2 ) ... what mine gets now vs what mathematica gets", duration=1.0000000000288e-06},
	{
		code="simplifyAssertEq( -1 / ( sqrt(sqrt(5) * (sqrt(5) - 1)) / sqrt(2) ), sqrt((5  + sqrt(5)) / 10))",
		comment="",
		duration=0.043173,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq( -1 / ( sqrt(sqrt(5) * (sqrt...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9sqrt.lua:100: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9sqrt.lua:9: in main chunk\n\9[C]: at 0x55a0e00be3e0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "^:Expand:frac", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( -(sqrt( 10 * (sqrt(5) - 1) ) + sqrt(2 * (sqrt(5) - 1))) / (4 * sqrt(sqrt(5))), sqrt((5  + sqrt(5)) / 10))",
		comment="",
		duration=0.038394,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:107: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq( -(sqrt( 10 * (sqrt(5) - 1) ...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9sqrt.lua:100: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9sqrt.lua:9: in main chunk\n\9[C]: at 0x55a0e00be3e0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "^:Expand:frac", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}