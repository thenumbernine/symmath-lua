{
	{
		code="a,b,c = symmath.vars('a', 'b', 'c')",
		comment="",
		duration=2.4999999999997e-05,
		simplifyStack={}
	},
	{
		code="x,y,z = symmath.vars('x', 'y', 'z')",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="expr = a * x + b * y + c * z",
		comment="",
		duration=0.000235,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x, 1) == 1 + b * y + c * z)",
		comment="",
		duration=0.000201,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y, 1) == 1 + a * x + c * z)",
		comment="",
		duration=0.000685,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(c * z, 1) == 1 + a * x + b * y)",
		comment="",
		duration=0.000343,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + b * y, 1) == 1 + c * z)",
		comment="",
		duration=0.000171,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + c * z, 1) == 1 + b * y)",
		comment="",
		duration=0.000119,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y + c * z, 1) == 1 + a * x)",
		comment="",
		duration=0.000112,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(b * y + c * z, 1) == 1 + a * x)",
		comment="",
		duration=0.000208,
		simplifyStack={}
	},
	{
		code="assert(expr:replace(a * x + b * y + c * z, 1) == symmath.Constant(1))",
		comment="",
		duration=0.000341,
		simplifyStack={}
	}
}