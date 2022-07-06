{
	{
		code="B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end)",
		comment="",
		duration=0.001495,
		simplifyStack={}
	},
	{
		code="printbr(Array(B:dim()))",
		comment="",
		duration=0.000154,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="printbr(B'^ix'())",
		comment="",
		duration=0.004509,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Array(B'^ix'():dim()))",
		comment="",
		duration=0.004439,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="rank-1 subtensor assignment", duration=0},
	{code="", comment="", duration=0},
	{code="", comment="A is from the txyz chart, so it will have 4 elements accordingly", duration=0},
	{
		code="A = Tensor('^a', function(a) return var'a'('^'..coords[a].name) end)",
		comment="",
		duration=0.000457,
		simplifyStack={}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000628,
		simplifyStack={}
	},
	{
		code="assert(A[1] == var'a''^t')",
		comment="",
		duration=7.299999999999e-05,
		simplifyStack={}
	},
	{
		code="assert(A[2] == var'a''^x')",
		comment="",
		duration=8.9000000000006e-05,
		simplifyStack={}
	},
	{
		code="assert(A[3] == var'a''^y')",
		comment="",
		duration=2.0000000000006e-05,
		simplifyStack={}
	},
	{
		code="assert(A[4] == var'a''^z')",
		comment="",
		duration=2.3000000000009e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="B is from the xyz chart, so it will have 3 elements accordingly", duration=0},
	{
		code="B = Tensor('^i', function(i) return var'b'('^'..coords[i+1].name) end)",
		comment="",
		duration=0.000448,
		simplifyStack={}
	},
	{
		code="printbr('B = '..B)",
		comment="",
		duration=0.000277,
		simplifyStack={}
	},
	{
		code="assert(B[1] == var'b''^x')",
		comment="",
		duration=2.8e-05,
		simplifyStack={}
	},
	{
		code="assert(B[2] == var'b''^y')",
		comment="",
		duration=1.8000000000004e-05,
		simplifyStack={}
	},
	{
		code="assert(B[3] == var'b''^z')",
		comment="",
		duration=1.799999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A2 = A:clone()",
		comment="",
		duration=0.000156,
		simplifyStack={}
	},
	{
		code="A2['^i'] = B'^i'()",
		comment="",
		duration=0.005048,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A2 = '..A2)",
		comment="",
		duration=0.000517,
		simplifyStack={}
	},
	{
		code="assertEq(A2[1], A[1])",
		comment="",
		duration=0.000139,
		simplifyStack={}
	},
	{
		code="assertEq(A2[2], B[1])",
		comment="B uses the xyz chart so B.x is B[1]",
		duration=7.1000000000002e-05,
		simplifyStack={}
	},
	{
		code="assertEq(A2[3], B[2])",
		comment="",
		duration=0.000212,
		simplifyStack={}
	},
	{
		code="assertEq(A2[4], B[3])",
		comment="",
		duration=0.00029899999999999,
		simplifyStack={}
	},
	{
		code="assertEq(A2, Tensor('^a', A[1], B[1], B[2], B[3]))",
		comment="",
		duration=0.000721,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="rank-2 subtensor assignment", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A = Tensor('^ab', function(a,b) return var'a'('^'..coords[a].name..' '..coords[b].name) end)",
		comment="",
		duration=0.001123,
		simplifyStack={}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00072699999999999,
		simplifyStack={}
	},
	{
		code="for i=1,4 do for j=1,4 do assertEq(A[i][j], var'a'('^'..coords[i].name..coords[j].name)) end end",
		comment="",
		duration=0.001983,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end)",
		comment="",
		duration=0.00042400000000001,
		simplifyStack={}
	},
	{
		code="printbr('B = '..B)",
		comment="",
		duration=0.000219,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(B[i][j], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000753,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="A['^ij'] = B'^ij'()",
		comment="",
		duration=0.017981,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00072700000000001,
		simplifyStack={}
	},
	{
		code="for j=1,4 do assertEq(A[1][j], var'a'('^t'..coords[j].name)) end",
		comment="",
		duration=0.000323,
		simplifyStack={}
	},
	{
		code="for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end",
		comment="",
		duration=0.00039199999999999,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00075599999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="C = Tensor('^i', function(i) return var'c'('^'..coords[i+1].name) end)",
		comment="",
		duration=0.00021499999999999,
		simplifyStack={}
	},
	{
		code="printbr('C = '..C)",
		comment="",
		duration=0.000279,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^ti'] = C'^i'()",
		comment="",
		duration=0.006999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000665,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.000181,
		simplifyStack={}
	},
	{
		code="for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end",
		comment="",
		duration=0.00022,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00064400000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^it'] = B'^ix'()",
		comment="",
		duration=0.007822,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00035499999999999,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], var'a''^tt')",
		comment="",
		duration=8.5000000000002e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.000227,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=0.00017200000000001,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00052400000000002,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^tt'] = 2",
		comment="",
		duration=0.003926,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00043599999999999,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], Constant(2))",
		comment="",
		duration=6.5999999999983e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.000249,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=0.00025,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000637,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="A['^ij'] = 1",
		comment="",
		duration=0.00555,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.001016,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], Constant(2))",
		comment="",
		duration=0.00023000000000001,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.000719,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=0.00067800000000001,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], Constant(1)) end end",
		comment="",
		duration=0.00109,
		simplifyStack={}
	}
}