{
	{
		code="simplifyAssertEq((a'^b' * b'^in_n' * c'^a_ab'):tidyIndexes(), a'^a' * b'^ib_b' * c'^c_ca')",
		comment="",
		duration=0.02159,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999911e-06},
	{
		code="simplifyAssertEq((a'^a' * b'^b_ba'):tidyIndexes(), a'^a' * b'^b_ba')",
		comment="",
		duration=0.009596,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^i_i' * b'^j_j'):tidyIndexes(), a'^a_a' * b'^b_b')",
		comment="",
		duration=0.007669,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq(a'^i_i^j_j':tidyIndexes(), a'^a_a^b_b')",
		comment="",
		duration=0.002693,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^i_i' + a'^j_j'):tidyIndexes(), 2 * a'^a_a')",
		comment="",
		duration=0.006602,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^ij' * (b'_jk' + c'_jk')):tidyIndexes(), a'^ia' * (b'_ak' + c'_ak'))",
		comment="",
		duration=0.028315,
		simplifyStack={"Init", "Prune", "*:Expand:apply", "Expand", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_ijk' * b'^jk' + a'_ilm' * b'^lm'):tidyIndexes(), 2 * a'_iab' * b'^ab')",
		comment="",
		duration=0.024358,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'_ajk' * b'^jk' + a'_alm' * b'^lm'):tidyIndexes(), 2 * a'_abc' * b'^bc')",
		comment="",
		duration=0.018399,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((c'^pq' * (d'_ipqj' + d'_jpqi') - c'^mr' * (d'_imrj' + d'_jmri')):tidyIndexes(), 0)",
		comment="",
		duration=0.033498,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertEq(((a'^k' + b'^k') * (c'_k' + d'_k')):tidyIndexes(), (a'^a' + b'^a') * (c'_a' + d'_a'))",
		comment="",
		duration=0.029385,
		simplifyStack={"Init", "Prune", "*:Expand:apply", "*:Expand:apply", "*:Expand:apply", "Expand", "+:Prune:flatten", "Prune", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^i' * (b'_i' + c'_i^j' * d'_j')):tidyIndexes(), a'^a' * (b'_a' + c'_a^b' * d'_b'))",
		comment="",
		duration=0.032015,
		simplifyStack={"Init", "Prune", "*:Expand:apply", "Expand", "*:Prune:flatten", "Prune", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "unm:Prune:doubleNegative", "+:Prune:combineConstants", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq(((a'^i' + b'^i_j' * c'^j') * (d'_i' + e'_i^k' * f'_k')):tidyIndexes(), a'^a' * d'_a' + c'^a' * b'^b_a' * d'_b' + a'^a' * f'_b' * e'_a^b' + c'^a' * f'_b' * b'^c_a' * e'_c^b')",
		comment="",
		duration=0.034183,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((-a'_i' * a'_j' + (d'_ji^k' + d'_ij^k' - d'^k_ij') * (a'_k' + c'_k' - d'^l_lk')):tidyIndexes(), -a'_i' * a'_j' + (d'_ji^a' + d'_ij^a' - d'^a_ij') * (a'_a' + c'_a' - d'^b_ba') )",
		comment="",
		duration=0.089441,
		simplifyStack={"Init", "unm:Prune:doubleNegative", "*:Prune:flatten", "unm:Prune:doubleNegative", "unm:Prune:doubleNegative", "Prune", "*:Expand:apply", "*:Expand:apply", "*:Expand:apply", "*:Expand:apply", "Expand", "*:Prune:flatten", "*:Prune:flatten", "*:Prune:flatten", "*:Prune:flatten", "*:Prune:flatten", "*:Prune:flatten", "+:Prune:flatten", "+:Prune:flatten", "Prune", "+:Factor:apply", "Factor", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Constant:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "*:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((a'^j_aj' * b'^a' - a'^k_jk' * b'^j'):tidyIndexes(), 0)",
		comment="",
		duration=0.005669,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq((2 * phi_K^4 * A' _\\\\alpha' * F' _\\\\gamma ^\\\\beta' * F' _\\\\beta ^\\\\gamma' * A' ^\\\\alpha' + phi_K^2 * F' _\\\\beta ^\\\\alpha' * F' _\\\\alpha ^\\\\beta' + 4 * R - 2 * phi_K^4 * F' _\\\\beta ^\\\\alpha' * A' _\\\\gamma' * F' _\\\\alpha ^\\\\beta' * A' ^\\\\gamma')():tidyIndexes()(), 4 * R + F'_a^b' * F'_b^a' * phi_K^2)",
		comment="should tidyIndexes automatically simplify()?  or at least add.Factor?  otherwise mul terms don't get sorted.",
		duration=0.069663,
		simplifyStack={"Init", "Prune", "^:Expand:integerPower", "Expand", "+:Prune:combineConstants", "*:Prune:combinePows", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq((a'^i' * b'^j_ji'):tidyIndexes(), a'^a' * b'^b_ba')",
		comment="this uses the first available indexes",
		duration=0.003162,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	}
}