{
	{
		code="local x=a'i' \9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false})",
		comment="upper by default",
		duration=0.000103,
		simplifyStack={}
	},
	{
		code="local x=a'^i' \9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false})",
		comment="",
		duration=7.1000000000002e-05,
		simplifyStack={}
	},
	{
		code="local x=a'_i' \9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true})",
		comment="",
		duration=7.0999999999995e-05,
		simplifyStack={}
	},
	{
		code="local x=a'ij' \9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=false})",
		comment="",
		duration=0.000135,
		simplifyStack={}
	},
	{
		code="local x=a'i_j' \9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=true})",
		comment="",
		duration=8.3e-05,
		simplifyStack={}
	},
	{
		code="local x=a'^ij' \9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=false})",
		comment="",
		duration=7.7000000000001e-05,
		simplifyStack={}
	},
	{
		code="local x=a'^i_j'\9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=true})",
		comment="",
		duration=7.0000000000001e-05,
		simplifyStack={}
	},
	{
		code="local x=a'_i^j'\9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true} and x[3]==Tensor.Index{symbol='j', lower=false})",
		comment="",
		duration=0.000167,
		simplifyStack={}
	},
	{
		code="local x=a'_ij' \9print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true} and x[3]==Tensor.Index{symbol='j', lower=true})",
		comment="",
		duration=0.000253,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="multi-char", duration=1.000000000001e-06},
	{
		code="local x=a' i' \9\9\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false})",
		comment="upper by default",
		duration=0.00013999999999999,
		simplifyStack={}
	},
	{
		code="local x=a' \\\\mu' \9\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='\\\\mu', lower=false})",
		comment="upper by default",
		duration=7.0000000000001e-05,
		simplifyStack={}
	},
	{
		code="local x=a' ^\\\\mu' \9\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='\\\\mu', lower=false})",
		comment="",
		duration=6.9e-05,
		simplifyStack={}
	},
	{
		code="local x=a' _\\\\mu' \9\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='\\\\mu', lower=true})",
		comment="",
		duration=8.4999999999995e-05,
		simplifyStack={}
	},
	{
		code="local x=a' \\\\mu \\\\nu' print(x)\9assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='\\\\mu', lower=false} and x[3]==Tensor.Index{symbol='\\\\nu', lower=false})",
		comment="",
		duration=8.7000000000004e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="local x=a',i'\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true, derivative=','})",
		comment="commas are lower by default",
		duration=6.6000000000004e-05,
		simplifyStack={}
	},
	{
		code="local x=a',^i'\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false, derivative=','})",
		comment="",
		duration=0.000175,
		simplifyStack={}
	},
	{
		code="local x=a',_i'\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true, derivative=','})",
		comment="",
		duration=8.6000000000003e-05,
		simplifyStack={}
	},
	{
		code="local x=a'^,i'\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false, derivative=','})",
		comment="",
		duration=7.8000000000002e-05,
		simplifyStack={}
	},
	{
		code="local x=a'_,i'\9print(x)\9assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true, derivative=','})",
		comment="",
		duration=7.0000000000001e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO multiple indexes with commas mixed", duration=1.000000000001e-06},
	{code="", comment="TODO multiple indexes with commas mixed with multiple chars", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertNe(a'^,i', a'_,i')",
		comment="",
		duration=0.001991,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}