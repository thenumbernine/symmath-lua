{
	{
		code="B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end)",
		comment="",
		duration=0.001058,
		simplifyStack={}
	},
	{
		code="printbr(Array(B:dim()))",
		comment="",
		duration=0.000199,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="printbr(B'^ix'())",
		comment="",
		duration=0.005206,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Array(B'^ix'():dim()))",
		comment="",
		duration=0.003289,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="rank-1 subtensor assignment", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="A is from the txyz chart, so it will have 4 elements accordingly", duration=1.000000000001e-06},
	{
		code="A = Tensor('^a', function(a) return var'a'('^'..coords[a].name) end)",
		comment="",
		duration=0.00042200000000001,
		simplifyStack={}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000319,
		simplifyStack={}
	},
	{
		code="assert(A[1] == var'a''^t')",
		comment="",
		duration=3.2999999999991e-05,
		simplifyStack={}
	},
	{
		code="assert(A[2] == var'a''^x')",
		comment="",
		duration=2.1000000000007e-05,
		simplifyStack={}
	},
	{
		code="assert(A[3] == var'a''^y')",
		comment="",
		duration=9.9000000000002e-05,
		simplifyStack={}
	},
	{
		code="assert(A[4] == var'a''^z')",
		comment="",
		duration=8.9999999999993e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="B is from the xyz chart, so it will have 3 elements accordingly", duration=1.000000000001e-06},
	{
		code="B = Tensor('^i', function(i) return var'b'('^'..coords[i+1].name) end)",
		comment="",
		duration=0.00020299999999999,
		simplifyStack={}
	},
	{
		code="printbr('B = '..B)",
		comment="",
		duration=0.00032699999999999,
		simplifyStack={}
	},
	{
		code="assert(B[1] == var'b''^x')",
		comment="",
		duration=2.9000000000001e-05,
		simplifyStack={}
	},
	{
		code="assert(B[2] == var'b''^y')",
		comment="",
		duration=1.9000000000005e-05,
		simplifyStack={}
	},
	{
		code="assert(B[3] == var'b''^z')",
		comment="",
		duration=0.000129,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="", duration=0},
	{
		code="A2 = A:clone()",
		comment="",
		duration=0.000151,
		simplifyStack={}
	},
	{
		code="A2['^i'] = B'^i'()",
		comment="",
		duration=0.003935,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A2 = '..A2)",
		comment="",
		duration=0.000526,
		simplifyStack={}
	},
	{
		code="assertEq(A2[1], A[1])",
		comment="",
		duration=0.000137,
		simplifyStack={}
	},
	{
		code="assertEq(A2[2], B[1])",
		comment="B uses the xyz chart so B.x is B[1]",
		duration=7.4000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(A2[3], B[2])",
		comment="",
		duration=0.000124,
		simplifyStack={}
	},
	{
		code="assertEq(A2[4], B[3])",
		comment="",
		duration=0.000292,
		simplifyStack={}
	},
	{
		code="assertEq(A2, Tensor('^a', A[1], B[1], B[2], B[3]))",
		comment="",
		duration=0.000664,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="rank-2 subtensor assignment", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A = Tensor('^ab', function(a,b) return var'a'('^'..coords[a].name..' '..coords[b].name) end)",
		comment="",
		duration=0.001285,
		simplifyStack={}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000872,
		simplifyStack={}
	},
	{
		code="for i=1,4 do for j=1,4 do assertEq(A[i][j], var'a'('^'..coords[i].name..coords[j].name)) end end",
		comment="",
		duration=0.001559,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end)",
		comment="",
		duration=0.000861,
		simplifyStack={}
	},
	{
		code="printbr('B = '..B)",
		comment="",
		duration=0.00021,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(B[i][j], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000637,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="A['^ij'] = B'^ij'()",
		comment="",
		duration=0.020508,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000763,
		simplifyStack={}
	},
	{
		code="for j=1,4 do assertEq(A[1][j], var'a'('^t'..coords[j].name)) end",
		comment="",
		duration=0.00031200000000001,
		simplifyStack={}
	},
	{
		code="for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end",
		comment="",
		duration=0.000378,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00082500000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="C = Tensor('^i', function(i) return var'c'('^'..coords[i+1].name) end)",
		comment="",
		duration=0.000139,
		simplifyStack={}
	},
	{
		code="printbr('C = '..C)",
		comment="",
		duration=0.00014499999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="A['^ti'] = C'^i'()",
		comment="",
		duration=0.006859,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00043699999999999,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.000236,
		simplifyStack={}
	},
	{
		code="for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end",
		comment="",
		duration=0.000232,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000572,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^it'] = B'^ix'()",
		comment="",
		duration=0.008828,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00038300000000001,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], var'a''^tt')",
		comment="",
		duration=0.000102,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.00021299999999999,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=0.000301,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000654,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^tt'] = 2",
		comment="",
		duration=0.004003,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00035600000000002,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], Constant(2))",
		comment="",
		duration=6.0000000000004e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.000223,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=0.000248,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00064700000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="A['^ij'] = 1",
		comment="",
		duration=0.007675,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00046599999999999,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], Constant(2))",
		comment="",
		duration=5.7000000000001e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.00018499999999999,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=0.00026699999999999,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], Constant(1)) end end",
		comment="",
		duration=0.00025499999999998,
		simplifyStack={}
	}
}