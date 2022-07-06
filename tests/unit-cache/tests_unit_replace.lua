{
	{
		code="a,b,c = symmath.vars('a', 'b', 'c')",
		comment="",
		duration=4.6000000000004e-05,
		simplifyStack={}
	},
	{
		code="x,y,z = symmath.vars('x', 'y', 'z')",
		comment="",
		duration=2.5999999999998e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="expr = a * x + b * y + c * z",
		comment="",
		duration=0.000421,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x, 1) == 1 + b * y + c * z)",
		comment="",
		duration=0.000426,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y, 1) == 1 + a * x + c * z)",
		comment="",
		duration=0.000181,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(c * z, 1) == 1 + a * x + b * y)",
		comment="",
		duration=0.000335,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + b * y, 1) == 1 + c * z)",
		comment="",
		duration=0.000158,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + c * z, 1) == 1 + b * y)",
		comment="",
		duration=0.000101,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y + c * z, 1) == 1 + a * x)",
		comment="",
		duration=0.000397,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y + c * z, 1) == 1 + a * x)",
		comment="",
		duration=0.000163,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + b * y + c * z, 1) == symmath.Constant(1))",
		comment="",
		duration=6.5999999999997e-05,
		simplifyStack={}
	}
}