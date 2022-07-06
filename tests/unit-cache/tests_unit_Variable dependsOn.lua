{
	{code="", comment="testing dependency", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=2.6000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars(), 0)",
		comment="",
		duration=0.000103,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^p':getDependentVars(), 0)",
		comment="",
		duration=6.6999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(y))",
		comment="depends regardless of specification",
		duration=5.7000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(y'^p'))",
		comment="was not specified",
		duration=6.6999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^p':dependsOn(y))",
		comment="was not specified",
		duration=0.000144,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^p':dependsOn(y'^q'))",
		comment="depends regardless of specification",
		duration=7.4999999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="y:setDependentVars(x'^a')",
		comment="",
		duration=3.0000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars() == 1 and y:getDependentVars()[1], x'^a')",
		comment="",
		duration=0.000178,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^p':getDependentVars(), 0)",
		comment="",
		duration=6.5000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^pq':getDependentVars(), 0)",
		comment="",
		duration=0.00012599999999999,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^p':dependsOn(x))",
		comment="was not specified",
		duration=0.00019300000000001,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^p':dependsOn(x'^q'))",
		comment="was not specified",
		duration=0.000125,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x'^q'))",
		comment="was specified",
		duration=7.0000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="was not specified",
		duration=6.7000000000005e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="not by default",
		duration=0.000121,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=0.000149,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=0.000224,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=0.0001,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=0.000133,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=7.3000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=6.9e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=0.00011,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=0.000129,
		simplifyStack={}
	},
	{
		code="y:setDependentVars(x)",
		comment="",
		duration=1.9000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars() == 1 and y:getDependentVars()[1], x)",
		comment="",
		duration=5.6e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^p':getDependentVars(), 0)",
		comment="",
		duration=7.3000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^pq':getDependentVars(), 0)",
		comment="",
		duration=0.000122,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x))",
		comment="",
		duration=8.3e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=0.000133,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=0.000204,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=7.2000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=6.3000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=7.8000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=7.9999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=0.000131,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=0.000154,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO this should be in tests/unit/diff.lua", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(y:diff(y), 1)",
		comment="",
		duration=0.000658,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertEq(y:diff(x)(), y:diff(x))",
		comment="assert and not simplifyAssertEq so the rhs doesn't simplify",
		duration=0.000874,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), zero)",
		comment="",
		duration=0.000593,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=0.000853,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), zero)",
		comment="",
		duration=0.000279,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), zero)",
		comment="",
		duration=0.000473,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.000352,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.000344,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=0.000828,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.000828,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x,z), zero)",
		comment="",
		duration=0.000284,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(y'^p':diff(y'^q'), delta'^p_q')",
		comment="",
		duration=0.001536,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'_p':diff(y'_q'), delta'_p^q')",
		comment="",
		duration=0.002013,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'_p':diff(y'^q'), g'_pq')",
		comment="",
		duration=0.000942,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^p':diff(y'_q'), g'^pq')",
		comment="",
		duration=0.001344,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(y'^pq':diff(y'^rs'), delta'^p_r' * delta'^q_s')",
		comment="",
		duration=0.003268,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.6999999999996e-05,
		simplifyStack={}
	},
	{
		code="y:setDependentVars(x'^a')",
		comment="",
		duration=2.8e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars(), 1)",
		comment="",
		duration=7.0000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^a':getDependentVars(), 0)",
		comment="",
		duration=5.1000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="",
		duration=4.5999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x'^p'))",
		comment="",
		duration=5.0999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=6.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=4.8999999999993e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=0.000282,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=0.00011800000000001,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=0.00011,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=0.00017,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=7.5000000000006e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(y:diff(x), zero)",
		comment="",
		duration=0.000199,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), y:diff(x'^p'))",
		comment="",
		duration=0.000776,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=0.000196,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), zero)",
		comment="",
		duration=0.000209,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), zero)",
		comment="",
		duration=0.00032800000000001,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.00055200000000001,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.000302,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=0.000278,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.000206,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.5999999999997e-05},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=2.8e-05,
		simplifyStack={}
	},
	{
		code="y'^a':setDependentVars(x)",
		comment="",
		duration=4.2e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars(), 0)",
		comment="",
		duration=6.4000000000008e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^a':getDependentVars(), 1)",
		comment="",
		duration=4.5000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=0.000178,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=7.6999999999994e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^i':dependsOn(x))",
		comment="",
		duration=4.7000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=6.0999999999992e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=7.7999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=4.5000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=4.8999999999993e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=5.0000000000008e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(y:diff(x), zero)",
		comment="",
		duration=0.000153,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), zero)",
		comment="",
		duration=0.000267,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=0.00017,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), y'^i':diff(x))",
		comment="",
		duration=0.00060700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), zero)",
		comment="",
		duration=0.000281,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.000319,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.000212,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=0.00018799999999999,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.000247,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="y'^a':setDependentVars(x'^b')",
		comment="",
		duration=3.8999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=4.2e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=4.3999999999988e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=4.2e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=0.00016999999999999,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=8.0999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=4.7999999999992e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=5.0000000000008e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(y:diff(x), zero)",
		comment="",
		duration=0.000329,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), zero)",
		comment="",
		duration=0.00015599999999999,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=0.00016000000000001,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), zero)",
		comment="",
		duration=0.000208,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), y'^i':diff(x'^p'))",
		comment="",
		duration=0.00119,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.000276,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.000197,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=0.00018600000000001,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.000226,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="testing graph dependency z(y(x)), z depends on x", duration=1.000000000001e-06},
	{
		code="x = symmath.var'x'",
		comment="",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="y = symmath.var('y', {x})",
		comment="",
		duration=2.0000000000006e-05,
		simplifyStack={}
	},
	{
		code="z = symmath.var('z', {y})",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="assertEq(true, z:dependsOn(z))",
		comment="",
		duration=4.3000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, z:dependsOn(y))",
		comment="",
		duration=3.7999999999996e-05,
		simplifyStack={}
	},
	{code="", comment="hmm, how to handle graph dependencies ...", duration=1.000000000001e-06},
	{code="", comment="I'm not going to evaluate them for now, because they cause", duration=1.000000000001e-06},
	{code="", comment="(1) infinite loops (unless I track search state) and", duration=0},
	{code="", comment="(2) {u,v} depends on {t,x} makes a graph search produce u depends on v ...", duration=1.000000000001e-06},
	{code="", comment="assertEq(true, z:dependsOn(x))", duration=0},
	{
		code="assertEq(false, y:dependsOn(z))",
		comment="",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(y))",
		comment="",
		duration=3.3000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x))",
		comment="",
		duration=3.3000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(z))",
		comment="",
		duration=5.0999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(y))",
		comment="",
		duration=3.0999999999989e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, x:dependsOn(x))",
		comment="",
		duration=3.199999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(false, z:dependsOn(z'^I'))",
		comment="",
		duration=9.3999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z:dependsOn(y'^I'))",
		comment="",
		duration=4.6000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z:dependsOn(x'^I'))",
		comment="",
		duration=9.2000000000009e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(z'^I'))",
		comment="",
		duration=8.1999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(y'^I'))",
		comment="",
		duration=4.3000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^I'))",
		comment="",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(z'^I'))",
		comment="",
		duration=3.8999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(y'^I'))",
		comment="",
		duration=3.8999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(x'^I'))",
		comment="",
		duration=3.4000000000006e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(false, z'^I':dependsOn(z))",
		comment="",
		duration=3.7000000000009e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(y))",
		comment="",
		duration=4.3999999999988e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(x))",
		comment="",
		duration=3.6999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(z))",
		comment="",
		duration=3.7999999999996e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(y))",
		comment="",
		duration=3.7999999999996e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(x))",
		comment="",
		duration=3.8999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(z))",
		comment="",
		duration=3.7000000000009e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(y))",
		comment="",
		duration=3.6999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(x))",
		comment="",
		duration=3.6999999999995e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(true, z'^I':dependsOn(z'^I'))",
		comment="by default",
		duration=0.000123,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(y'^I'))",
		comment="",
		duration=5.3999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(x'^I'))",
		comment="",
		duration=9.7e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(z'^I'))",
		comment="",
		duration=4.8999999999993e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^I':dependsOn(y'^I'))",
		comment="by default",
		duration=5.1000000000009e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(x'^I'))",
		comment="",
		duration=4.6999999999991e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(z'^I'))",
		comment="",
		duration=4.6000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(y'^I'))",
		comment="",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, x'^I':dependsOn(x'^I'))",
		comment="by default",
		duration=4.2e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="testing graph dependency z(y(x'^I')), z depends on x", duration=0},
	{
		code="x = symmath.var'x'",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=7.9999999999941e-06,
		simplifyStack={}
	},
	{
		code="y:setDependentVars(x'^I')",
		comment="",
		duration=0.00010299999999999,
		simplifyStack={}
	},
	{
		code="z = symmath.var'z'",
		comment="",
		duration=1.000000000001e-05,
		simplifyStack={}
	},
	{
		code="z:setDependentVars(y)",
		comment="",
		duration=1.4e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(true, z:dependsOn(z))",
		comment="",
		duration=5.7000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, z:dependsOn(y))",
		comment="",
		duration=3.2999999999991e-05,
		simplifyStack={}
	},
	{code="", comment="same as above, not doing a graph search.  should I?", duration=1.000000000001e-06},
	{code="", comment="assertEq(true, z:dependsOn(x'^I'))", duration=0},
	{
		code="assertEq(false, y:dependsOn(z))",
		comment="",
		duration=3.2999999999991e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(y))",
		comment="",
		duration=3.0000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x'^I'))",
		comment="",
		duration=4.3000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(z))",
		comment="",
		duration=3.9000000000011e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(y))",
		comment="",
		duration=3.6999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, x'^I':dependsOn(x'^I'))",
		comment="",
		duration=4.0999999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="make definite variable objects in our scope so implicit variable creation doesn't replace them and reset their state", duration=1.000000000001e-06},
	{code="", comment="alright, I'm at an impass here ...", duration=1.000000000001e-06},
	{code="", comment="before I fixed chain dependencies, I had a good system where {u,v}:depends{t,x} would only produce du/dt du/dx dv/dt dv/dx", duration=1.000000000001e-06},
	{code="", comment="but now, with chain dependencies, I'm also getting dv/du, du/dv, dt/dx, dx/dt ... and this is incorrect", duration=1.000000000001e-06},
	{
		code="u,v,t,x,y,z = vars('u','v','t','x','y','z')",
		comment="",
		duration=7.8000000000009e-05,
		simplifyStack={}
	},
	{
		code="u:setDependentVars(t,x)",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="v:setDependentVars(t,x)",
		comment="",
		duration=1.4e-05,
		simplifyStack={}
	},
	{
		code="t:setDependentVars(u,v)",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="x:setDependentVars(u,v)",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="allvars = table{u,v,t,x,y,z}",
		comment="",
		duration=1.4e-05,
		simplifyStack={}
	},
	{
		code="all = Matrix(allvars):T()",
		comment="",
		duration=0.00025699999999999,
		simplifyStack={}
	},
	{
		code="varofall = var('\\\\{'..allvars:mapi(function(v) return v.name end):concat','..'\\\\}')",
		comment="",
		duration=0.00010599999999999,
		simplifyStack={}
	},
	{
		code="print(varofall:diff(varofall):eq(Matrix:lambda({#all,#all}, function(i,j) return allvars[i]:diff(allvars[j])() end)))",
		comment="",
		duration=0.005671,
		simplifyStack={"Init", "Derivative:Prune:self", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}