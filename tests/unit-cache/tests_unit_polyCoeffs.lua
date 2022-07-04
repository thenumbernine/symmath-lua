{
	{
		code="for k,v in pairs( const(1):polyCoeffs(x) ) do printbr(k, '=', v) end",
		comment="",
		duration=0.000166,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq( const(1):polyCoeffs(x), {[0]=const(1)})",
		comment="",
		duration=0.001131,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq( x:polyCoeffs(x), {[1]=const(1)} )",
		comment="",
		duration=0.000453,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq( sin(x):polyCoeffs(x), {extra=sin(x)} )",
		comment="",
		duration=0.001151,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq( (x^2 - a):polyCoeffs(x), {[0]=-a, [2]=const(1)} )",
		comment="",
		duration=0.002072,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq( (x^2 - 2 * a * x + a^2):polyCoeffs(x), {[0]=a^2, [1]=-2*a, [2]=const(1)} )",
		comment="",
		duration=0.005104,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}