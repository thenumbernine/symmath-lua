{
	{
		code="simplifyAssertEq(x, x)",
		comment="",
		duration=0.000395,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertNe(x, y)",
		comment="",
		duration=0.000275,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assert(x:match(x))",
		comment="",
		duration=1.4999999999994e-05,
		simplifyStack={}
	},
	{
		code="assert(not x:match(y))",
		comment="",
		duration=1.0999999999997e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="constants", duration=0},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({const(2):match(const(2)*W(1))}, {const(1)})",
		comment="implicit mul by 1",
		duration=0.001543,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({const(2):match(const(1)*W(1))}, {const(2)})",
		comment="",
		duration=0.001088,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({const(2):match(const(2)/W(1))}, {const(1)})",
		comment="implicit divide by 1",
		duration=0.000617,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:175: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:175: in function 'simplifyAssertAllEq'\n\9[string \"simplifyAssertAllEq({const(2):match(const(2)/...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:230: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:229>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:229: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x560b096392f0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({const(4):match(const(2)*W(1))}, {const(2)})",
		comment="implicit integer factoring",
		duration=0.000616,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:175: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:175: in function 'simplifyAssertAllEq'\n\9[string \"simplifyAssertAllEq({const(4):match(const(2)*...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:230: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:229>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:229: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x560b096392f0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="functions", duration=0},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({sin(x):match(sin(W(1)))}, {x})",
		comment="",
		duration=0.000573,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="functions and mul mixed", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(W(1)))}, {2 * x})",
		comment="",
		duration=0.003404,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(2 * W(1)))}, {x})",
		comment="",
		duration=0.000436,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="matching c*f(x) => c*sin(a*x)", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({sin(2*x):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})}, {sin(2*x), one})",
		comment="",
		duration=0.005015,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(W{1, cannotDependOn=x} * x))}, {const(2)})",
		comment="",
		duration=0.000717,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add", duration=0},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({x:match(W{2, cannotDependOn=x} + W{1, dependsOn=x})}, {x, zero})",
		comment="",
		duration=0.000781,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x + y), (x + y))",
		comment="",
		duration=0.003487,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="assert((x + y):match(x + y))",
		comment="",
		duration=3.3000000000005e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="add match to first term", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1) + y)}, {x})",
		comment="",
		duration=0.000474,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="add match to second term", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(x + W(1))}, {y})",
		comment="",
		duration=0.000296,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="change order", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(y + W(1))}, {x})",
		comment="",
		duration=0.000354,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add match to zero, because nothing's left", duration=0},
	{
		code="simplifyAssertAllEq({(x + y):match(x + y + W(1))}, {zero})",
		comment="",
		duration=0.000295,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1))}, {x + y})",
		comment="",
		duration=0.001655,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="doubled-up matches should only work if they match", duration=1.000000000001e-06},
	{
		code="assert(not (x + y):match(W(1) + W(1)))",
		comment="",
		duration=0.000474,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="this too, this would work only if x + x and not x + y", duration=0},
	{
		code="simplifyAssertAllEq({(x + x):match(W(1) + W(1))}, {x})",
		comment="",
		duration=0.000376,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="this too", duration=0},
	{
		code="simplifyAssertAllEq({(x + x):match(W{1, atMost=1} + W{2, atMost=1})}, {x, x})",
		comment="",
		duration=0.00042299999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="this should match (x+y), 0", duration=9.9999999998712e-07},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1) + W(2))}, {x + y, zero})",
		comment="",
		duration=0.003585,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, atMost=1} + W{2, atMost=1})}, {x, y})",
		comment="",
		duration=0.00047100000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="for these to work, I have to add the multi-wildcard stuff to the non-wildcard elements, handled in add.wildcardMatches", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(W(1) + W(2))}, {x, zero})",
		comment="",
		duration=0.000351,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(x + W(1) + W(2))}, {zero, zero})",
		comment="",
		duration=0.000374,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({x:match(W(1) + x + W(2))}, {zero, zero})",
		comment="",
		duration=0.000525,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) + W(2))}, {x * y, zero})",
		comment="",
		duration=0.001828,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="make sure within add.wildcardMatches we greedy-match any wildcards with 'atLeast' before assigning the rest to zero", duration=0},
	{
		code="simplifyAssertAllEq({x:match(W(1) + W{2,atLeast=1} + W(3))}, {zero, x, zero})",
		comment="",
		duration=0.000691,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="now we match wildcards left-to-right, so the cannot-depend-on will match first", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, cannotDependOn=x} + W{2, dependsOn=x})}, {y, x})",
		comment="",
		duration=0.000405,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, cannotDependOn=x, atLeast=1} + W{2, dependsOn=x})}, {y, x})",
		comment="",
		duration=0.000587,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with mul", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(y * W(1))}, {x})",
		comment="",
		duration=0.000263,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(x * y * W(1))}, {one})",
		comment="",
		duration=0.000263,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({ (x * y):match(W(1))}, {x * y})",
		comment="",
		duration=0.001865,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="assert(not (x * y):match(W(1) * W(1)))",
		comment="",
		duration=0.00036900000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * x):match(W(1) * W(1))}, {x})",
		comment="",
		duration=0.000403,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="verify wildcards are greedy with multiple mul matching", duration=1.000000000001e-06},
	{code="", comment="the first will take all expressions, the second gets the empty set", duration=0},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W(2))}, {x * y, one})",
		comment="",
		duration=0.001247,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{code="", comment="verify 'atMost' works - since both need at least 1 entry, it will only match when each gets a separate term", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * x):match(W{1, atMost=1} * W{2, atMost=1})}, {x, x})",
		comment="",
		duration=0.00031,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="verify 'atMost' cooperates with non-atMost wildcards", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W{2, atLeast=1})}, {x, y})",
		comment="",
		duration=0.000292,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({(x * y):match(W{1, atMost=1} * W{2, atMost=1})}, {x, y})",
		comment="",
		duration=0.000427,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assert( not( Constant(0):match(x) ) )",
		comment="",
		duration=2.0000000000006e-05,
		simplifyStack={}
	},
	{
		code="assert( not( Constant(0):match(x * y) ) )",
		comment="",
		duration=1.9000000000005e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( zero:match(W(1) * x), zero )",
		comment="",
		duration=0.00010399999999999,
		simplifyStack={}
	},
	{
		code="assert( not zero:match(W{1, dependsOn=x} * x) )",
		comment="",
		duration=3.4000000000006e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.7000000000003e-05},
	{
		code="simplifyAssertEq( zero:match(W(1) * x * y), zero )",
		comment="",
		duration=0.0001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( one:match(1 + W(1)), zero )",
		comment="",
		duration=7.1999999999989e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{
		code="simplifyAssertEq( one:match(1 + W(1) * x), zero )",
		comment="",
		duration=7.8999999999996e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( one:match(1 + W(1) * x * y), zero )",
		comment="",
		duration=0.00014600000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="", duration=0},
	{code="", comment="how can you take x*y and match only the 'x'?", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{index=2, cannotDependOn=x} * W{1, dependsOn=x})}, {x, y})",
		comment="",
		duration=0.00041000000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})}, {x*y, 1})",
		comment="",
		duration=0.0013,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{index=2, cannotDependOn=x} * W(1))}, {x, y})",
		comment="",
		duration=0.000487,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W{index=2, cannotDependOn=x})}, {x*y, 1})",
		comment="",
		duration=0.001127,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W(2))}, {x*y, 1})",
		comment="",
		duration=0.000746,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="combinations of add and mul", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="for this to work, add.wildcardMatches must call the wildcard-capable objects' own wildcard handlers correctly (and use push/pop match states, instead of assigning to wildcard indexes directly?)", duration=1.000000000001e-06},
	{code="", comment="also, because add.wildcardMatches assigns the extra wildcards to zero, it will be assigning (W(2) * W(3)) to zero ... which means it must (a) handle mul.wildcardMatches and (b) pick who of mul's children gets the zero and who doesn't", duration=1.000000000001e-06},
	{code="", comment="it also means that a situation like add->mul->add might have problems ... x:match(W(1) + (W(2) + W(3)) * (W(4) + W(5)))", duration=1.000000000001e-06},
	{
		code="do local i,j,k = x:match(W(1) + W(2) * W(3)) assertEq(i, x) assert(j == zero or k == zero) end",
		comment="",
		duration=0.00024100000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="cross over add and mul ... not yet working", duration=0},
	{code="", comment="local i = (x):match(W(1) + x)\9-- works", duration=1.000000000001e-06},
	{
		code="do local i = (x * y):match(W(1) + x * y) assertEq(i, zero) end",
		comment="",
		duration=0.000226,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="either 1 or 2 must be zero, and either 3 or 4 must be zero", duration=1.000000000001e-06},
	{
		code="do local i,j,k,l = x:match(x + W(1) * W(2) + W(3) * W(4)) assert(i == zero or j == zero) assert(k == zero or l == zero) end",
		comment="",
		duration=0.000207,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, x) end",
		comment="",
		duration=0.000639,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, x) end",
		comment="",
		duration=0.00035800000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="Put the 'cannotDependOn' wildcard first (leftmost) in the mul for it to greedily match non-dep-on-x terms", duration=1.000000000001e-06},
	{code="", comment="otherwise 'dependsOn' will match everything, since the mul of a non-dep and a dep itself is dep on 'x', so it will include non-dep-on-terms", duration=0},
	{
		code="do local c, f = (2 * 1/x):factorDivision():match(W{index=1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, 1/x) end",
		comment="",
		duration=0.003641,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local c, f = (2 * 1/x):factorDivision():match(W{1, cannotDependOn=x} * W(2)) assertEq(c, const(2)) assertEq(f, 1/x) end",
		comment="",
		duration=0.003399,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({ (x + 2*y):match(W(1) + W(2) * y) }, {x,2})",
		comment="",
		duration=0.00084099999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({ (x + 2*y):match(W(1) * x + W(2) * y) }, {1,2})",
		comment="",
		duration=0.001288,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq( {x:match( W(1)*x + W(2))}, {1, 0})",
		comment="",
		duration=0.000538,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq( {x:match( W(1)*x + W(2)*y)}, {1, 0})",
		comment="",
		duration=0.000817,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="div", duration=0},
	{code="", comment="", duration=9.9999999998712e-07},
	{code="", comment="", duration=0},
	{
		code="do local i = (1/x):match(1 / W(1)) assertEq(i, x) end",
		comment="",
		duration=0.000121,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="do local i = (1/x):match(1 / (W(1) * x)) assertEq(i, one) end",
		comment="",
		duration=9.5999999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="do local i = (1/x):match(1 / (W{1, cannotDependOn=x} * x)) assertEq(i, one) end",
		comment="",
		duration=9.3999999999997e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assert((2 * 1/x):match(2 * 1/x))",
		comment="",
		duration=2.8999999999987e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="do local i = (2 * 1/x):match(2 * 1/W(1)) assertEq(i, x) end",
		comment="",
		duration=0.000111,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="do local i = (2 * 1/x):match(2 * 1/(W(1) * x)) assertEq(i, one) end",
		comment="",
		duration=7.8000000000009e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="do local i, j = (2 * 1/x):factorDivision():match(W{1, atMost=1} * W{index=2, atMost=1}) assertEq(i, const(2)) assertEq(j, 1/x) end",
		comment="",
		duration=0.002523,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a, b = (1/(x*(3*x+4))):match(1 / (x * (W{1, cannotDependOn=x} * x + W{2, cannotDependOn=x}))) assertEq(a, const(3)) assertEq(b, const(4)) end",
		comment="",
		duration=0.00045500000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a, b = (1/(x*(3*x+4))):factorDivision():match(1 / (W{1, cannotDependOn=x} * x * x + W{2, cannotDependOn=x} * x)) assertEq(a, const(3)) assertEq(b, const(4)) end",
		comment="",
		duration=0.016426,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "*:FactorDivision:apply", "*:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="pow", duration=1.000000000001e-06},
	{code="", comment="", duration=9.9999999998712e-07},
	{
		code="simplifyAssertAllEq({(x^2):match(x^W(1))}, {const(2)})",
		comment="",
		duration=0.00053599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2):match(W(1)^2)}, {x})",
		comment="",
		duration=0.000267,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2):match(W(1)^W(2))}, {x, 2})",
		comment="",
		duration=0.00040800000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="defaults:", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x):match(x^W(1))}, {const(1)})",
		comment="",
		duration=0.00034500000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x):match(W(1)^1)}, {x})",
		comment="",
		duration=0.00033,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x):match(W(1)^W(2))}, {x, const(1)})",
		comment="",
		duration=0.000485,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="etc", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local expr = sin(2*x) + cos(3*x) local a,b = expr:match( sin(W(1)) + cos(W(2)) ) print(a[1], a[2] ,b) end",
		comment="",
		duration=0.000546,
		simplifyStack={}
	},
	{
		code="do local expr = sin(2*x) * cos(3*x) local a,b = expr:match( sin(W(1)) * cos(W(2)) ) print(a[1], a[2] ,b) end",
		comment="",
		duration=0.000373,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999998712e-07},
	{
		code="do local expr = (3*x^2 + 1) printbr('expr', expr) local a, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x}) printbr('a', a) printbr('c', c) simplifyAssertAllEq({a, c}, {3, 1}) end",
		comment="",
		duration=0.001839,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local expr = (3*x^2 + 2*x + 1) printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.003264,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local expr = (3*x^2 + 1):factorDivision() printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 0, 1}) end",
		comment="",
		duration=0.007232,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:175: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:175: in function 'simplifyAssertAllEq'\n\9[string \"do local expr = (3*x^2 + 1):factorDivision() ...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:230: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:229>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:229: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x560b096392f0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (3*x*x + 2*x + 1):factorDivision() printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.008452,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (1/(3*x*x + 2*x + 1)):factorDivision() printbr('expr', expr) local a, b, c = expr:match(1 / (W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x})) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.009745,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (x/(3*x*x + 2*x + 1)):factorDivision() printbr('expr', expr) local a, b, c = expr:match(1 / (W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x})) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.012273,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:175: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:175: in function 'simplifyAssertAllEq'\n\9[string \"do local expr = (x/(3*x*x + 2*x + 1)):factorD...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:230: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:229>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:229: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x560b096392f0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999997324e-07},
	{code="", comment="TensorRef", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{
		code="local a = x'^i':match(Tensor.Ref(x, W(1))) simplifyAssertEq(a, Tensor.Index{symbol='i', lower=false})",
		comment="",
		duration=0.00031400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}