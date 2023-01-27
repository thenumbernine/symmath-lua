{
	{
		code="simplifyAssertEq(x, x)",
		comment="",
		duration=0.00153,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertNe(x, y)",
		comment="",
		duration=0.00050199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="assert(x:match(x))",
		comment="",
		duration=7.0000000000001e-05,
		simplifyStack={}
	},
	{
		code="assert(not x:match(y))",
		comment="",
		duration=4.6999999999991e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="constants", duration=4.000000000004e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({const(2):match(const(2)*W(1))}, {const(1)})",
		comment="implicit mul by 1",
		duration=0.00344,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({const(2):match(const(1)*W(1))}, {const(2)})",
		comment="",
		duration=0.001569,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({const(2):match(const(2)/W(1))}, {const(1)})",
		comment="implicit divide by 1",
		duration=0.001252,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:183: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:246: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:245>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:183: in function 'simplifyAssertAllEq'\n\9[string \"simplifyAssertAllEq({const(2):match(const(2)/...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:237: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:54: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x5602f61ee3e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({const(4):match(const(2)*W(1))}, {const(2)})",
		comment="implicit integer factoring",
		duration=0.000778,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:183: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:246: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:245>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:183: in function 'simplifyAssertAllEq'\n\9[string \"simplifyAssertAllEq({const(4):match(const(2)*...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:237: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:54: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x5602f61ee3e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="functions", duration=4.9999999999911e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({sin(x):match(sin(W(1)))}, {x})",
		comment="",
		duration=0.000875,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999911e-06},
	{code="", comment="functions and mul mixed", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(W(1)))}, {2 * x})",
		comment="",
		duration=0.004732,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(2 * W(1)))}, {x})",
		comment="",
		duration=0.000835,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="matching c*f(x) => c*sin(a*x)", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({sin(2*x):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})}, {sin(2*x), one})",
		comment="",
		duration=0.006958,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(W{1, cannotDependOn=x} * x))}, {const(2)})",
		comment="",
		duration=0.001151,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="add", duration=6.000000000006e-06},
	{code="", comment="", duration=6.000000000006e-06},
	{
		code="simplifyAssertAllEq({x:match(W{2, cannotDependOn=x} + W{1, dependsOn=x})}, {x, zero})",
		comment="",
		duration=0.0016,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x + y), (x + y))",
		comment="",
		duration=0.004227,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="assert((x + y):match(x + y))",
		comment="",
		duration=7.1000000000015e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{code="", comment="add match to first term", duration=6.1999999999979e-05},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1) + y)}, {x})",
		comment="",
		duration=0.001193,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="add match to second term", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(x + W(1))}, {y})",
		comment="",
		duration=0.001119,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="change order", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(y + W(1))}, {x})",
		comment="",
		duration=0.001041,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="add match to zero, because nothing's left", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(x + y + W(1))}, {zero})",
		comment="",
		duration=0.001012,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1))}, {x + y})",
		comment="",
		duration=0.006848,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{code="", comment="doubled-up matches should only work if they match", duration=4.000000000004e-06},
	{
		code="assert(not (x + y):match(W(1) + W(1)))",
		comment="",
		duration=0.00092499999999998,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="this too, this would work only if x + x and not x + y", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x + x):match(W(1) + W(1))}, {x})",
		comment="",
		duration=0.00065899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="this too", duration=3.9999999999762e-06},
	{
		code="simplifyAssertAllEq({(x + x):match(W{1, atMost=1} + W{2, atMost=1})}, {x, x})",
		comment="",
		duration=0.00050599999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="this should match (x+y), 0", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1) + W(2))}, {x + y, zero})",
		comment="",
		duration=0.002974,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, atMost=1} + W{2, atMost=1})}, {x, y})",
		comment="",
		duration=0.00097900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="for these to work, I have to add the multi-wildcard stuff to the non-wildcard elements, handled in add.wildcardMatches", duration=4.9999999999772e-06},
	{
		code="simplifyAssertAllEq({x:match(W(1) + W(2))}, {x, zero})",
		comment="",
		duration=0.00056899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({x:match(x + W(1) + W(2))}, {zero, zero})",
		comment="",
		duration=0.001141,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({x:match(W(1) + x + W(2))}, {zero, zero})",
		comment="",
		duration=0.001072,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) + W(2))}, {x * y, zero})",
		comment="",
		duration=0.002312,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="make sure within add.wildcardMatches we greedy-match any wildcards with 'atLeast' before assigning the rest to zero", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({x:match(W(1) + W{2,atLeast=1} + W(3))}, {zero, x, zero})",
		comment="",
		duration=0.00078600000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="now we match wildcards left-to-right, so the cannot-depend-on will match first", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, cannotDependOn=x} + W{2, dependsOn=x})}, {y, x})",
		comment="",
		duration=0.00097999999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999782e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, cannotDependOn=x, atLeast=1} + W{2, dependsOn=x})}, {y, x})",
		comment="",
		duration=0.001431,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="same with mul", duration=3.9999999999762e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(y * W(1))}, {x})",
		comment="",
		duration=0.000386,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(x * y * W(1))}, {one})",
		comment="",
		duration=0.001004,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({ (x * y):match(W(1))}, {x * y})",
		comment="",
		duration=0.002358,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="assert(not (x * y):match(W(1) * W(1)))",
		comment="",
		duration=0.00082300000000002,
		simplifyStack={}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x * x):match(W(1) * W(1))}, {x})",
		comment="",
		duration=0.000612,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="verify wildcards are greedy with multiple mul matching", duration=5.000000000005e-06},
	{code="", comment="the first will take all expressions, the second gets the empty set", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W(2))}, {x * y, one})",
		comment="",
		duration=0.001898,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="verify 'atMost' works - since both need at least 1 entry, it will only match when each gets a separate term", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x * x):match(W{1, atMost=1} * W{2, atMost=1})}, {x, x})",
		comment="",
		duration=0.001073,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="verify 'atMost' cooperates with non-atMost wildcards", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W{2, atLeast=1})}, {x, y})",
		comment="",
		duration=0.00054899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{1, atMost=1} * W{2, atMost=1})}, {x, y})",
		comment="",
		duration=0.00070400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="assert( not( Constant(0):match(x) ) )",
		comment="",
		duration=3.7999999999982e-05,
		simplifyStack={}
	},
	{
		code="assert( not( Constant(0):match(x * y) ) )",
		comment="",
		duration=7.3999999999991e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq( zero:match(W(1) * x), zero )",
		comment="",
		duration=0.00028800000000001,
		simplifyStack={}
	},
	{
		code="assert( not zero:match(W{1, dependsOn=x} * x) )",
		comment="",
		duration=6.8000000000012e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertEq( zero:match(W(1) * x * y), zero )",
		comment="",
		duration=0.00018400000000002,
		simplifyStack={}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertEq( one:match(1 + W(1)), zero )",
		comment="",
		duration=0.00018099999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{
		code="simplifyAssertEq( one:match(1 + W(1) * x), zero )",
		comment="",
		duration=0.00069000000000002,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertEq( one:match(1 + W(1) * x * y), zero )",
		comment="",
		duration=0.000221,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="how can you take x*y and match only the 'x'?", duration=5.000000000005e-06},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{index=2, cannotDependOn=x} * W{1, dependsOn=x})}, {x, y})",
		comment="",
		duration=0.001185,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.9999999999792e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})}, {x*y, 1})",
		comment="",
		duration=0.002505,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{index=2, cannotDependOn=x} * W(1))}, {x, y})",
		comment="",
		duration=0.001029,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W{index=2, cannotDependOn=x})}, {x*y, 1})",
		comment="",
		duration=0.001577,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W(2))}, {x*y, 1})",
		comment="",
		duration=0.002004,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="combinations of add and mul", duration=4.9999999999772e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="", duration=3.9999999999762e-06},
	{code="", comment="for this to work, add.wildcardMatches must call the wildcard-capable objects' own wildcard handlers correctly (and use push/pop match states, instead of assigning to wildcard indexes directly?)", duration=4.000000000004e-06},
	{code="", comment="also, because add.wildcardMatches assigns the extra wildcards to zero, it will be assigning (W(2) * W(3)) to zero ... which means it must (a) handle mul.wildcardMatches and (b) pick who of mul's children gets the zero and who doesn't", duration=5.000000000005e-06},
	{code="", comment="it also means that a situation like add->mul->add might have problems ... x:match(W(1) + (W(2) + W(3)) * (W(4) + W(5)))", duration=4.000000000004e-06},
	{
		code="do local i,j,k = x:match(W(1) + W(2) * W(3)) assertEq(i, x) assert(j == zero or k == zero) end",
		comment="",
		duration=0.000363,
		simplifyStack={}
	},
	{code="", comment="", duration=3.9999999999762e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{code="", comment="cross over add and mul ... not yet working", duration=4.000000000004e-06},
	{code="", comment="local i = (x):match(W(1) + x)\9-- works", duration=4.9999999999772e-06},
	{
		code="do local i = (x * y):match(W(1) + x * y) assertEq(i, zero) end",
		comment="",
		duration=0.00037499999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="either 1 or 2 must be zero, and either 3 or 4 must be zero", duration=5.000000000005e-06},
	{
		code="do local i,j,k,l = x:match(x + W(1) * W(2) + W(3) * W(4)) assert(i == zero or j == zero) assert(k == zero or l == zero) end",
		comment="",
		duration=0.00069999999999998,
		simplifyStack={}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="do local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, x) end",
		comment="",
		duration=0.00060299999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="do local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, x) end",
		comment="",
		duration=0.00065300000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{code="", comment="Put the 'cannotDependOn' wildcard first (leftmost) in the mul for it to greedily match non-dep-on-x terms", duration=5.000000000005e-06},
	{code="", comment="otherwise 'dependsOn' will match everything, since the mul of a non-dep and a dep itself is dep on 'x', so it will include non-dep-on-terms", duration=6.000000000006e-06},
	{
		code="do local c, f = (2 * 1/x):factorDivision():match(W{index=1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, 1/x) end",
		comment="",
		duration=0.00894,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="do local c, f = (2 * 1/x):factorDivision():match(W{1, cannotDependOn=x} * W(2)) assertEq(c, const(2)) assertEq(f, 1/x) end",
		comment="",
		duration=0.006271,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="simplifyAssertAllEq({ (x + 2*y):match(W(1) + W(2) * y) }, {x,2})",
		comment="",
		duration=0.001514,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({ (x + 2*y):match(W(1) * x + W(2) * y) }, {1,2})",
		comment="",
		duration=0.001406,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq( {x:match( W(1)*x + W(2))}, {1, 0})",
		comment="",
		duration=0.000773,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="simplifyAssertAllEq( {x:match( W(1)*x + W(2)*y)}, {1, 0})",
		comment="",
		duration=0.002641,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.9999999999782e-06},
	{code="", comment="div", duration=5.000000000005e-06},
	{code="", comment="", duration=7.000000000007e-06},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="do local i = (1/x):match(1 / W(1)) assertEq(i, x) end",
		comment="",
		duration=0.000305,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="do local i = (1/x):match(1 / (W(1) * x)) assertEq(i, one) end",
		comment="",
		duration=0.000636,
		simplifyStack={}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="do local i = (1/x):match(1 / (W{1, cannotDependOn=x} * x)) assertEq(i, one) end",
		comment="",
		duration=0.000391,
		simplifyStack={}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="assert((2 * 1/x):match(2 * 1/x))",
		comment="",
		duration=9.4000000000011e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="do local i = (2 * 1/x):match(2 * 1/W(1)) assertEq(i, x) end",
		comment="",
		duration=0.00012199999999998,
		simplifyStack={}
	},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="do local i = (2 * 1/x):match(2 * 1/(W(1) * x)) assertEq(i, one) end",
		comment="",
		duration=0.00034500000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="do local i, j = (2 * 1/x):factorDivision():match(W{1, atMost=1} * W{index=2, atMost=1}) assertEq(i, const(2)) assertEq(j, 1/x) end",
		comment="",
		duration=0.0049,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="do local a, b = (1/(x*(3*x+4))):match(1 / (x * (W{1, cannotDependOn=x} * x + W{2, cannotDependOn=x}))) assertEq(a, const(3)) assertEq(b, const(4)) end",
		comment="",
		duration=0.00056200000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=5.000000000005e-06},
	{
		code="do local a, b = (1/(x*(3*x+4))):factorDivision():match(1 / (W{1, cannotDependOn=x} * x * x + W{2, cannotDependOn=x} * x)) assertEq(a, const(3)) assertEq(b, const(4)) end",
		comment="",
		duration=0.030551,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "*:FactorDivision:apply", "*:FactorDivision:apply"}
	},
	{code="", comment="", duration=4.9999999999772e-06},
	{code="", comment="pow", duration=4.000000000004e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x^2):match(x^W(1))}, {const(2)})",
		comment="",
		duration=0.00046499999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2):match(W(1)^2)}, {x})",
		comment="",
		duration=0.00033299999999997,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2):match(W(1)^W(2))}, {x, 2})",
		comment="",
		duration=0.00080999999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="defaults:", duration=4.000000000004e-06},
	{
		code="simplifyAssertAllEq({(x):match(x^W(1))}, {const(1)})",
		comment="",
		duration=0.000587,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x):match(W(1)^1)}, {x})",
		comment="",
		duration=0.00026900000000002,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x):match(W(1)^W(2))}, {x, const(1)})",
		comment="",
		duration=0.00070599999999998,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{code="", comment="etc", duration=5.0000000000328e-06},
	{code="", comment="", duration=4.9999999999772e-06},
	{
		code="do local expr = sin(2*x) + cos(3*x) local a,b = expr:match( sin(W(1)) + cos(W(2)) ) print(a[1], a[2] ,b) end",
		comment="",
		duration=0.000807,
		simplifyStack={}
	},
	{
		code="do local expr = sin(2*x) * cos(3*x) local a,b = expr:match( sin(W(1)) * cos(W(2)) ) print(a[1], a[2] ,b) end",
		comment="",
		duration=0.000527,
		simplifyStack={}
	},
	{code="", comment="", duration=6.000000000006e-06},
	{
		code="do local expr = (3*x^2 + 1) printbr('expr', expr) local a, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x}) printbr('a', a) printbr('c', c) simplifyAssertAllEq({a, c}, {3, 1}) end",
		comment="",
		duration=0.002055,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=5.0000000000328e-06},
	{
		code="do local expr = (3*x^2 + 2*x + 1) printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.004079,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=8.9999999999812e-06},
	{
		code="do local expr = (3*x^2 + 1):factorDivision() printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 0, 1}) end",
		comment="",
		duration=0.009692,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:183: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:246: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:245>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:183: in function 'simplifyAssertAllEq'\n\9[string \"do local expr = (3*x^2 + 1):factorDivision() ...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:237: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:54: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x5602f61ee3e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (3*x*x + 2*x + 1):factorDivision() printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.015512,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (1/(3*x*x + 2*x + 1)):factorDivision() printbr('expr', expr) local a, b, c = expr:match(1 / (W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x})) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.021006,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (x/(3*x*x + 2*x + 1)):factorDivision() printbr('expr', expr) local a, b, c = expr:match(1 / (W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x})) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.024731,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:183: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:246: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:245>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:183: in function 'simplifyAssertAllEq'\n\9[string \"do local expr = (x/(3*x*x + 2*x + 1)):factorD...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:238: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:237>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:237: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:54: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x5602f61ee3e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=7.0000000000348e-06},
	{code="", comment="TensorRef", duration=4.000000000004e-06},
	{code="", comment="", duration=4.000000000004e-06},
	{
		code="local a = x'^i':match(Tensor.Ref(x, W(1))) simplifyAssertEq(a, Tensor.Index{symbol='i', lower=false})",
		comment="",
		duration=0.00099199999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}