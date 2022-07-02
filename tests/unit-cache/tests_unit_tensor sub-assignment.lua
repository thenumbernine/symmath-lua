{
	{
		code="B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end)",
		comment="",
		duration=0.000694,
		simplifyStack={}
	},
	{
		code="printbr(Array(B:dim()))",
		comment="",
		duration=0.000115,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="printbr(B'^ix'())",
		comment="",
		duration=0.00287,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Array(B'^ix'():dim()))",
		comment="",
		duration=0.002431,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="rank-1 subtensor assignment", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="A is from the txyz chart, so it will have 4 elements accordingly", duration=1.000000000001e-06},
	{
		code="A = Tensor('^a', function(a) return var'a'('^'..coords[a].name) end)",
		comment="",
		duration=0.000407,
		simplifyStack={}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00041,
		simplifyStack={}
	},
	{
		code="assert(A[1] == var'a''^t')",
		comment="",
		duration=5.8000000000002e-05,
		simplifyStack={}
	},
	{
		code="assert(A[2] == var'a''^x')",
		comment="",
		duration=3.6999999999995e-05,
		simplifyStack={}
	},
	{
		code="assert(A[3] == var'a''^y')",
		comment="",
		duration=0.000114,
		simplifyStack={}
	},
	{
		code="assert(A[4] == var'a''^z')",
		comment="",
		duration=2.2000000000001e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="B is from the xyz chart, so it will have 3 elements accordingly", duration=1.9999999999951e-06},
	{
		code="B = Tensor('^i', function(i) return var'b'('^'..coords[i+1].name) end)",
		comment="",
		duration=0.000361,
		simplifyStack={}
	},
	{
		code="printbr('B = '..B)",
		comment="",
		duration=0.000679,
		simplifyStack={}
	},
	{
		code="assert(B[1] == var'b''^x')",
		comment="",
		duration=3.7000000000002e-05,
		simplifyStack={}
	},
	{
		code="assert(B[2] == var'b''^y')",
		comment="",
		duration=3.1999999999997e-05,
		simplifyStack={}
	},
	{
		code="assert(B[3] == var'b''^z')",
		comment="",
		duration=6.6000000000004e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A2 = A:clone()",
		comment="",
		duration=0.000147,
		simplifyStack={}
	},
	{
		code="A2['^i'] = B'^i'()",
		comment="",
		duration=0.003118,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A2 = '..A2)",
		comment="",
		duration=0.000476,
		simplifyStack={}
	},
	{
		code="assertEq(A2[1], A[1])",
		comment="",
		duration=2.1e-05,
		simplifyStack={}
	},
	{
		code="assertEq(A2[2], B[1])",
		comment="B uses the xyz chart so B.x is B[1]",
		duration=3.9000000000004e-05,
		simplifyStack={}
	},
	{
		code="assertEq(A2[3], B[2])",
		comment="",
		duration=4.0000000000005e-05,
		simplifyStack={}
	},
	{
		code="assertEq(A2[4], B[3])",
		comment="",
		duration=0.000104,
		simplifyStack={}
	},
	{
		code="assertEq(A2, Tensor('^a', A[1], B[1], B[2], B[3]))",
		comment="",
		duration=6.9e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="rank-2 subtensor assignment", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A = Tensor('^ab', function(a,b) return var'a'('^'..coords[a].name..' '..coords[b].name) end)",
		comment="",
		duration=0.002078,
		simplifyStack={}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000848,
		simplifyStack={}
	},
	{
		code="for i=1,4 do for j=1,4 do assertEq(A[i][j], var'a'('^'..coords[i].name..coords[j].name)) end end",
		comment="",
		duration=0.000273,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end)",
		comment="",
		duration=0.000553,
		simplifyStack={}
	},
	{
		code="printbr('B = '..B)",
		comment="",
		duration=0.000247,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(B[i][j], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000185,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^ij'] = B'^ij'()",
		comment="",
		duration=0.008483,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000415,
		simplifyStack={}
	},
	{
		code="for j=1,4 do assertEq(A[1][j], var'a'('^t'..coords[j].name)) end",
		comment="",
		duration=0.00011599999999999,
		simplifyStack={}
	},
	{
		code="for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end",
		comment="",
		duration=3.1000000000003e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00024300000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="C = Tensor('^i', function(i) return var'c'('^'..coords[i+1].name) end)",
		comment="",
		duration=7.9999999999997e-05,
		simplifyStack={}
	},
	{
		code="printbr('C = '..C)",
		comment="",
		duration=9.300000000001e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="A['^ti'] = C'^i'()",
		comment="",
		duration=0.004228,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00083999999999999,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=4.8000000000006e-05,
		simplifyStack={}
	},
	{
		code="for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end",
		comment="",
		duration=4.3000000000001e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000183,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^it'] = B'^ix'()",
		comment="",
		duration=0.006872,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000458,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], var'a''^tt')",
		comment="",
		duration=4.6000000000004e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=8.6000000000003e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=7.9999999999997e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=8.3e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^tt'] = 2",
		comment="",
		duration=0.002362,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00019899999999999,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], Constant(2))",
		comment="",
		duration=1.000000000001e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=8.1999999999999e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=2.6999999999999e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=8.1999999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^ij'] = 1",
		comment="",
		duration=0.00209,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000125,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], Constant(2))",
		comment="",
		duration=8.9999999999951e-06,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.000138,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=2.8e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], Constant(1)) end end",
		comment="",
		duration=0.000152,
		simplifyStack={}
	}
}