{
	{
		code="simplifyAssertEq(x, x)",
		comment="",
		duration=0.000595,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertNe(x, y)",
		comment="",
		duration=0.000254,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{
		code="assert(x:match(x))",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="assert(not x:match(y))",
		comment="",
		duration=9.0000000000021e-06,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="constants", duration=0},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq({const(2):match(const(2)*W(1))}, {const(1)})",
		comment="implicit mul by 1",
		duration=0.000885,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({const(2):match(const(1)*W(1))}, {const(2)})",
		comment="",
		duration=0.00074999999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({const(2):match(const(2)/W(1))}, {const(1)})",
		comment="implicit divide by 1",
		duration=0.000427,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: in function 'simplifyAssertAllEq'\n\9[string \"simplifyAssertAllEq({const(2):match(const(2)/...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x55a02a9ef3e0",
		simplifyStack={"Init"}
	},
	{
		code="simplifyAssertAllEq({const(4):match(const(2)*W(1))}, {const(2)})",
		comment="implicit integer factoring",
		duration=0.00027,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: in function 'simplifyAssertAllEq'\n\9[string \"simplifyAssertAllEq({const(4):match(const(2)*...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x55a02a9ef3e0",
		simplifyStack={"Init"}
	},
	{code="", comment="", duration=0},
	{code="", comment="functions", duration=0},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq({sin(x):match(sin(W(1)))}, {x})",
		comment="",
		duration=0.000292,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="functions and mul mixed", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(W(1)))}, {2 * x})",
		comment="",
		duration=0.002315,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(2 * W(1)))}, {x})",
		comment="",
		duration=0.000298,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="matching c*f(x) => c*sin(a*x)", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({sin(2*x):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})}, {sin(2*x), one})",
		comment="",
		duration=0.002012,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(W{1, cannotDependOn=x} * x))}, {const(2)})",
		comment="",
		duration=0.000264,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(W{2, cannotDependOn=x} + W{1, dependsOn=x})}, {x, zero})",
		comment="",
		duration=0.00037599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x + y), (x + y))",
		comment="",
		duration=0.000828,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="assert((x + y):match(x + y))",
		comment="",
		duration=2.4000000000003e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add match to first term", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1) + y)}, {x})",
		comment="",
		duration=0.000164,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add match to second term", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(x + W(1))}, {y})",
		comment="",
		duration=0.000229,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="change order", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(y + W(1))}, {x})",
		comment="",
		duration=0.000149,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add match to zero, because nothing's left", duration=0},
	{
		code="simplifyAssertAllEq({(x + y):match(x + y + W(1))}, {zero})",
		comment="",
		duration=0.000218,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1))}, {x + y})",
		comment="",
		duration=0.001625,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="doubled-up matches should only work if they match", duration=1.000000000001e-06},
	{
		code="assert(not (x + y):match(W(1) + W(1)))",
		comment="",
		duration=0.000245,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="this too, this would work only if x + x and not x + y", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + x):match(W(1) + W(1))}, {x})",
		comment="",
		duration=0.000244,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="this too", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + x):match(W{1, atMost=1} + W{2, atMost=1})}, {x, x})",
		comment="",
		duration=0.000171,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="this should match (x+y), 0", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1) + W(2))}, {x + y, zero})",
		comment="",
		duration=0.001263,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, atMost=1} + W{2, atMost=1})}, {x, y})",
		comment="",
		duration=0.00029,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="for these to work, I have to add the multi-wildcard stuff to the non-wildcard elements, handled in add.wildcardMatches", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(W(1) + W(2))}, {x, zero})",
		comment="",
		duration=0.000225,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(x + W(1) + W(2))}, {zero, zero})",
		comment="",
		duration=0.000358,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(W(1) + x + W(2))}, {zero, zero})",
		comment="",
		duration=0.000429,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) + W(2))}, {x * y, zero})",
		comment="",
		duration=0.001902,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="make sure within add.wildcardMatches we greedy-match any wildcards with 'atLeast' before assigning the rest to zero", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq({x:match(W(1) + W{2,atLeast=1} + W(3))}, {zero, x, zero})",
		comment="",
		duration=0.000355,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="now we match wildcards left-to-right, so the cannot-depend-on will match first", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, cannotDependOn=x} + W{2, dependsOn=x})}, {y, x})",
		comment="",
		duration=0.000326,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, cannotDependOn=x, atLeast=1} + W{2, dependsOn=x})}, {y, x})",
		comment="",
		duration=0.000293,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.9999999999951e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with mul", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(y * W(1))}, {x})",
		comment="",
		duration=0.000411,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(x * y * W(1))}, {one})",
		comment="",
		duration=0.000359,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq({ (x * y):match(W(1))}, {x * y})",
		comment="",
		duration=0.000946,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assert(not (x * y):match(W(1) * W(1)))",
		comment="",
		duration=0.00016099999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * x):match(W(1) * W(1))}, {x})",
		comment="",
		duration=0.000342,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{code="", comment="verify wildcards are greedy with multiple mul matching", duration=1.9999999999951e-06},
	{code="", comment="the first will take all expressions, the second gets the empty set", duration=1.9999999999951e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W(2))}, {x * y, one})",
		comment="",
		duration=0.001165,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.4999999999997e-05},
	{code="", comment="verify 'atMost' works - since both need at least 1 entry, it will only match when each gets a separate term", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * x):match(W{1, atMost=1} * W{2, atMost=1})}, {x, x})",
		comment="",
		duration=0.000316,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="verify 'atMost' cooperates with non-atMost wildcards", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W{2, atLeast=1})}, {x, y})",
		comment="",
		duration=0.000189,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{1, atMost=1} * W{2, atMost=1})}, {x, y})",
		comment="",
		duration=0.000173,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assert( not( Constant(0):match(x) ) )",
		comment="",
		duration=1.5000000000001e-05,
		simplifyStack={}
	},
	{
		code="assert( not( Constant(0):match(x * y) ) )",
		comment="",
		duration=9.5999999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( zero:match(W(1) * x), zero )",
		comment="",
		duration=0.000151,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="assert( not zero:match(W{1, dependsOn=x} * x) )",
		comment="",
		duration=0.00012,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( zero:match(W(1) * x * y), zero )",
		comment="",
		duration=0.000133,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( one:match(1 + W(1)), zero )",
		comment="",
		duration=0.000105,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( one:match(1 + W(1) * x), zero )",
		comment="",
		duration=0.000168,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( one:match(1 + W(1) * x * y), zero )",
		comment="",
		duration=0.000315,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="how can you take x*y and match only the 'x'?", duration=9.9999999999406e-07},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{index=2, cannotDependOn=x} * W{1, dependsOn=x})}, {x, y})",
		comment="",
		duration=0.00024900000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})}, {x*y, 1})",
		comment="",
		duration=0.000919,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{index=2, cannotDependOn=x} * W(1))}, {x, y})",
		comment="",
		duration=0.00026,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W{index=2, cannotDependOn=x})}, {x*y, 1})",
		comment="",
		duration=0.000898,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W(2))}, {x*y, 1})",
		comment="",
		duration=0.000727,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="combinations of add and mul", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="for this to work, add.wildcardMatches must call the wildcard-capable objects' own wildcard handlers correctly (and use push/pop match states, instead of assigning to wildcard indexes directly?)", duration=1.000000000001e-06},
	{code="", comment="also, because add.wildcardMatches assigns the extra wildcards to zero, it will be assigning (W(2) * W(3)) to zero ... which means it must (a) handle mul.wildcardMatches and (b) pick who of mul's children gets the zero and who doesn't", duration=1.000000000001e-06},
	{code="", comment="it also means that a situation like add->mul->add might have problems ... x:match(W(1) + (W(2) + W(3)) * (W(4) + W(5)))", duration=1.000000000001e-06},
	{
		code="do local i,j,k = x:match(W(1) + W(2) * W(3)) assertEq(i, x) assert(j == zero or k == zero) end",
		comment="",
		duration=9.1000000000001e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="cross over add and mul ... not yet working", duration=9.9999999999406e-07},
	{code="", comment="local i = (x):match(W(1) + x)\9-- works", duration=0},
	{
		code="do local i = (x * y):match(W(1) + x * y) assertEq(i, zero) end",
		comment="",
		duration=8.0000000000004e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="either 1 or 2 must be zero, and either 3 or 4 must be zero", duration=0},
	{
		code="do local i,j,k,l = x:match(x + W(1) * W(2) + W(3) * W(4)) assert(i == zero or j == zero) assert(k == zero or l == zero) end",
		comment="",
		duration=0.000471,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, x) end",
		comment="",
		duration=0.000293,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, x) end",
		comment="",
		duration=0.000265,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="Put the 'cannotDependOn' wildcard first (leftmost) in the mul for it to greedily match non-dep-on-x terms", duration=1.000000000001e-06},
	{code="", comment="otherwise 'dependsOn' will match everything, since the mul of a non-dep and a dep itself is dep on 'x', so it will include non-dep-on-terms", duration=0},
	{
		code="do local c, f = (2 * 1/x):factorDivision():match(W{index=1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, 1/x) end",
		comment="",
		duration=0.001875,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local c, f = (2 * 1/x):factorDivision():match(W{1, cannotDependOn=x} * W(2)) assertEq(c, const(2)) assertEq(f, 1/x) end",
		comment="",
		duration=0.001975,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({ (x + 2*y):match(W(1) + W(2) * y) }, {x,2})",
		comment="",
		duration=0.000301,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({ (x + 2*y):match(W(1) * x + W(2) * y) }, {1,2})",
		comment="",
		duration=0.000525,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.0999999999993e-05},
	{
		code="simplifyAssertAllEq( {x:match( W(1)*x + W(2))}, {1, 0})",
		comment="",
		duration=0.00032599999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq( {x:match( W(1)*x + W(2)*y)}, {1, 0})",
		comment="",
		duration=0.00061699999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="div", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i = (1/x):match(1 / W(1)) assertEq(i, x) end",
		comment="",
		duration=5.6e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i = (1/x):match(1 / (W(1) * x)) assertEq(i, one) end",
		comment="",
		duration=0.000166,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i = (1/x):match(1 / (W{1, cannotDependOn=x} * x)) assertEq(i, one) end",
		comment="",
		duration=0.000134,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assert((2 * 1/x):match(2 * 1/x))",
		comment="",
		duration=1.8000000000004e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i = (2 * 1/x):match(2 * 1/W(1)) assertEq(i, x) end",
		comment="",
		duration=1.5999999999988e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i = (2 * 1/x):match(2 * 1/(W(1) * x)) assertEq(i, one) end",
		comment="",
		duration=0.00014199999999999,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i, j = (2 * 1/x):factorDivision():match(W{1, atMost=1} * W{index=2, atMost=1}) assertEq(i, const(2)) assertEq(j, 1/x) end",
		comment="",
		duration=0.001405,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a, b = (1/(x*(3*x+4))):match(1 / (x * (W{1, cannotDependOn=x} * x + W{2, cannotDependOn=x}))) assertEq(a, const(3)) assertEq(b, const(4)) end",
		comment="",
		duration=0.000155,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a, b = (1/(x*(3*x+4))):factorDivision():match(1 / (W{1, cannotDependOn=x} * x * x + W{2, cannotDependOn=x} * x)) assertEq(a, const(3)) assertEq(b, const(4)) end",
		comment="",
		duration=0.008223,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "*:FactorDivision:apply", "*:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="pow", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x^2):match(x^W(1))}, {const(2)})",
		comment="",
		duration=0.00021499999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2):match(W(1)^2)}, {x})",
		comment="",
		duration=0.00011700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2):match(W(1)^W(2))}, {x, 2})",
		comment="",
		duration=0.00022,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="defaults:", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x):match(x^W(1))}, {const(1)})",
		comment="",
		duration=0.000124,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x):match(W(1)^1)}, {x})",
		comment="",
		duration=0.00011799999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x):match(W(1)^W(2))}, {x, const(1)})",
		comment="",
		duration=0.00016000000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="etc", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{
		code="do local expr = sin(2*x) + cos(3*x) local a,b = expr:match( sin(W(1)) + cos(W(2)) ) print(a[1], a[2] ,b) end",
		comment="",
		duration=0.00012999999999999,
		simplifyStack={}
	},
	{
		code="do local expr = sin(2*x) * cos(3*x) local a,b = expr:match( sin(W(1)) * cos(W(2)) ) print(a[1], a[2] ,b) end",
		comment="",
		duration=0.00024300000000001,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local expr = (3*x^2 + 1) printbr('expr', expr) local a, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x}) printbr('a', a) printbr('c', c) simplifyAssertAllEq({a, c}, {3, 1}) end",
		comment="",
		duration=0.000679,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local expr = (3*x^2 + 2*x + 1) printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.001277,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.9999999999881e-06},
	{
		code="do local expr = (3*x^2 + 1):factorDivision() printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 0, 1}) end",
		comment="",
		duration=0.0048,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: in function 'simplifyAssertAllEq'\n\9[string \"do local expr = (3*x^2 + 1):factorDivision() ...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x55a02a9ef3e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (3*x*x + 2*x + 1):factorDivision() printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.003884,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (1/(3*x*x + 2*x + 1)):factorDivision() printbr('expr', expr) local a, b, c = expr:match(1 / (W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x})) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.00898,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (x/(3*x*x + 2*x + 1)):factorDivision() printbr('expr', expr) local a, b, c = expr:match(1 / (W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x})) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.011014,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: in function 'simplifyAssertAllEq'\n\9[string \"do local expr = (x/(3*x*x + 2*x + 1)):factorD...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x55a02a9ef3e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TensorRef", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="local a = x'^i':match(Tensor.Ref(x, W(1))) simplifyAssertEq(a, Tensor.Index{symbol='i', lower=false})",
		comment="",
		duration=0.000556,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}