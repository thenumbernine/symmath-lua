{
	{
		code="for k,v in pairs( const(1):polyCoeffs(x) ) do printbr(k, '=', v) end",
		comment="",
		duration=0.000243,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq( const(1):polyCoeffs(x), {[0]=const(1)})",
		comment="",
		duration=0.000975,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.9999999999985e-06},
	{
		code="simplifyAssertAllEq( x:polyCoeffs(x), {[1]=const(1)} )",
		comment="",
		duration=0.000716,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq( sin(x):polyCoeffs(x), {extra=sin(x)} )",
		comment="",
		duration=0.000573,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq( (x^2 - a):polyCoeffs(x), {[0]=-a, [2]=const(1)} )",
		comment="",
		duration=0.003867,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq( (x^2 - 2 * a * x + a^2):polyCoeffs(x), {[0]=a^2, [1]=-2*a, [2]=const(1)} )",
		comment="",
		duration=0.002769,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}