{
	{
		code="B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end)",
		comment="",
		duration=0.000764,
		simplifyStack={}
	},
	{
		code="printbr(Array(B:dim()))",
		comment="",
		duration=0.000179,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="printbr(B'^ix'())",
		comment="",
		duration=0.003289,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Array(B'^ix'():dim()))",
		comment="",
		duration=0.002399,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="rank-1 subtensor assignment", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="A is from the txyz chart, so it will have 4 elements accordingly", duration=1.000000000001e-06},
	{
		code="A = Tensor('^a', function(a) return var'a'('^'..coords[a].name) end)",
		comment="",
		duration=0.000366,
		simplifyStack={}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000183,
		simplifyStack={}
	},
	{
		code="assert(A[1] == var'a''^t')",
		comment="",
		duration=6.1000000000005e-05,
		simplifyStack={}
	},
	{
		code="assert(A[2] == var'a''^x')",
		comment="",
		duration=5.8000000000002e-05,
		simplifyStack={}
	},
	{
		code="assert(A[3] == var'a''^y')",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="assert(A[4] == var'a''^z')",
		comment="",
		duration=3.3999999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="B is from the xyz chart, so it will have 3 elements accordingly", duration=1.000000000001e-06},
	{
		code="B = Tensor('^i', function(i) return var'b'('^'..coords[i+1].name) end)",
		comment="",
		duration=0.000118,
		simplifyStack={}
	},
	{
		code="printbr('B = '..B)",
		comment="",
		duration=0.000238,
		simplifyStack={}
	},
	{
		code="assert(B[1] == var'b''^x')",
		comment="",
		duration=2.3999999999996e-05,
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
		duration=1.8999999999998e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A2 = A:clone()",
		comment="",
		duration=6.2e-05,
		simplifyStack={}
	},
	{
		code="A2['^i'] = B'^i'()",
		comment="",
		duration=0.002821,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A2 = '..A2)",
		comment="",
		duration=0.000238,
		simplifyStack={}
	},
	{
		code="assertEq(A2[1], A[1])",
		comment="",
		duration=9.9999999999961e-06,
		simplifyStack={}
	},
	{
		code="assertEq(A2[2], B[1])",
		comment="B uses the xyz chart so B.x is B[1]",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="assertEq(A2[3], B[2])",
		comment="",
		duration=9.0000000000021e-06,
		simplifyStack={}
	},
	{
		code="assertEq(A2[4], B[3])",
		comment="",
		duration=5.7000000000001e-05,
		simplifyStack={}
	},
	{
		code="assertEq(A2, Tensor('^a', A[1], B[1], B[2], B[3]))",
		comment="",
		duration=3.3000000000005e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="rank-2 subtensor assignment", duration=9.9999999999406e-07},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A = Tensor('^ab', function(a,b) return var'a'('^'..coords[a].name..' '..coords[b].name) end)",
		comment="",
		duration=0.000885,
		simplifyStack={}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.001193,
		simplifyStack={}
	},
	{
		code="for i=1,4 do for j=1,4 do assertEq(A[i][j], var'a'('^'..coords[i].name..coords[j].name)) end end",
		comment="",
		duration=0.000607,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end)",
		comment="",
		duration=0.000823,
		simplifyStack={}
	},
	{
		code="printbr('B = '..B)",
		comment="",
		duration=0.000748,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(B[i][j], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00017,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="A['^ij'] = B'^ij'()",
		comment="",
		duration=0.009473,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000504,
		simplifyStack={}
	},
	{
		code="for j=1,4 do assertEq(A[1][j], var'a'('^t'..coords[j].name)) end",
		comment="",
		duration=6.6999999999998e-05,
		simplifyStack={}
	},
	{
		code="for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end",
		comment="",
		duration=3.3000000000005e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00011799999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{
		code="C = Tensor('^i', function(i) return var'c'('^'..coords[i+1].name) end)",
		comment="",
		duration=0.00013199999999999,
		simplifyStack={}
	},
	{
		code="printbr('C = '..C)",
		comment="",
		duration=0.000176,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^ti'] = C'^i'()",
		comment="",
		duration=0.004183,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000569,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=6.3999999999995e-05,
		simplifyStack={}
	},
	{
		code="for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end",
		comment="",
		duration=4.2e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000151,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{
		code="A['^it'] = B'^ix'()",
		comment="",
		duration=0.005399,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00078300000000001,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], var'a''^tt')",
		comment="",
		duration=4.6999999999991e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=9.3999999999997e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=0.000113,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000178,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^tt'] = 2",
		comment="",
		duration=0.003524,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00017800000000001,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], Constant(2))",
		comment="",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=3.8999999999997e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=3.0000000000002e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=5.200000000001e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^ij'] = 1",
		comment="",
		duration=0.003607,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000342,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], Constant(2))",
		comment="",
		duration=1.1999999999998e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.00011000000000001,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=6.0000000000004e-05,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], Constant(1)) end end",
		comment="",
		duration=2.1000000000007e-05,
		simplifyStack={}
	}
}