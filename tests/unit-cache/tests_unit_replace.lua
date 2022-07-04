{
	{
		code="a,b,c = symmath.vars('a', 'b', 'c')",
		comment="",
		duration=2.9000000000001e-05,
		simplifyStack={}
	},
	{
		code="x,y,z = symmath.vars('x', 'y', 'z')",
		comment="",
		duration=1.4e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="expr = a * x + b * y + c * z",
		comment="",
		duration=0.000424,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x, 1) == 1 + b * y + c * z)",
		comment="",
		duration=0.000157,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y, 1) == 1 + a * x + c * z)",
		comment="",
		duration=0.000276,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(c * z, 1) == 1 + a * x + b * y)",
		comment="",
		duration=0.00032500000000001,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + b * y, 1) == 1 + c * z)",
		comment="",
		duration=0.000133,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + c * z, 1) == 1 + b * y)",
		comment="",
		duration=0.000136,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y + c * z, 1) == 1 + a * x)",
		comment="",
		duration=0.000159,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y + c * z, 1) == 1 + a * x)",
		comment="",
		duration=0.000139,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + b * y + c * z, 1) == symmath.Constant(1))",
		comment="",
		duration=0.00012,
		simplifyStack={}
	}
}