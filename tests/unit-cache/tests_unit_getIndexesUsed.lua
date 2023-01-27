{
	{code="", comment="not a TensorRef == no indexes used", duration=6.9999999999792e-06},
	{
		code="assertIndexesUsed(c)",
		comment="",
		duration=0.002461,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="single TensorRef, fixed", duration=5.000000000005e-06},
	{
		code="assertIndexesUsed(c'_i', {fixed='_i'})",
		comment="",
		duration=0.005197,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(c'_ij', {fixed='_ij'})",
		comment="",
		duration=0.003559,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(c'^i_jk', {fixed='^i_jk'})",
		comment="",
		duration=0.003845,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=7.000000000007e-06},
	{code="", comment="single TensorRef, summed", duration=7.000000000007e-06},
	{
		code="assertIndexesUsed(c'^i_i', {summed='^i'})",
		comment="",
		duration=0.003152,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="single TensorRef, mixed", duration=5.000000000005e-06},
	{
		code="assertIndexesUsed(c'^i_ij', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.00303,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="mul, fixed * summed", duration=5.000000000005e-06},
	{
		code="assertIndexesUsed(a'_i' * b'^j_j', {fixed='_i', summed='^j'})",
		comment="",
		duration=0.002612,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="mul, fixed * fixed => summed", duration=5.000000000005e-06},
	{
		code="assertIndexesUsed(g'^im' * c'_mjk', {fixed='^i_jk', summed='^m'})",
		comment="",
		duration=0.007294,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="add, nothing", duration=5.000000000005e-06},
	{
		code="assertIndexesUsed(a + b)",
		comment="",
		duration=0.000392,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="add, fixed", duration=5.000000000005e-06},
	{
		code="assertIndexesUsed(a'_i' + b'_i', {fixed='_i'})",
		comment="",
		duration=0.002032,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(a'_ij' + b'_ij', {fixed='_ij'})",
		comment="",
		duration=0.003255,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="add, summed", duration=7.000000000007e-06},
	{
		code="assertIndexesUsed(a'^i_i' + b'^i_i', {summed='^i'})",
		comment="",
		duration=0.002185,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed(a'^i_i' + b'^j_j', {summed='^ij'})",
		comment="",
		duration=0.003853,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="add, extra", duration=6.000000000006e-06},
	{
		code="assertIndexesUsed( a'_i' + b, {extra='_i'})",
		comment="",
		duration=0.002355,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed( a + b'_j', {extra='_j'})",
		comment="",
		duration=0.002026,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed( a'_i' + b'_j', {extra='_ij'})",
		comment="",
		duration=0.002184,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="add, fixed + summed", duration=7.000000000007e-06},
	{
		code="assertIndexesUsed( a'^i_ij' + b'^i_ij', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.003219,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="assertIndexesUsed( a'^i_ij' + b'^k_kj', {fixed='_j', summed='^ik'})",
		comment="",
		duration=0.003543,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=8.000000000008e-06},
	{code="", comment="add, fixed + extra", duration=8.000000000008e-06},
	{
		code="assertIndexesUsed( a'_ij' + b'_kj', {fixed='_j', extra='_ik'})",
		comment="",
		duration=0.003088,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=8.9999999999812e-06},
	{code="", comment="add, summed + extra", duration=7.000000000007e-06},
	{
		code="assertIndexesUsed( a'^i_ij' + b'^i_ik', {summed='^i', extra='_jk'})",
		comment="",
		duration=0.004456,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.9999999999792e-06},
	{code="", comment="add, fixed + summed + extra", duration=6.000000000006e-06},
	{
		code="assertIndexesUsed( a'_ij^jk' + b'_ij^jl', {fixed='_i', summed='_j', extra='^kl'})",
		comment="",
		duration=0.006256,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=8.000000000008e-06},
	{code="", comment="", duration=8.000000000008e-06},
	{code="", comment="TODO fixed and summed of add", duration=7.000000000007e-06},
	{code="", comment="TODO fixed and summed of add and mul", duration=8.000000000008e-06},
	{code="", comment="", duration=6.9999999999792e-06},
	{code="", comment="", duration=7.9999999999802e-06},
	{code="", comment="notice that the summed index is counted by the number of the symbol's occurrence, regardless of the lower/upper", duration=7.9999999999802e-06},
	{code="", comment="this means the lower/upper of the summed will be arbitrary", duration=9.000000000009e-06},
	{
		code="assertIndexesUsed( a'^i' * b'_i' * c'_j', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.004291,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=8.000000000008e-06},
	{
		code="assertIndexesUsed(a'^i' * b'_i' * c'_j' + d'^i' * e'_i' * f'_j', {fixed='_j', summed='^i'})",
		comment="",
		duration=0.004838,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=8.000000000008e-06},
	{
		code="assertIndexesUsed(a'^i' * b'_i', {summed='^i'})",
		comment="",
		duration=0.001866,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.000000000009e-06},
	{
		code="assertIndexesUsed(a'^i' * b'_i' + c, {summed='^i'})",
		comment="",
		duration=0.001381,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0.00015999999999999},
	{
		code="assertIndexesUsed(a'^i' * b'_i' + c'^i' * d'_i', {summed='^i'})",
		comment="",
		duration=0.00165,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}