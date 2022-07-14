{
	{
		code="print(sqrt(-1)())",
		comment="",
		duration=0.000324,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(sqrt(-1), i)",
		comment="",
		duration=0.000258,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="make sure, when distributing sqrt()'s, that the negative signs on the inside are simplified in advance", duration=0},
	{
		code="simplifyAssertEq( ((((-x*a - x*b)))^frac(1,2)), i * (sqrt(x) * sqrt(a+b)) )",
		comment="",
		duration=0.006458,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "Factor", "^:Prune:expandMulOfLikePow", "*:Prune:flatten", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (-(((-x*a - x*b)))^frac(1,2)), -i * (sqrt(x) * sqrt(a+b)) )",
		comment="",
		duration=0.007392,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "sqrt:Prune:apply", "sqrt:Prune:apply", "*:Prune:flatten", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "Factor", "^:Prune:expandMulOfLikePow", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( ((((-x*a - x*b)*-1))^frac(1,2)), (sqrt(x) * sqrt(a+b)) )",
		comment="",
		duration=0.003536,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "Factor", "^:Prune:expandMulOfLikePow", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq( (-(((-x*a - x*b)*-1))^frac(1,2)), -(sqrt(x) * sqrt(a+b)) )",
		comment="",
		duration=0.004101,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "Factor", "^:Prune:expandMulOfLikePow", "*:Prune:flatten", "Prune", "Constant:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="If sqrt, -1, and mul factor run out of order then -sqrt(-x) and sqrt(-x) will end up equal.  And that isn't good for things like solve() on quadratics.", duration=0},
	{
		code="simplifyAssertEq( ((((-x*a - x*b)/-1)/y)^frac(1,2)), (sqrt(x) * sqrt(a+b)) / sqrt(y) )",
		comment="",
		duration=0.0086,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "/:Factor:polydiv", "Factor", "^:Prune:expandMulOfLikePow", "*:Prune:flatten", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "Tidy"}
	},
	{
		code="simplifyAssertEq( (-(((-x*a - x*b)/-1)/y)^frac(1,2)), -(sqrt(x) * sqrt(a+b)) / sqrt(y) )",
		comment="",
		duration=0.010086,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "sqrt:Prune:apply", "Prune", "Expand", "Prune", "+:Factor:apply", "*:Factor:combineMulOfLikePow", "/:Factor:polydiv", "Factor", "^:Prune:expandMulOfLikePow", "*:Prune:flatten", "*:Prune:flatten", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "Prune", "Constant:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="", duration=0},
	{code="", comment="simplifying expressions with sqrts in them", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( 2^frac(-1,2) + 2^frac(1,2), frac(3, sqrt(2)) )",
		comment="",
		duration=0.002401,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "Tidy"}
	},
	{
		code="simplifyAssertEq( 2*2^frac(-1,2) + 2^frac(1,2), 2 * sqrt(2) )",
		comment="",
		duration=0.001275,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "Tidy"}
	},
	{
		code="simplifyAssertEq( 4*2^frac(-1,2) + 2^frac(1,2), 3 * sqrt(2) )",
		comment="",
		duration=0.001268,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (1 + sqrt(3))^2 + (1 - sqrt(3))^2, 8 )",
		comment="",
		duration=0.003051,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( (frac(1,2)*sqrt(3))*(frac(sqrt(2),sqrt(3))) + (-frac(1,2))*(frac(1,3)*-sqrt(2)) , 2 * sqrt(2) / 3)",
		comment="",
		duration=0.005586,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "*:Prune:apply", "Prune", "Expand", "Prune", "Factor", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( -frac(1,3)*-frac(1+sqrt(3),3) + -frac(2,3)*frac(1,3) + -frac(2,3) * frac(1-sqrt(3),3), -frac(1 - sqrt(3), 3))",
		comment="",
		duration=0.008791,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Tidy:replacePowerOfFractionWithRoots", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:flatten", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( -sqrt(3)*sqrt(2)/(2*sqrt(3)) + sqrt(2)/6, -sqrt(2)/3 )",
		comment="",
		duration=0.003467,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "Prune", "Constant:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "*:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( 1 + 5*sqrt(5) + sqrt(5), 1 + 6*sqrt(5) )",
		comment="",
		duration=0.001469,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( 1 + 25*sqrt(5) + sqrt(5), 1 + 26*sqrt(5) )",
		comment="powers of the sqrt sometimes get caught simplifying as merging the exponents, and don't add.",
		duration=0.001838,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( 1 + 5*sqrt(5) - 5*sqrt(5), 1 )",
		comment="",
		duration=0.000643,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( -(1 + sqrt(5))/(2*sqrt(3)) , frac(1,2)*(-frac(1,sqrt(3)))*(1 + sqrt(5)) )",
		comment="",
		duration=0.009526,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "*:Prune:factorDenominators", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "Constant:Tidy:apply", "Constant:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "*:Tidy:apply", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (-(1-sqrt(3))/3)*(frac(1,3)) + ((2+sqrt(3))/6)*(-(1-sqrt(3))/3) + (-(1+2*sqrt(3))/6)*(-(1+sqrt(3))/3) , (1 + sqrt(3))/3 )",
		comment="",
		duration=0.010734,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( (-sqrt(sqrt(5) + 1) * (1 - sqrt(5))) / (4 * sqrt(sqrt(5) - 1)) , frac(1,2))",
		comment="",
		duration=0.006312,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertNe( 6 + 6 * sqrt(3), 12)",
		comment="ok this is hard to explain ..",
		duration=0.001832,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( (sqrt(5) + 1) * (sqrt(5) - 1), 4)",
		comment="",
		duration=0.001088,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( sqrt((sqrt(5) + 1) * (sqrt(5) - 1)), 2)",
		comment="",
		duration=0.001581,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( (1 + 2 / sqrt(3)) / (2 * sqrt(3)), (2 + sqrt(3)) / 6 )",
		comment="",
		duration=0.002297,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (frac(1,3)*(-(1-sqrt(3)))) * (frac(1,3)*(-(1-sqrt(3)))) + (frac(1,6)*(2+sqrt(3))) * (frac(1,3)*(1+sqrt(3))) + (frac(1,6)*-(1+2*sqrt(3))) * frac(1,3), (4 - sqrt(3))/6 )",
		comment="",
		duration=0.011925,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( 1/sqrt(6) + 1/sqrt(6), 2/sqrt(6) )",
		comment="",
		duration=0.001299,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "/:Prune:divToPowSub", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "^:Tidy:replacePowerOfFractionWithRoots", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( (32 * sqrt(3) + 32 * sqrt(15)) / 384, (sqrt(3) + sqrt(15)) / 12 )",
		comment="",
		duration=0.021152,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( sqrt(5)/(2*sqrt(3)), sqrt(15)/6 )",
		comment="",
		duration=0.005182,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "^:Tidy:replacePowerOfFractionWithRoots", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:combineMulOfLikePow", "*:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "^:Tidy:replacePowerOfFractionWithRoots", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:combineMulOfLikePow", "*:Prune:apply", "^:Prune:sqrtFix4", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "^:Prune:sqrtFix4", "^:Tidy:replacePowerOfFractionWithRoots", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( -1/(2*sqrt(3)), -sqrt(frac(1,12)) )",
		comment="",
		duration=0.003675,
		simplifyStack={"Init", "sqrt:Prune:apply", "^:Prune:oneToTheX", "*:Prune:apply", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "Prune", "Expand", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Constant:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "/:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertNe( -sqrt(frac(1,12)), sqrt(frac(1,12)) )",
		comment="",
		duration=0.004056,
		simplifyStack={"Init", "sqrt:Prune:apply", "Prune", "^:Expand:frac", "Expand", "^:Prune:oneToTheX", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Expand", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( (sqrt(2)*sqrt(frac(1,3))) * -frac(1,3) + (-frac(1,2)) * (sqrt(2)/sqrt(3)) + (frac(1,2)*1/sqrt(3)) * (-sqrt(2)/3), -sqrt(2) / sqrt(3) )",
		comment="",
		duration=0.010201,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Constant:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "*:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "/:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( 1 + ( -(7 - 3*sqrt(5)) / (3*(3 - sqrt(5))) )*(1 + frac(1,2)), (1 + sqrt(5))/4 )",
		comment="",
		duration=0.006829,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( (-(sqrt(5)-1)/2)/sqrt((-(sqrt(5)-1)/2)^2 + 1), -sqrt( (sqrt(5) - 1) / (2 * sqrt(5)) ))",
		comment="",
		duration=0.021243,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "+:Prune:combineConstants", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "Constant:Tidy:apply", "^:Tidy:replacePowerOfFractionWithRoots", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "+:Prune:combineConstants", "*:Prune:apply", "^:Prune:distributePow", "^:Prune:expandMulOfLikePow", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "Prune", "^:Expand:integerPower", "^:Expand:integerPower", "^:Expand:frac", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "*:Prune:apply", "*:Prune:apply", "unm:Prune:doubleNegative", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "*:Prune:apply", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "^:Prune:xToTheZero", "*:Prune:apply", "/:Prune:divToPowSub", "*:Prune:factorDenominators", "+:Prune:combineConstants", "/:Prune:zeroOverX", "+:Prune:factorOutDivs", "^:Prune:xToTheZero", "*:Prune:apply", "*:Prune:apply", "*:Prune:factorDenominators", "unm:Prune:doubleNegative", "^:Prune:sqrtFix4", "/:Prune:prodOfSqrtOverProdOfSqrt", "/:Prune:divToPowSub", "/:Prune:mulBySqrtConj", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(sqrt(frac(15,16)) * sqrt(frac(2,3)), sqrt(5)/(2*sqrt(2)))",
		comment="",
		duration=0.003198,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "*:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "^:Tidy:replacePowerOfFractionWithRoots", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="simplify() was introducing an unflattened mul where there originally was none", duration=0},
	{code="", comment="TODO NOTICE - if there's just sqrt(2)*sqrt(3) then the sqrts will merge ... so should they merge if that extra 2 is out front?", duration=0},
	{
		code="local expr = 2*sqrt(2)*sqrt(3) local sexpr = expr() printbr(symmath.op.eq(Verbose(expr), Verbose(sexpr))) simplifyAssertEq(expr,sexpr)",
		comment="",
		duration=0.001654,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "^:Prune:sqrtFix4", "*:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "^:Prune:sqrtFix4", "Prune", "^:Tidy:replacePowerOfFractionWithRoots", "^:Tidy:replacePowerOfFractionWithRoots", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="", duration=0},
	{code="", comment="these go bad when I don't have mul/Prune/combineMulOfLikePow_mulPowAdd", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( ( sqrt(f) * (g + f * sqrt(g)) )() , sqrt(f) * sqrt(g) * (sqrt(g) + f))",
		comment="",
		duration=0.008893,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:flattenAddMul", "^:Prune:xToTheOne", "*:Prune:apply", "+:Prune:combineConstants", "+:Prune:factorOutDivs", "+:Prune:combineConstants", "*:Prune:apply", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( ( sqrt(f) * (g + sqrt(g)) )() , sqrt(f) * sqrt(g) * (sqrt(g) + 1))",
		comment="",
		duration=0.004229,
		simplifyStack={"Init", "sqrt:Prune:apply", "sqrt:Prune:apply", "sqrt:Prune:apply", "+:Prune:combineConstants", "Prune", "*:Expand:apply", "Expand", "*:Prune:apply", "/:Prune:xOverX", "*:Prune:factorDenominators", "+:Prune:flattenAddMul", "^:Prune:xToTheOne", "*:Prune:apply", "Prune", "*:Factor:combineMulOfLikePow", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="", duration=0},
	{code="", comment="hmm having constant factor and sqrt/pow simplification problems", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( sqrt(15) - sqrt(15), 0)",
		comment="works",
		duration=0.000248,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( sqrt(6) - sqrt(Constant(2)*3), 0)",
		comment="works",
		duration=0.000306,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( sqrt(6) - sqrt(2)*sqrt(3), 0)",
		comment="",
		duration=0.000277,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( sqrt(15)/2 - sqrt(15)/2, 0)",
		comment="",
		duration=0.00069699999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( sqrt(6*x) - sqrt(2)*sqrt(3)*sqrt(x), 0)",
		comment="",
		duration=0.000503,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( (3+sqrt(5)) * (3 - sqrt(5)), 4 )",
		comment="without the extra product our difference-of-squares picks up fine ...",
		duration=0.00095700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertEq( (4 * sqrt(3+sqrt(5)))(), 4 * sqrt(3+sqrt(5))  )",
		comment="and it does recognize without the sqrts as a simplified form ...",
		duration=0.00065700000000002,
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( (3+sqrt(5)) * (3 - sqrt(5)) * sqrt(3+sqrt(5)) , 4 * sqrt(3+sqrt(5)))",
		comment="but with and extra product of a sqrt of a sum ... it doesn't",
		duration=0.004623,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:117: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:117: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq( (3+sqrt(5)) * (3 - sqrt(5))...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:230: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:229>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:229: in function 'exec'\n\9./sqrt.lua:118: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9./sqrt.lua:9: in main chunk\n\9[C]: at 0x5624838102f0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "Expand", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="these are in simplification loops", duration=0},
	{code="", comment="", duration=0},
	{code="", comment="start with -1 / ( (√√5 √(√5 - 1)) / √2 ) ... what mine gets now vs what mathematica gets", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( -1 / ( sqrt(sqrt(5) * (sqrt(5) - 1)) / sqrt(2) ), sqrt((5  + sqrt(5)) / 10))",
		comment="",
		duration=0.019793,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:117: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:117: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq( -1 / ( sqrt(sqrt(5) * (sqrt...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:230: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:229>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:229: in function 'exec'\n\9./sqrt.lua:118: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9./sqrt.lua:9: in main chunk\n\9[C]: at 0x5624838102f0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "^:Expand:frac", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq( -(sqrt( 10 * (sqrt(5) - 1) ) + sqrt(2 * (sqrt(5) - 1))) / (4 * sqrt(sqrt(5))), sqrt((5  + sqrt(5)) / 10))",
		comment="",
		duration=0.014399,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:117: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:117: in function 'simplifyAssertEq'\n\9[string \"simplifyAssertEq( -(sqrt( 10 * (sqrt(5) - 1) ...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:230: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:229>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:229: in function 'exec'\n\9./sqrt.lua:118: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9./sqrt.lua:9: in main chunk\n\9[C]: at 0x5624838102f0",
		simplifyStack={"Init", "^:Prune:sqrtFix4", "sqrt:Prune:apply", "sqrt:Prune:apply", "Prune", "^:Expand:frac", "Expand", "^:Prune:sqrtFix4", "^:Prune:sqrtFix4", "Prune", "Factor", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}