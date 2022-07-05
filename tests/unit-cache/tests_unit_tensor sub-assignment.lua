{
	{
		code="B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end)",
		comment="",
		duration=0.001021,
		simplifyStack={}
	},
	{
		code="printbr(Array(B:dim()))",
		comment="",
		duration=0.00016000000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="printbr(B'^ix'())",
		comment="",
		duration=0.005133,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr(Array(B'^ix'():dim()))",
		comment="",
		duration=0.003646,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="rank-1 subtensor assignment", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="A is from the txyz chart, so it will have 4 elements accordingly", duration=1.000000000001e-06},
	{
		code="A = Tensor('^a', function(a) return var'a'('^'..coords[a].name) end)",
		comment="",
		duration=0.000385,
		simplifyStack={}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000304,
		simplifyStack={}
	},
	{
		code="assert(A[1] == var'a''^t')",
		comment="",
		duration=0.000101,
		simplifyStack={}
	},
	{
		code="assert(A[2] == var'a''^x')",
		comment="",
		duration=0.00010300000000001,
		simplifyStack={}
	},
	{
		code="assert(A[3] == var'a''^y')",
		comment="",
		duration=2.1000000000007e-05,
		simplifyStack={}
	},
	{
		code="assert(A[4] == var'a''^z')",
		comment="",
		duration=2.0999999999993e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{code="", comment="B is from the xyz chart, so it will have 3 elements accordingly", duration=9.9999999998712e-07},
	{
		code="B = Tensor('^i', function(i) return var'b'('^'..coords[i+1].name) end)",
		comment="",
		duration=0.00028599999999999,
		simplifyStack={}
	},
	{
		code="printbr('B = '..B)",
		comment="",
		duration=0.00042299999999999,
		simplifyStack={}
	},
	{
		code="assert(B[1] == var'b''^x')",
		comment="",
		duration=3.5000000000007e-05,
		simplifyStack={}
	},
	{
		code="assert(B[2] == var'b''^y')",
		comment="",
		duration=1.9999999999992e-05,
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
		duration=0.0001,
		simplifyStack={}
	},
	{
		code="A2['^i'] = B'^i'()",
		comment="",
		duration=0.004172,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A2 = '..A2)",
		comment="",
		duration=0.00053299999999999,
		simplifyStack={}
	},
	{
		code="assertEq(A2[1], A[1])",
		comment="",
		duration=9.7e-05,
		simplifyStack={}
	},
	{
		code="assertEq(A2[2], B[1])",
		comment="B uses the xyz chart so B.x is B[1]",
		duration=0.00029499999999999,
		simplifyStack={}
	},
	{
		code="assertEq(A2[3], B[2])",
		comment="",
		duration=0.000115,
		simplifyStack={}
	},
	{
		code="assertEq(A2[4], B[3])",
		comment="",
		duration=0.00015800000000001,
		simplifyStack={}
	},
	{
		code="assertEq(A2, Tensor('^a', A[1], B[1], B[2], B[3]))",
		comment="",
		duration=0.00045300000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="rank-2 subtensor assignment", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{
		code="A = Tensor('^ab', function(a,b) return var'a'('^'..coords[a].name..' '..coords[b].name) end)",
		comment="",
		duration=0.001669,
		simplifyStack={}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000782,
		simplifyStack={}
	},
	{
		code="for i=1,4 do for j=1,4 do assertEq(A[i][j], var'a'('^'..coords[i].name..coords[j].name)) end end",
		comment="",
		duration=0.001832,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="B = Tensor('^ij', function(i,j) return var'b'('^'..coords[i+1].name..' '..coords[j+1].name) end)",
		comment="",
		duration=0.000623,
		simplifyStack={}
	},
	{
		code="printbr('B = '..B)",
		comment="",
		duration=0.000427,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(B[i][j], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00078,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^ij'] = B'^ij'()",
		comment="",
		duration=0.021239,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000889,
		simplifyStack={}
	},
	{
		code="for j=1,4 do assertEq(A[1][j], var'a'('^t'..coords[j].name)) end",
		comment="",
		duration=0.00049,
		simplifyStack={}
	},
	{
		code="for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end",
		comment="",
		duration=0.00032,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000939,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="C = Tensor('^i', function(i) return var'c'('^'..coords[i+1].name) end)",
		comment="",
		duration=0.000139,
		simplifyStack={}
	},
	{
		code="printbr('C = '..C)",
		comment="",
		duration=0.00019000000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^ti'] = C'^i'()",
		comment="",
		duration=0.006635,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000524,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.000429,
		simplifyStack={}
	},
	{
		code="for i=1,4 do assertEq(A[i][1], var'a'('^'..coords[i].name..'t')) end",
		comment="",
		duration=0.00031600000000001,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00093699999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^it'] = B'^ix'()",
		comment="",
		duration=0.00923,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00032599999999999,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], var'a''^tt')",
		comment="",
		duration=8.8000000000005e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.00023700000000001,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=0.00018099999999999,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.00071399999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^tt'] = 2",
		comment="",
		duration=0.00435,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.000504,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], Constant(2))",
		comment="",
		duration=9.5000000000012e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.000329,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=0.00030000000000002,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], var'b'('^'..spatialCoords[i].name..spatialCoords[j].name)) end end",
		comment="",
		duration=0.000777,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="A['^ij'] = 1",
		comment="",
		duration=0.005473,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="printbr('A = '..A)",
		comment="",
		duration=0.00047599999999998,
		simplifyStack={}
	},
	{
		code="assertEq(A[1][1], Constant(2))",
		comment="",
		duration=7.4999999999992e-05,
		simplifyStack={}
	},
	{
		code="for j=1,3 do assertEq(A[1][j+1], var'c'('^'..spatialCoords[j].name)) end",
		comment="",
		duration=0.00056699999999998,
		simplifyStack={}
	},
	{
		code="for i=1,3 do assertEq(A[i+1][1], var'b'('^'..spatialCoords[i].name..'x')) end",
		comment="",
		duration=0.00065300000000001,
		simplifyStack={}
	},
	{
		code="for i=1,3 do for j=1,3 do assertEq(A[i+1][j+1], Constant(1)) end end",
		comment="",
		duration=0.001242,
		simplifyStack={}
	}
}