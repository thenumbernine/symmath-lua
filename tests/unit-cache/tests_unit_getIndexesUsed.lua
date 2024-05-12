{
	{code="", comment="not a TensorRef == no indexes used", duration=9.9999999999406e-07},
	{
		code="assertIndexesUsed(c)",
		comment="",
		duration=0.000516,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="single TensorRef, fixed", duration=9.9999999999406e-07},
	{
		code="assertIndexesUsed(c'_i', {fixed='_i'})",
		comment="",
		duration=0.001127,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(c'_ij', {fixed='_ij'})",
		comment="",
		duration=0.000938,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(c'^i_jk', {fixed='^i_jk'})",
		comment="",
		duration=0.001014,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="single TensorRef, summed", duration=0},
	{
		code="assertIndexesUsed(c'^i_i', {summed='^i'})",
		comment="",
		duration=0.000594,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="single TensorRef, mixed", duration=0},
	{
		code="assertIndexesUsed(c'^i_ij', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.000627,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="mul, fixed * summed", duration=0},
	{
		code="assertIndexesUsed(a'_i' * b'^j_j', {fixed='_i', summed='^j'})",
		comment="",
		duration=0.000578,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="mul, fixed * fixed => summed", duration=9.9999999999406e-07},
	{
		code="assertIndexesUsed(g'^im' * c'_mjk', {fixed='^i_jk', summed='^m'})",
		comment="",
		duration=0.000889,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, nothing", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a + b)",
		comment="",
		duration=5.7999999999996e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, fixed", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'_i' + b'_i', {fixed='_i'})",
		comment="",
		duration=0.000427,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(a'_ij' + b'_ij', {fixed='_ij'})",
		comment="",
		duration=0.000441,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, summed", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'^i_i' + b'^i_i', {summed='^i'})",
		comment="",
		duration=0.000353,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(a'^i_i' + b'^j_j', {summed='^ij'})",
		comment="",
		duration=0.000369,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, extra", duration=0},
	{
		code="assertIndexesUsed( a'_i' + b, {extra='_i'})",
		comment="",
		duration=0.000214,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed( a + b'_j', {extra='_j'})",
		comment="",
		duration=0.00029899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed( a'_i' + b'_j', {extra='_ij'})",
		comment="",
		duration=0.000388,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, fixed + summed", duration=0},
	{
		code="assertIndexesUsed( a'^i_ij' + b'^i_ij', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.000476,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed( a'^i_ij' + b'^k_kj', {fixed='_j', summed='^ik'})",
		comment="",
		duration=0.00061,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="add, fixed + extra", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed( a'_ij' + b'_kj', {fixed='_j', extra='_ik'})",
		comment="",
		duration=0.000386,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add, summed + extra", duration=0},
	{
		code="assertIndexesUsed( a'^i_ij' + b'^i_ik', {summed='^i', extra='_jk'})",
		comment="",
		duration=0.000494,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="add, fixed + summed + extra", duration=0},
	{
		code="assertIndexesUsed( a'_ij^jk' + b'_ij^jl', {fixed='_i', summed='_j', extra='^kl'})",
		comment="",
		duration=0.000527,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="TODO fixed and summed of add", duration=0},
	{code="", comment="TODO fixed and summed of add and mul", duration=0},
	{code="", comment="", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="notice that the summed index is counted by the number of the symbol's occurrence, regardless of the lower/upper", duration=9.9999999999406e-07},
	{code="", comment="this means the lower/upper of the summed will be arbitrary", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed( a'^i' * b'_i' * c'_j', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.000689,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'^i' * b'_i' * c'_j' + d'^i' * e'_i' * f'_j', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.000568,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="assertIndexesUsed(a'^i' * b'_i', {summed='^i'})",
		comment="",
		duration=0.000251,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assertIndexesUsed(a'^i' * b'_i' + c, {summed='^i'})",
		comment="",
		duration=0.000348,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="assertIndexesUsed(a'^i' * b'_i' + c'^i' * d'_i', {summed='^i'})",
		comment="",
		duration=0.000308,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}