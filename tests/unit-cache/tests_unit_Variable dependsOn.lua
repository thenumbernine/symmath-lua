{
	{code="", comment="testing dependency", duration=1.000000000001e-06},
	{code="", comment="", duration=9.9999999999753e-07},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.8000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars(), 0)",
		comment="",
		duration=7.9999999999976e-06,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^p':getDependentVars(), 0)",
		comment="",
		duration=1.8000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(y))",
		comment="depends regardless of specification",
		duration=5.9999999999991e-06,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(y'^p'))",
		comment="was not specified",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^p':dependsOn(y))",
		comment="was not specified",
		duration=1.1000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^p':dependsOn(y'^q'))",
		comment="depends regardless of specification",
		duration=1.3000000000003e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=5.9999999999991e-06,
		simplifyStack={}
	},
	{
		code="y:setDependentVars(x'^a')",
		comment="",
		duration=1.4e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars() == 1 and y:getDependentVars()[1], x'^a')",
		comment="",
		duration=1.6000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^p':getDependentVars(), 0)",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^pq':getDependentVars(), 0)",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^p':dependsOn(x))",
		comment="was not specified",
		duration=1.1000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^p':dependsOn(x'^q'))",
		comment="was not specified",
		duration=1.2000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x'^q'))",
		comment="was specified",
		duration=7.6e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="was not specified",
		duration=8.9999999999986e-06,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=9.9999999999996e-06,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="not by default",
		duration=8.0000000000011e-06,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=2.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=1.1000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=2.6999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=7.0999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=0.000102,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=1.7000000000003e-05,
		simplifyStack={}
	},
	{
		code="y:setDependentVars(x)",
		comment="",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars() == 1 and y:getDependentVars()[1], x)",
		comment="",
		duration=1.1000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^p':getDependentVars(), 0)",
		comment="",
		duration=4.0999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^pq':getDependentVars(), 0)",
		comment="",
		duration=8.1999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x))",
		comment="",
		duration=9.0000000000021e-06,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=1.4e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=6.4999999999996e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=1.5999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=3.2999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=1.8000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=2.2999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=1.4e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="TODO this should be in tests/unit/diff.lua", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(y:diff(y), 1)",
		comment="",
		duration=0.000369,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertEq(y:diff(x)(), y:diff(x))",
		comment="assert and not simplifyAssertEq so the rhs doesn't simplify",
		duration=0.000419,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), zero)",
		comment="",
		duration=0.00017200000000001,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=0.000263,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), zero)",
		comment="",
		duration=0.000156,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), zero)",
		comment="",
		duration=0.000113,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.000275,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.000206,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=0.000302,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.000294,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x,z), zero)",
		comment="",
		duration=7.9000000000003e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.9999999999951e-06},
	{
		code="simplifyAssertEq(y'^p':diff(y'^q'), delta'^p_q')",
		comment="",
		duration=0.000829,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'_p':diff(y'_q'), delta'_p^q')",
		comment="",
		duration=0.000758,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'_p':diff(y'^q'), g'_pq')",
		comment="",
		duration=0.000458,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^p':diff(y'_q'), g'^pq')",
		comment="",
		duration=0.000409,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertEq(y'^pq':diff(y'^rs'), delta'^p_r' * delta'^q_s')",
		comment="",
		duration=0.001013,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="y:setDependentVars(x'^a')",
		comment="",
		duration=2.1e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars(), 1)",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^a':getDependentVars(), 0)",
		comment="",
		duration=1.6000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x'^p'))",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=1.8000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=2.4000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=2.5999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=5.8000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=1.9000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=1.7999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=2.8e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(y:diff(x), zero)",
		comment="",
		duration=7.1000000000002e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), y:diff(x'^p'))",
		comment="",
		duration=0.00042499999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=0.000181,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), zero)",
		comment="",
		duration=6.3000000000001e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), zero)",
		comment="",
		duration=7.6999999999994e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.000116,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=9.7e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=9.7999999999994e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=9.2000000000002e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="y'^a':setDependentVars(x)",
		comment="",
		duration=2.3000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars(), 0)",
		comment="",
		duration=7.0000000000001e-06,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^a':getDependentVars(), 1)",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="",
		duration=1.1000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=1.8999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=1.6000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^i':dependsOn(x))",
		comment="",
		duration=1.6000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=1.7999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=2.9000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=1.9999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=1.7999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=2.1e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(y:diff(x), zero)",
		comment="",
		duration=5.3999999999998e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), zero)",
		comment="",
		duration=5.4999999999999e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=6.4999999999996e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), y'^i':diff(x))",
		comment="",
		duration=0.000589,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), zero)",
		comment="",
		duration=0.000122,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.000101,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.000183,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=8.5000000000002e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.000113,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="y'^a':setDependentVars(x'^b')",
		comment="",
		duration=4.0999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="",
		duration=1.0000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=1.9000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=9.9999999999961e-06,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=1.7999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=1.9999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=1.8999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=1.7999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=1.9999999999999e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(y:diff(x), zero)",
		comment="",
		duration=5.3000000000004e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), zero)",
		comment="",
		duration=5.7000000000001e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=7.8000000000002e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), zero)",
		comment="",
		duration=5.8000000000002e-05,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), y'^i':diff(x'^p'))",
		comment="",
		duration=0.000648,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.000238,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.000112,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=0.000123,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.000133,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="testing graph dependency z(y(x)), z depends on x", duration=9.9999999999406e-07},
	{
		code="x = symmath.var'x'",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="y = symmath.var('y', {x})",
		comment="",
		duration=3.2999999999998e-05,
		simplifyStack={}
	},
	{
		code="z = symmath.var('z', {y})",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(true, z:dependsOn(z))",
		comment="",
		duration=8.0000000000011e-06,
		simplifyStack={}
	},
	{
		code="assertEq(true, z:dependsOn(y))",
		comment="",
		duration=1.4e-05,
		simplifyStack={}
	},
	{code="", comment="hmm, how to handle graph dependencies ...", duration=9.9999999999406e-07},
	{code="", comment="I'm not going to evaluate them for now, because they cause", duration=1.000000000001e-06},
	{code="", comment="(1) infinite loops (unless I track search state) and", duration=1.000000000001e-06},
	{code="", comment="(2) {u,v} depends on {t,x} makes a graph search produce u depends on v ...", duration=1.000000000001e-06},
	{code="", comment="assertEq(true, z:dependsOn(x))", duration=1.000000000001e-06},
	{
		code="assertEq(false, y:dependsOn(z))",
		comment="",
		duration=5.4999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(y))",
		comment="",
		duration=7.0000000000001e-06,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x))",
		comment="",
		duration=4.3000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(z))",
		comment="",
		duration=8.0000000000011e-06,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(y))",
		comment="",
		duration=7.0000000000001e-06,
		simplifyStack={}
	},
	{
		code="assertEq(true, x:dependsOn(x))",
		comment="",
		duration=5.9999999999991e-06,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(false, z:dependsOn(z'^I'))",
		comment="",
		duration=1.5999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z:dependsOn(y'^I'))",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z:dependsOn(x'^I'))",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(z'^I'))",
		comment="",
		duration=7.9999999999941e-06,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(y'^I'))",
		comment="",
		duration=9.9999999999961e-06,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^I'))",
		comment="",
		duration=9.0000000000021e-06,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(z'^I'))",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(y'^I'))",
		comment="",
		duration=1.2000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(x'^I'))",
		comment="",
		duration=1.4e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(false, z'^I':dependsOn(z))",
		comment="",
		duration=1.8999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(y))",
		comment="",
		duration=2.4000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(x))",
		comment="",
		duration=1.8000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(z))",
		comment="",
		duration=2.5999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(y))",
		comment="",
		duration=1.7000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(x))",
		comment="",
		duration=2.8e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(z))",
		comment="",
		duration=2.1e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(y))",
		comment="",
		duration=1.8999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(x))",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(true, z'^I':dependsOn(z'^I'))",
		comment="by default",
		duration=1.7999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(y'^I'))",
		comment="",
		duration=1.7999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(x'^I'))",
		comment="",
		duration=1.6000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(z'^I'))",
		comment="",
		duration=2.8e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^I':dependsOn(y'^I'))",
		comment="by default",
		duration=4.5999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(x'^I'))",
		comment="",
		duration=2.5999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(z'^I'))",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(y'^I'))",
		comment="",
		duration=1.3000000000006e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, x'^I':dependsOn(x'^I'))",
		comment="by default",
		duration=1.6999999999996e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="testing graph dependency z(y(x'^I')), z depends on x", duration=1.9999999999951e-06},
	{
		code="x = symmath.var'x'",
		comment="",
		duration=1.9999999999999e-05,
		simplifyStack={}
	},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=7.0000000000001e-06,
		simplifyStack={}
	},
	{
		code="y:setDependentVars(x'^I')",
		comment="",
		duration=8.3e-05,
		simplifyStack={}
	},
	{
		code="z = symmath.var'z'",
		comment="",
		duration=1.4e-05,
		simplifyStack={}
	},
	{
		code="z:setDependentVars(y)",
		comment="",
		duration=6.4000000000002e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{
		code="assertEq(true, z:dependsOn(z))",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, z:dependsOn(y))",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{code="", comment="same as above, not doing a graph search.  should I?", duration=1.000000000001e-06},
	{code="", comment="assertEq(true, z:dependsOn(x'^I'))", duration=1.000000000001e-06},
	{
		code="assertEq(false, y:dependsOn(z))",
		comment="",
		duration=1.7999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(y))",
		comment="",
		duration=9.9999999999961e-06,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x'^I'))",
		comment="",
		duration=2.2999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(z))",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(y))",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, x'^I':dependsOn(x'^I'))",
		comment="",
		duration=1.9999999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="make definite variable objects in our scope so implicit variable creation doesn't replace them and reset their state", duration=1.000000000001e-06},
	{code="", comment="alright, I'm at an impass here ...", duration=1.000000000001e-06},
	{code="", comment="before I fixed chain dependencies, I had a good system where {u,v}:depends{t,x} would only produce du/dt du/dx dv/dt dv/dx", duration=2.000000000002e-06},
	{code="", comment="but now, with chain dependencies, I'm also getting dv/du, du/dv, dt/dx, dx/dt ... and this is incorrect", duration=1.000000000001e-06},
	{
		code="u,v,t,x,y,z = vars('u','v','t','x','y','z')",
		comment="",
		duration=0.00017,
		simplifyStack={}
	},
	{
		code="u:setDependentVars(t,x)",
		comment="",
		duration=2.2000000000001e-05,
		simplifyStack={}
	},
	{
		code="v:setDependentVars(t,x)",
		comment="",
		duration=3.2999999999998e-05,
		simplifyStack={}
	},
	{
		code="t:setDependentVars(u,v)",
		comment="",
		duration=1.9999999999999e-05,
		simplifyStack={}
	},
	{
		code="x:setDependentVars(u,v)",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="allvars = table{u,v,t,x,y,z}",
		comment="",
		duration=1.4999999999994e-05,
		simplifyStack={}
	},
	{
		code="all = Matrix(allvars):T()",
		comment="",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="varofall = var('\\\\{'..allvars:mapi(function(v) return v.name end):concat','..'\\\\}')",
		comment="",
		duration=7.5000000000006e-05,
		simplifyStack={}
	},
	{
		code="print(varofall:diff(varofall):eq(Matrix:lambda({#all,#all}, function(i,j) return allvars[i]:diff(allvars[j])() end)))",
		comment="",
		duration=0.005464,
		simplifyStack={"Init", "Derivative:Prune:self", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}