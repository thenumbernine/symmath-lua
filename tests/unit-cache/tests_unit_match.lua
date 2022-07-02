{
	{
		code="simplifyAssertEq(x, x)",
		comment="",
		duration=0.000145,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertNe(x, y)",
		comment="",
		duration=0.000134,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assert(x:match(x))",
		comment="",
		duration=9.9999999999996e-06,
		simplifyStack={}
	},
	{
		code="assert(not x:match(y))",
		comment="",
		duration=7.0000000000001e-06,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999999753e-07},
	{code="", comment="constants", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({const(2):match(const(2)*W(1))}, {const(1)})",
		comment="implicit mul by 1",
		duration=0.000617,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({const(2):match(const(1)*W(1))}, {const(2)})",
		comment="",
		duration=0.000335,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({const(2):match(const(2)/W(1))}, {const(1)})",
		comment="implicit divide by 1",
		duration=0.000369,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: in function 'simplifyAssertAllEq'\n\9[string \"simplifyAssertAllEq({const(2):match(const(2)/...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x556ff5d383e0",
		simplifyStack={"Init"}
	},
	{
		code="simplifyAssertAllEq({const(4):match(const(2)*W(1))}, {const(2)})",
		comment="implicit integer factoring",
		duration=0.000238,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: in function 'simplifyAssertAllEq'\n\9[string \"simplifyAssertAllEq({const(4):match(const(2)*...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x556ff5d383e0",
		simplifyStack={"Init"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="functions", duration=0},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({sin(x):match(sin(W(1)))}, {x})",
		comment="",
		duration=0.000153,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="functions and mul mixed", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(W(1)))}, {2 * x})",
		comment="",
		duration=0.001562,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(2 * W(1)))}, {x})",
		comment="",
		duration=0.00013700000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="matching c*f(x) => c*sin(a*x)", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq({sin(2*x):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})}, {sin(2*x), one})",
		comment="",
		duration=0.00156,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({sin(2*x):match(sin(W{1, cannotDependOn=x} * x))}, {const(2)})",
		comment="",
		duration=0.000427,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add", duration=0},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(W{2, cannotDependOn=x} + W{1, dependsOn=x})}, {x, zero})",
		comment="",
		duration=0.000249,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Constant:Tidy:apply", "Tidy"}
	},
	{
		code="simplifyAssertEq((x + y), (x + y))",
		comment="",
		duration=0.000927,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{
		code="assert((x + y):match(x + y))",
		comment="",
		duration=2.5999999999998e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add match to first term", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1) + y)}, {x})",
		comment="",
		duration=0.000168,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add match to second term", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(x + W(1))}, {y})",
		comment="",
		duration=0.000142,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="change order", duration=0},
	{
		code="simplifyAssertAllEq({(x + y):match(y + W(1))}, {x})",
		comment="",
		duration=6.7999999999999e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="add match to zero, because nothing's left", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(x + y + W(1))}, {zero})",
		comment="",
		duration=0.000178,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1))}, {x + y})",
		comment="",
		duration=0.00104,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="doubled-up matches should only work if they match", duration=1.000000000001e-06},
	{
		code="assert(not (x + y):match(W(1) + W(1)))",
		comment="",
		duration=0.00017,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="this too, this would work only if x + x and not x + y", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + x):match(W(1) + W(1))}, {x})",
		comment="",
		duration=0.000183,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="this too", duration=0},
	{
		code="simplifyAssertAllEq({(x + x):match(W{1, atMost=1} + W{2, atMost=1})}, {x, x})",
		comment="",
		duration=0.000185,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="this should match (x+y), 0", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W(1) + W(2))}, {x + y, zero})",
		comment="",
		duration=0.001067,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "+:Factor:apply", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, atMost=1} + W{2, atMost=1})}, {x, y})",
		comment="",
		duration=0.000281,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="for these to work, I have to add the multi-wildcard stuff to the non-wildcard elements, handled in add.wildcardMatches", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(W(1) + W(2))}, {x, zero})",
		comment="",
		duration=0.00015,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(x + W(1) + W(2))}, {zero, zero})",
		comment="",
		duration=9.9000000000002e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(W(1) + x + W(2))}, {zero, zero})",
		comment="",
		duration=0.000257,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) + W(2))}, {x * y, zero})",
		comment="",
		duration=0.000464,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="make sure within add.wildcardMatches we greedy-match any wildcards with 'atLeast' before assigning the rest to zero", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({x:match(W(1) + W{2,atLeast=1} + W(3))}, {zero, x, zero})",
		comment="",
		duration=0.000255,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="now we match wildcards left-to-right, so the cannot-depend-on will match first", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, cannotDependOn=x} + W{2, dependsOn=x})}, {y, x})",
		comment="",
		duration=0.000272,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq({(x + y):match(W{1, cannotDependOn=x, atLeast=1} + W{2, dependsOn=x})}, {y, x})",
		comment="",
		duration=0.000121,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="same with mul", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(y * W(1))}, {x})",
		comment="",
		duration=9e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(x * y * W(1))}, {one})",
		comment="",
		duration=0.000138,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({ (x * y):match(W(1))}, {x * y})",
		comment="",
		duration=0.0004,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "*:Tidy:apply", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assert(not (x * y):match(W(1) * W(1)))",
		comment="",
		duration=0.000138,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * x):match(W(1) * W(1))}, {x})",
		comment="",
		duration=9.1000000000001e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="verify wildcards are greedy with multiple mul matching", duration=1.000000000001e-06},
	{code="", comment="the first will take all expressions, the second gets the empty set", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W(2))}, {x * y, one})",
		comment="",
		duration=0.000484,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="verify 'atMost' works - since both need at least 1 entry, it will only match when each gets a separate term", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * x):match(W{1, atMost=1} * W{2, atMost=1})}, {x, x})",
		comment="",
		duration=0.000116,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="verify 'atMost' cooperates with non-atMost wildcards", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W{2, atLeast=1})}, {x, y})",
		comment="",
		duration=0.00014,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{1, atMost=1} * W{2, atMost=1})}, {x, y})",
		comment="",
		duration=9.6000000000006e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assert( not( Constant(0):match(x) ) )",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{
		code="assert( not( Constant(0):match(x * y) ) )",
		comment="",
		duration=1.2999999999999e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( zero:match(W(1) * x), zero )",
		comment="",
		duration=1.6999999999996e-05,
		simplifyStack={}
	},
	{
		code="assert( not zero:match(W{1, dependsOn=x} * x) )",
		comment="",
		duration=2.3000000000002e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( zero:match(W(1) * x * y), zero )",
		comment="",
		duration=7.3999999999998e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertEq( one:match(1 + W(1)), zero )",
		comment="",
		duration=3.2999999999998e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( one:match(1 + W(1) * x), zero )",
		comment="",
		duration=3.6999999999995e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertEq( one:match(1 + W(1) * x * y), zero )",
		comment="",
		duration=0.000114,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="how can you take x*y and match only the 'x'?", duration=0},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({(x * y):match(W{index=2, cannotDependOn=x} * W{1, dependsOn=x})}, {x, y})",
		comment="",
		duration=0.000154,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=0},
	{
		code="simplifyAssertAllEq({(x * y):match(W{1, dependsOn=x} * W{index=2, cannotDependOn=x})}, {x*y, 1})",
		comment="",
		duration=0.000378,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W{index=2, cannotDependOn=x} * W(1))}, {x, y})",
		comment="",
		duration=0.000171,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W{index=2, cannotDependOn=x})}, {x*y, 1})",
		comment="",
		duration=0.000451,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x * y):match(W(1) * W(2))}, {x*y, 1})",
		comment="",
		duration=0.000409,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{code="", comment="combinations of add and mul", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="for this to work, add.wildcardMatches must call the wildcard-capable objects' own wildcard handlers correctly (and use push/pop match states, instead of assigning to wildcard indexes directly?)", duration=1.000000000001e-06},
	{code="", comment="also, because add.wildcardMatches assigns the extra wildcards to zero, it will be assigning (W(2) * W(3)) to zero ... which means it must (a) handle mul.wildcardMatches and (b) pick who of mul's children gets the zero and who doesn't", duration=1.000000000001e-06},
	{code="", comment="it also means that a situation like add->mul->add might have problems ... x:match(W(1) + (W(2) + W(3)) * (W(4) + W(5)))", duration=1.000000000001e-06},
	{
		code="do local i,j,k = x:match(W(1) + W(2) * W(3)) assertEq(i, x) assert(j == zero or k == zero) end",
		comment="",
		duration=0.000149,
		simplifyStack={}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="cross over add and mul ... not yet working", duration=1.000000000001e-06},
	{code="", comment="local i = (x):match(W(1) + x)\9-- works", duration=0},
	{
		code="do local i = (x * y):match(W(1) + x * y) assertEq(i, zero) end",
		comment="",
		duration=4.3000000000001e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="either 1 or 2 must be zero, and either 3 or 4 must be zero", duration=1.000000000001e-06},
	{
		code="do local i,j,k,l = x:match(x + W(1) * W(2) + W(3) * W(4)) assert(i == zero or j == zero) assert(k == zero or l == zero) end",
		comment="",
		duration=0.000148,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, x) end",
		comment="",
		duration=0.000126,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{
		code="do local c, f = (2 * x):match(W{1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, x) end",
		comment="",
		duration=8.8000000000005e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=0},
	{code="", comment="Put the 'cannotDependOn' wildcard first (leftmost) in the mul for it to greedily match non-dep-on-x terms", duration=1.000000000001e-06},
	{code="", comment="otherwise 'dependsOn' will match everything, since the mul of a non-dep and a dep itself is dep on 'x', so it will include non-dep-on-terms", duration=0},
	{
		code="do local c, f = (2 * 1/x):factorDivision():match(W{index=1, cannotDependOn=x} * W{2, dependsOn=x}) assertEq(c, const(2)) assertEq(f, 1/x) end",
		comment="",
		duration=0.001716,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local c, f = (2 * 1/x):factorDivision():match(W{1, cannotDependOn=x} * W(2)) assertEq(c, const(2)) assertEq(f, 1/x) end",
		comment="",
		duration=0.001533,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({ (x + 2*y):match(W(1) + W(2) * y) }, {x,2})",
		comment="",
		duration=0.000267,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({ (x + 2*y):match(W(1) * x + W(2) * y) }, {1,2})",
		comment="",
		duration=0.000499,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq( {x:match( W(1)*x + W(2))}, {1, 0})",
		comment="",
		duration=0.000462,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=9.9999999999406e-07},
	{
		code="simplifyAssertAllEq( {x:match( W(1)*x + W(2)*y)}, {1, 0})",
		comment="",
		duration=0.000675,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{code="", comment="div", duration=2.000000000002e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i = (1/x):match(1 / W(1)) assertEq(i, x) end",
		comment="",
		duration=0.000186,
		simplifyStack={}
	},
	{code="", comment="", duration=2.000000000002e-06},
	{
		code="do local i = (1/x):match(1 / (W(1) * x)) assertEq(i, one) end",
		comment="",
		duration=8.5999999999996e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i = (1/x):match(1 / (W{1, cannotDependOn=x} * x)) assertEq(i, one) end",
		comment="",
		duration=9.9999999999996e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="assert((2 * 1/x):match(2 * 1/x))",
		comment="",
		duration=3.0999999999996e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i = (2 * 1/x):match(2 * 1/W(1)) assertEq(i, x) end",
		comment="",
		duration=2.5999999999998e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i = (2 * 1/x):match(2 * 1/(W(1) * x)) assertEq(i, one) end",
		comment="",
		duration=5.9000000000003e-05,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local i, j = (2 * 1/x):factorDivision():match(W{1, atMost=1} * W{index=2, atMost=1}) assertEq(i, const(2)) assertEq(j, 1/x) end",
		comment="",
		duration=0.002261,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "/:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a, b = (1/(x*(3*x+4))):match(1 / (x * (W{1, cannotDependOn=x} * x + W{2, cannotDependOn=x}))) assertEq(a, const(3)) assertEq(b, const(4)) end",
		comment="",
		duration=0.000216,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local a, b = (1/(x*(3*x+4))):factorDivision():match(1 / (W{1, cannotDependOn=x} * x * x + W{2, cannotDependOn=x} * x)) assertEq(a, const(3)) assertEq(b, const(4)) end",
		comment="",
		duration=0.007088,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy", "*:FactorDivision:apply", "*:FactorDivision:apply"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="pow", duration=0},
	{code="", comment="", duration=9.9999999998712e-07},
	{
		code="simplifyAssertAllEq({(x^2):match(x^W(1))}, {const(2)})",
		comment="",
		duration=0.000181,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2):match(W(1)^2)}, {x})",
		comment="",
		duration=6.9000000000013e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x^2):match(W(1)^W(2))}, {x, 2})",
		comment="",
		duration=8.8000000000005e-05,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="defaults:", duration=1.000000000001e-06},
	{
		code="simplifyAssertAllEq({(x):match(x^W(1))}, {const(1)})",
		comment="",
		duration=0.00011899999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x):match(W(1)^1)}, {x})",
		comment="",
		duration=0.00014400000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="simplifyAssertAllEq({(x):match(W(1)^W(2))}, {x, const(1)})",
		comment="",
		duration=0.00012999999999999,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="etc", duration=1.000000000001e-06},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local expr = sin(2*x) + cos(3*x) local a,b = expr:match( sin(W(1)) + cos(W(2)) ) print(a[1], a[2] ,b) end",
		comment="",
		duration=0.0001,
		simplifyStack={}
	},
	{
		code="do local expr = sin(2*x) * cos(3*x) local a,b = expr:match( sin(W(1)) * cos(W(2)) ) print(a[1], a[2] ,b) end",
		comment="",
		duration=0.000193,
		simplifyStack={}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local expr = (3*x^2 + 1) printbr('expr', expr) local a, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x}) printbr('a', a) printbr('c', c) simplifyAssertAllEq({a, c}, {3, 1}) end",
		comment="",
		duration=0.00121,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local expr = (3*x^2 + 2*x + 1) printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.001433,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{
		code="do local expr = (3*x^2 + 1):factorDivision() printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 0, 1}) end",
		comment="",
		duration=0.003976,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: in function 'simplifyAssertAllEq'\n\9[string \"do local expr = (3*x^2 + 1):factorDivision() ...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x556ff5d383e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (3*x*x + 2*x + 1):factorDivision() printbr('expr', expr) local a, b, c = expr:match(W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x}) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.005241,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (1/(3*x*x + 2*x + 1)):factorDivision() printbr('expr', expr) local a, b, c = expr:match(1 / (W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x})) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.007144,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{
		code="do local expr = (x/(3*x*x + 2*x + 1)):factorDivision() printbr('expr', expr) local a, b, c = expr:match(1 / (W{1, cannotDependOn=x} * x^2 + W{2, cannotDependOn=x} * x + W{3, cannotDependOn=x})) printbr('a', a) printbr('b', b) printbr('c', c) simplifyAssertAllEq({a, b, c}, {3, 2, 1}) end",
		comment="",
		duration=0.00828,
		error="/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: failed\nstack traceback:\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:216: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:215>\n\9[C]: in function 'error'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:162: in function 'simplifyAssertAllEq'\n\9[string \"do local expr = (x/(3*x*x + 2*x + 1)):factorD...\"]:1: in main chunk\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:208: in function </home/chris/Projects/lua/symmath/tests/unit/unit.lua:207>\n\9[C]: in function 'xpcall'\n\9/home/chris/Projects/lua/symmath/tests/unit/unit.lua:207: in function 'exec'\n\9match.lua:233: in function 'cb'\n\9/home/chris/Projects/lua/ext/timer.lua:49: in function 'timer'\n\9match.lua:6: in main chunk\n\9[C]: at 0x556ff5d383e0",
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	},
	{code="", comment="", duration=1.000000000001e-06},
	{code="", comment="TensorRef", duration=1.000000000001e-06},
	{code="", comment="", duration=0},
	{
		code="local a = x'^i':match(Tensor.Ref(x, W(1))) simplifyAssertEq(a, Tensor.Index{symbol='i', lower=false})",
		comment="",
		duration=0.00021600000000001,
		simplifyStack={"Init", "Prune", "Expand", "Prune", "Factor", "Prune", "Tidy"}
	}
}