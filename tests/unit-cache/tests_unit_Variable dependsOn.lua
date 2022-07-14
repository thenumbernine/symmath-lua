{
	{code="", comment="testing dependency", duration=2.000000000002e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=2.4999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars(), 0)",
		comment="",
		duration=9.1000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^p':getDependentVars(), 0)",
		comment="",
		duration=6.9e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(y))",
		comment="depends regardless of specification",
		duration=7.8000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(y'^p'))",
		comment="was not specified",
		duration=6.8000000000006e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^p':dependsOn(y))",
		comment="was not specified",
		duration=0.000157,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^p':dependsOn(y'^q'))",
		comment="depends regardless of specification",
		duration=9.5999999999999e-05,
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
		code="y:setDependentVars(x'^a')",
		comment="",
		duration=2.9999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars() == 1 and y:getDependentVars()[1], x'^a')",
		comment="",
		duration=0.000116,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^p':getDependentVars(), 0)",
		comment="",
		duration=6.2e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^pq':getDependentVars(), 0)",
		comment="",
		duration=0.000117,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^p':dependsOn(x))",
		comment="was not specified",
		duration=0.000181,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^p':dependsOn(x'^q'))",
		comment="was not specified",
		duration=0.00011700000000001,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x'^q'))",
		comment="was specified",
		duration=0.000173,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="was not specified",
		duration=6.2e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="not by default",
		duration=5.2999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=0.000161,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=9.4999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=6.0999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=0.000153,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=0.000119,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=0.0002,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=0.000304,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=0.00012300000000001,
		simplifyStack={}
	},
	{
		code="y:setDependentVars(x)",
		comment="",
		duration=1.7999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars() == 1 and y:getDependentVars()[1], x)",
		comment="",
		duration=5.9000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^p':getDependentVars(), 0)",
		comment="",
		duration=0.000145,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^pq':getDependentVars(), 0)",
		comment="",
		duration=0.000303,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x))",
		comment="",
		duration=5.3999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=0.000193,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=0.000101,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=0.000108,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=0.000148,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=0.000133,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=5.5999999999994e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=0.000117,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=6.4000000000002e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="TODO this should be in tests/unit/diff.lua", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(y:diff(y), 1)",
		comment="",
		duration=0.00074999999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertEq(y:diff(x)(), y:diff(x))",
		comment="assert and not simplifyAssertEq so the rhs doesn't simplify",
		duration=0.00087400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), zero)",
		comment="",
		duration=0.001058,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=0.000908,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), zero)",
		comment="",
		duration=0.000444,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), zero)",
		comment="",
		duration=0.000372,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.000376,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.00033,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=0.000494,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.000475,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x,z), zero)",
		comment="",
		duration=0.000277,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq(y'^p':diff(y'^q'), delta'^p_q')",
		comment="",
		duration=0.001311,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'_p':diff(y'_q'), delta'_p^q')",
		comment="",
		duration=0.001411,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'_p':diff(y'^q'), g'_pq')",
		comment="",
		duration=0.00118,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^p':diff(y'_q'), g'^pq')",
		comment="",
		duration=0.001562,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq(y'^pq':diff(y'^rs'), delta'^p_r' * delta'^q_s')",
		comment="",
		duration=0.003565,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
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
		duration=2.6999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars(), 1)",
		comment="",
		duration=6.9e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^a':getDependentVars(), 0)",
		comment="",
		duration=5.0999999999995e-05,
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
		duration=4.7999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=0.000128,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=4.6999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=0.00013,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=7.1000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=5.9999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=6.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=0.000185,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(y:diff(x), zero)",
		comment="",
		duration=0.00029999999999999,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), y:diff(x'^p'))",
		comment="",
		duration=0.000981,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=0.000191,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), zero)",
		comment="",
		duration=0.000374,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), zero)",
		comment="",
		duration=0.000236,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.000365,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.00036,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=0.000292,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.000277,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="y'^a':setDependentVars(x)",
		comment="",
		duration=2.8e-05,
		simplifyStack={}
	},
	{
		code="assertEq(#y:getDependentVars(), 0)",
		comment="",
		duration=0.00022399999999999,
		simplifyStack={}
	},
	{
		code="assertEq(#y'^a':getDependentVars(), 1)",
		comment="",
		duration=0.000142,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="",
		duration=4.2e-05,
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
		duration=6.0000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^i':dependsOn(x))",
		comment="",
		duration=4.2e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=5.200000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=0.00025699999999999,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=4.8000000000006e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=4.6000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(y:diff(x), zero)",
		comment="",
		duration=0.000207,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), zero)",
		comment="",
		duration=0.00024200000000001,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=0.000265,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), y'^i':diff(x))",
		comment="",
		duration=0.000934,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), zero)",
		comment="",
		duration=0.000433,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.00031100000000001,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.000179,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=0.000264,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.00022899999999999,
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
		duration=3.7999999999996e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x))",
		comment="",
		duration=4.6999999999991e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^p'))",
		comment="",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^pq'))",
		comment="",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x))",
		comment="",
		duration=5.2999999999997e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^i':dependsOn(x'^p'))",
		comment="",
		duration=5.0999999999995e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^i':dependsOn(x'^pq'))",
		comment="",
		duration=5.7000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x))",
		comment="",
		duration=4.2e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^p'))",
		comment="",
		duration=6.0999999999992e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^ij':dependsOn(x'^pq'))",
		comment="",
		duration=4.9000000000007e-05,
		simplifyStack={}
	},
	{
		code="simplifyAssertEq(y:diff(x), zero)",
		comment="",
		duration=0.00028400000000001,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^p'), zero)",
		comment="",
		duration=0.000193,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y:diff(x'^pq'), zero)",
		comment="",
		duration=0.00017499999999999,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x), zero)",
		comment="",
		duration=0.000167,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^p'), y'^i':diff(x'^p'))",
		comment="",
		duration=0.000943,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^i':diff(x'^pq'), zero)",
		comment="",
		duration=0.00021299999999999,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x), zero)",
		comment="",
		duration=0.000179,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^p'), zero)",
		comment="",
		duration=0.000237,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(y'^ij':diff(x'^pq'), zero)",
		comment="",
		duration=0.000236,
		simplifyStack={"Init", "Derivative:Prune:other", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="testing graph dependency z(y(x)), z depends on x", duration=9.9999999998712e-07},
	{
		code="x = symmath.var'x'",
		comment="",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="y = symmath.var('y', {x})",
		comment="",
		duration=1.9000000000005e-05,
		simplifyStack={}
	},
	{
		code="z = symmath.var('z', {y})",
		comment="",
		duration=6.0000000000004e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(true, z:dependsOn(z))",
		comment="",
		duration=4.7000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, z:dependsOn(y))",
		comment="",
		duration=3.6000000000008e-05,
		simplifyStack={}
	},
	{code="", comment="hmm, how to handle graph dependencies ...", duration=0},
	{code="", comment="I'm not going to evaluate them for now, because they cause", duration=1.000000000001e-06},
	{code="", comment="(1) infinite loops (unless I track search state) and", duration=1.000000000001e-06},
	{code="", comment="(2) {u,v} depends on {t,x} makes a graph search produce u depends on v ...", duration=1.000000000001e-06},
	{code="", comment="assertEq(true, z:dependsOn(x))", duration=1.000000000001e-06},
	{
		code="assertEq(false, y:dependsOn(z))",
		comment="",
		duration=4.7999999999992e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(y))",
		comment="",
		duration=3.5000000000007e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(x))",
		comment="",
		duration=3.5000000000007e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(z))",
		comment="",
		duration=3.199999999999e-05,
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
	{code="", comment="", duration=0},
	{
		code="assertEq(false, z:dependsOn(z'^I'))",
		comment="",
		duration=4.7000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z:dependsOn(y'^I'))",
		comment="",
		duration=4.2e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z:dependsOn(x'^I'))",
		comment="",
		duration=4.0999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(z'^I'))",
		comment="",
		duration=6.4000000000008e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(y'^I'))",
		comment="",
		duration=0.000137,
		simplifyStack={}
	},
	{
		code="assertEq(false, y:dependsOn(x'^I'))",
		comment="",
		duration=4.7000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(z'^I'))",
		comment="",
		duration=3.9999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(y'^I'))",
		comment="",
		duration=3.9999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x:dependsOn(x'^I'))",
		comment="",
		duration=4.2e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(false, z'^I':dependsOn(z))",
		comment="",
		duration=4.3000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(y))",
		comment="",
		duration=4.6000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(x))",
		comment="",
		duration=0.000108,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(z))",
		comment="",
		duration=4.5000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(y))",
		comment="",
		duration=0.000191,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(x))",
		comment="",
		duration=4.5000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(z))",
		comment="",
		duration=3.9999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(y))",
		comment="",
		duration=4.6999999999991e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(x))",
		comment="",
		duration=4.1000000000013e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(true, z'^I':dependsOn(z'^I'))",
		comment="by default",
		duration=4.4000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(y'^I'))",
		comment="",
		duration=4.5000000000003e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, z'^I':dependsOn(x'^I'))",
		comment="",
		duration=4.3000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(z'^I'))",
		comment="",
		duration=4.9999999999994e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y'^I':dependsOn(y'^I'))",
		comment="by default",
		duration=4.8999999999993e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, y'^I':dependsOn(x'^I'))",
		comment="",
		duration=5.8000000000002e-05,
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
		duration=4.3000000000001e-05,
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
	{code="", comment="testing graph dependency z(y(x'^I')), z depends on x", duration=1.000000000001e-06},
	{
		code="x = symmath.var'x'",
		comment="",
		duration=9.9999999999961e-06,
		simplifyStack={}
	},
	{
		code="y = symmath.var'y'",
		comment="",
		duration=1.000000000001e-05,
		simplifyStack={}
	},
	{
		code="y:setDependentVars(x'^I')",
		comment="",
		duration=1.9999999999992e-05,
		simplifyStack={}
	},
	{
		code="z = symmath.var'z'",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{
		code="z:setDependentVars(y)",
		comment="",
		duration=1.2000000000012e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertEq(true, z:dependsOn(z))",
		comment="",
		duration=4.4999999999989e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, z:dependsOn(y))",
		comment="",
		duration=0.00013100000000001,
		simplifyStack={}
	},
	{code="", comment="same as above, not doing a graph search.  should I?", duration=1.000000000001e-06},
	{code="", comment="assertEq(true, z:dependsOn(x'^I'))", duration=1.000000000001e-06},
	{
		code="assertEq(false, y:dependsOn(z))",
		comment="",
		duration=4.0999999999999e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, y:dependsOn(y))",
		comment="",
		duration=3.3999999999992e-05,
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
		duration=4.2e-05,
		simplifyStack={}
	},
	{
		code="assertEq(false, x'^I':dependsOn(y))",
		comment="",
		duration=4.2e-05,
		simplifyStack={}
	},
	{
		code="assertEq(true, x'^I':dependsOn(x'^I'))",
		comment="",
		duration=4.2e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="", duration=0},
	{code="", comment="make definite variable objects in our scope so implicit variable creation doesn't replace them and reset their state", duration=0},
	{code="", comment="alright, I'm at an impass here ...", duration=1.000000000001e-06},
	{code="", comment="before I fixed chain dependencies, I had a good system where {u,v}:depends{t,x} would only produce du/dt du/dx dv/dt dv/dx", duration=1.000000000001e-06},
	{code="", comment="but now, with chain dependencies, I'm also getting dv/du, du/dv, dt/dx, dx/dt ... and this is incorrect", duration=0},
	{
		code="u,v,t,x,y,z = vars('u','v','t','x','y','z')",
		comment="",
		duration=2.8e-05,
		simplifyStack={}
	},
	{
		code="u:setDependentVars(t,x)",
		comment="",
		duration=1.7000000000003e-05,
		simplifyStack={}
	},
	{
		code="v:setDependentVars(t,x)",
		comment="",
		duration=1.2000000000012e-05,
		simplifyStack={}
	},
	{
		code="t:setDependentVars(u,v)",
		comment="",
		duration=9.3999999999997e-05,
		simplifyStack={}
	},
	{
		code="x:setDependentVars(u,v)",
		comment="",
		duration=5.3999999999998e-05,
		simplifyStack={}
	},
	{
		code="allvars = table{u,v,t,x,y,z}",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="all = Matrix(allvars):T()",
		comment="",
		duration=0.000433,
		simplifyStack={}
	},
	{
		code="varofall = var('\\\\{'..allvars:mapi(function(v) return v.name end):concat','..'\\\\}')",
		comment="",
		duration=4.7000000000005e-05,
		simplifyStack={}
	},
	{
		code="print(varofall:diff(varofall):eq(Matrix:lambda({#all,#all}, function(i,j) return allvars[i]:diff(allvars[j])() end)))",
		comment="",
		duration=0.006445,
		simplifyStack={"Init", "Derivative:Prune:self", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}