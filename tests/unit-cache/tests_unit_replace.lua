{
	{
		code="a,b,c = symmath.vars('a', 'b', 'c')",
		comment="",
		duration=8.5000000000002e-05,
		simplifyStack={}
	},
	{
		code="x,y,z = symmath.vars('x', 'y', 'z')",
		comment="",
		duration=5.0000000000001e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="expr = a * x + b * y + c * z",
		comment="",
		duration=0.00015,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x, 1) == 1 + b * y + c * z)",
		comment="",
		duration=0.000234,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y, 1) == 1 + a * x + c * z)",
		comment="",
		duration=0.000338,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(c * z, 1) == 1 + a * x + b * y)",
		comment="",
		duration=0.00027,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + b * y, 1) == 1 + c * z)",
		comment="",
		duration=0.000221,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + c * z, 1) == 1 + b * y)",
		comment="",
		duration=0.000193,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y + c * z, 1) == 1 + a * x)",
		comment="",
		duration=0.000189,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y + c * z, 1) == 1 + a * x)",
		comment="",
		duration=0.000138,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + b * y + c * z, 1) == symmath.Constant(1))",
		comment="",
		duration=0.000211,
		simplifyStack={}
	}
}