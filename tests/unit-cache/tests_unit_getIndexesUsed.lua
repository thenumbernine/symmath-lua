{
	{code="", comment="not a TensorRef == no indexes used", duration=2.000000000002e-06},
	{
		code="assertIndexesUsed(c)",
		comment="",
		duration=0.001369,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{code="", comment="single TensorRef, fixed", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(c'_i', {fixed='_i'})",
		comment="",
		duration=0.001647,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(c'_ij', {fixed='_ij'})",
		comment="",
		duration=0.001973,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(c'^i_jk', {fixed='^i_jk'})",
		comment="",
		duration=0.001637,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="single TensorRef, summed", duration=9.9999999999406e-07},
	{
		code="assertIndexesUsed(c'^i_i', {summed='^i'})",
		comment="",
		duration=0.001528,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="single TensorRef, mixed", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(c'^i_ij', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.001435,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.1999999999994e-05},
	{code="", comment="mul, fixed * summed", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'_i' * b'^j_j', {fixed='_i', summed='^j'})",
		comment="",
		duration=0.002421,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="mul, fixed * fixed => summed", duration=0},
	{
		code="assertIndexesUsed(g'^im' * c'_mjk', {fixed='^i_jk', summed='^m'})",
		comment="",
		duration=0.001791,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, nothing", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a + b)",
		comment="",
		duration=0.000305,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, fixed", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'_i' + b'_i', {fixed='_i'})",
		comment="",
		duration=0.000974,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(a'_ij' + b'_ij', {fixed='_ij'})",
		comment="",
		duration=0.001064,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, summed", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'^i_i' + b'^i_i', {summed='^i'})",
		comment="",
		duration=0.000713,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(a'^i_i' + b'^j_j', {summed='^ij'})",
		comment="",
		duration=0.001133,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{code="", comment="add, extra", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed( a'_i' + b, {extra='_i'})",
		comment="",
		duration=0.000941,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed( a + b'_j', {extra='_j'})",
		comment="",
		duration=0.00057699999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed( a'_i' + b'_j', {extra='_ij'})",
		comment="",
		duration=0.00085600000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, fixed + summed", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed( a'^i_ij' + b'^i_ij', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.001267,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed( a'^i_ij' + b'^k_kj', {fixed='_j', summed='^ik'})",
		comment="",
		duration=0.001211,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, fixed + extra", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed( a'_ij' + b'_kj', {fixed='_j', extra='_ik'})",
		comment="",
		duration=0.001216,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, summed + extra", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed( a'^i_ij' + b'^i_ik', {summed='^i', extra='_jk'})",
		comment="",
		duration=0.001087,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, fixed + summed + extra", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed( a'_ij^jk' + b'_ij^jl', {fixed='_i', summed='_j', extra='^kl'})",
		comment="",
		duration=0.001946,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.9999999999881e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TODO fixed and summed of add", duration=1.000000000001e-06},
	{code="", comment="TODO fixed and summed of add and mul", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="notice that the summed index is counted by the number of the symbol's occurrence, regardless of the lower/upper", duration=1.000000000001e-06},
	{code="", comment="this means the lower/upper of the summed will be arbitrary", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed( a'^i' * b'_i' * c'_j', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.002054,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'^i' * b'_i' * c'_j' + d'^i' * e'_i' * f'_j', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.001415,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'^i' * b'_i', {summed='^i'})",
		comment="",
		duration=0.00073100000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'^i' * b'_i' + c, {summed='^i'})",
		comment="",
		duration=0.000663,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'^i' * b'_i' + c'^i' * d'_i', {summed='^i'})",
		comment="",
		duration=0.00075500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}