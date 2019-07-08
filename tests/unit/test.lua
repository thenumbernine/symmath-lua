#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{debugSimplifyLoops=true, MathJax={title='test', pathToTryToFindMathJax='..'}}

function asserteq(a,b)
	local sa = symmath.simplify(a)
	local ta = symmath.simplify.stack
	local sb = symmath.simplify(b)
	local tb = symmath.simplify.stack
	if sa ~= sb then
		printbr('expected '..tostring(a)..' to equal '..tostring(b))
		printbr('instead found '..tostring(sa)..' vs '..tostring(sb))
		printbr('lhs stack')
		for _,x in ipairs(ta) do printbr(x) end
		printbr('rhs stack')
		for _,x in ipairs(tb) do printbr(x) end
	end
end

local function exec(str)
	printbr('<code>'..str..'</code>')
	printbr(assert(load(str))())
end

-- constant simplificaiton
for _,line in ipairs(([=[
asserteq(1, (Constant(1)*Constant(1))())
asserteq(1, (Constant(1)/Constant(1))())
asserteq(-1, (-Constant(1)/Constant(1))())	-- without the first 'simplify' we don't get the same canonical form with the unary - on the outside
asserteq(1, (Constant(1)/(Constant(1)*Constant(1)))())

x = symmath.Variable('x')
y = symmath.Variable('y')
t = symmath.Variable('t')

-- commutativity
asserteq(x+y, y+x)
asserteq(x*y, y*x)

-- pruning operations
asserteq(x, (1*x)())
asserteq(0, (Constant(0)*x)())
asserteq(x, (1*x)())
asserteq((x/x)(), 1)

asserteq(x^2, (x*x)())

-- simplify(): div add mul
asserteq(((x+1)*y)(), (x*y + y)())
asserteq(((x+1)*(y+1))(), (x*y + x + y + 1)())
asserteq((2/(2*x*y))(), (1/(x*y))())
asserteq((1-(1-x))(), x)
asserteq(((1-(1-x))/x)(), 1)
asserteq((1 + 1/x + 1/x)(), (1 + 2/x)())
asserteq((1 + 1/x + 2/x)(), (1 + 3/x)())

-- factoring integers
asserteq((Constant(2)/Constant(2))(), Constant(1))
asserteq((Constant(2)/Constant(4))(), (Constant(1)/Constant(2))())

asserteq(((2*x + 2*y)/2)(), (x+y)())
asserteq(((-2*x + 2*y)/2)(), (-x+y)())

asserteq(-1-x, -(1+x))

asserteq((-x)/x, -1)
asserteq((x/(-x)), -1)
asserteq((-x-1)/(x+1), -1) 
asserteq((x-1)/(1-x), -1)

-- expand(): add div mul

-- factor(): mul add div

-- [[ trigonometry
asserteq((symmath.sin(x)^2+symmath.cos(x)^2)(), 1)
asserteq((y*symmath.sin(x)^2+y*symmath.cos(x)^2)(), y)
asserteq((y+y*symmath.sin(x)^2+y*symmath.cos(x)^2)(), 2*y)	-- works when combining y + y * trig ident
asserteq((1+y*symmath.sin(x)^2+y*symmath.cos(x)^2)(), 1+y)	-- ... but not when combining 1 + y * trig ident (look in factor.lua)
--]]

asserteq(1+symmath.cos(x)^2+symmath.cos(x)^2, 1+2*symmath.cos(x)^2)
asserteq(-1+symmath.cos(x)^2+symmath.cos(x)^2, -1+2*symmath.cos(x)^2)

asserteq((y-x)/(x-y), -1)
asserteq((x+y)/(x+y)^2, 1/(x+y))
asserteq((-x+y)/(-x+y)^2, 1/(-x+y))

gUxx = var('\\gamma^{xx}')
gUxy = var('\\gamma^{xy}')
gUyy = var('\\gamma^{yy}')
--asserteq( gUxy * (gUxy^2 - gUxx*gUyy) / (gUxx * gUyy - gUxy^2), -gUxy)
--asserteq( gUxy * (gUxy - gUxx*gUyy) / (gUxx * gUyy - gUxy), -gUxy)
asserteq( gUxy * (gUxy - gUxx) / (gUxx - gUxy), -gUxy)

-- and an example of what a failure looks like:
asserteq(1,2)
]=]):trim():split'\n') do
	exec(line)
end
