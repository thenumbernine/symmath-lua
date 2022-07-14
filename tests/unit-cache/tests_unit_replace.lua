{
	{
		code="a,b,c = symmath.vars('a', 'b', 'c')",
		comment="",
		duration=4.5999999999997e-05,
		simplifyStack={}
	},
	{
		code="x,y,z = symmath.vars('x', 'y', 'z')",
		comment="",
		duration=3.2000000000004e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="expr = a * x + b * y + c * z",
		comment="",
		duration=0.00040800000000001,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x, 1) == 1 + b * y + c * z)",
		comment="",
		duration=0.000509,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y, 1) == 1 + a * x + c * z)",
		comment="",
		duration=0.00073,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(c * z, 1) == 1 + a * x + b * y)",
		comment="",
		duration=0.000389,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + b * y, 1) == 1 + c * z)",
		comment="",
		duration=0.000406,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + c * z, 1) == 1 + b * y)",
		comment="",
		duration=0.000171,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y + c * z, 1) == 1 + a * x)",
		comment="",
		duration=0.00042,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y + c * z, 1) == 1 + a * x)",
		comment="",
		duration=0.000405,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + b * y + c * z, 1) == symmath.Constant(1))",
		comment="",
		duration=0.000205,
		simplifyStack={}
	}
}