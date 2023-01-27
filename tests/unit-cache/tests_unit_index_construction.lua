{
	{
		code="local x=a'i' \9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false})",
		comment="upper by default",
		duration=0.00012899999999999,
		simplifyStack={}
	},
	{
		code="local x=a'^i' \9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false})",
		comment="",
		duration=0.000127,
		simplifyStack={}
	},
	{
		code="local x=a'_i' \9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true})",
		comment="",
		duration=0.00013700000000001,
		simplifyStack={}
	},
	{
		code="local x=a'ij' \9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=false})",
		comment="",
		duration=0.00036,
		simplifyStack={}
	},
	{
		code="local x=a'i_j' \9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=true})",
		comment="",
		duration=0.00017500000000001,
		simplifyStack={}
	},
	{
		code="local x=a'^ij' \9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=false})",
		comment="",
		duration=0.000137,
		simplifyStack={}
	},
	{
		code="local x=a'^i_j'\9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=true})",
		comment="",
		duration=0.00013400000000001,
		simplifyStack={}
	},
	{
		code="local x=a'_i^j'\9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true} and x[3]==Tensor.Index{symbol='j', lower=false})",
		comment="",
		duration=0.00026100000000001,
		simplifyStack={}
	},
	{
		code="local x=a'_ij' \9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true} and x[3]==Tensor.Index{symbol='j', lower=true})",
		comment="",
		duration=0.00040999999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="multi-char", duration=3.000000000003e-06},
	{
		code="local x=a' i' \9\9\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false})",
		comment="upper by default",
		duration=0.00021699999999999,
		simplifyStack={}
	},
	{
		code="local x=a' \\\\mu' \9\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='\\\\mu', lower=false})",
		comment="upper by default",
		duration=0.000127,
		simplifyStack={}
	},
	{
		code="local x=a' ^\\\\mu' \9\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='\\\\mu', lower=false})",
		comment="",
		duration=0.00014400000000001,
		simplifyStack={}
	},
	{
		code="local x=a' _\\\\mu' \9\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='\\\\mu', lower=true})",
		comment="",
		duration=0.00010499999999999,
		simplifyStack={}
	},
	{
		code="local x=a' \\\\mu \\\\nu' print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='\\\\mu', lower=false} and x[3]==Tensor.Index{symbol='\\\\nu', lower=false})",
		comment="",
		duration=0.00014500000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="local x=a',i'\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true, derivative=','})",
		comment="commas are lower by default",
		duration=0.000108,
		simplifyStack={}
	},
	{
		code="local x=a',^i'\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false, derivative=','})",
		comment="",
		duration=0.00014700000000001,
		simplifyStack={}
	},
	{
		code="local x=a',_i'\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true, derivative=','})",
		comment="",
		duration=0.000127,
		simplifyStack={}
	},
	{
		code="local x=a'^,i'\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false, derivative=','})",
		comment="",
		duration=0.000122,
		simplifyStack={}
	},
	{
		code="local x=a'_,i'\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true, derivative=','})",
		comment="",
		duration=0.00034100000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="TODO multiple indexes with commas mixed", duration=3.9999999999901e-06},
	{code="", comment="TODO multiple indexes with commas mixed with multiple chars", duration=3.000000000003e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertNe(a'^,i', a'_,i')",
		comment="",
		duration=0.004488,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}