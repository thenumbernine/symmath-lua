#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'test')

env.a = symmath.Variable('a')
env.b = symmath.Variable('b')
env.x = symmath.Variable('x')
env.y = symmath.Variable('y')
env.s = symmath.Variable('s')
env.t = symmath.Variable('t')

env.gUxx = var('\\gamma^{xx}')
env.gUxy = var('\\gamma^{xy}')
env.gUyy = var('\\gamma^{yy}')

-- constant simplificaiton
for _,line in ipairs(string.split(string.trim([=[
asserteq(1, (Constant(1)*Constant(1))())					-- multiply by 1
asserteq(1, (Constant(1)/Constant(1))())					-- divide by 1
asserteq(-1, (-Constant(1)/Constant(1))())					-- divide by -1
asserteq(1, (Constant(1)/(Constant(1)*Constant(1)))())		-- multiply and divide by 1

-- commutativity
asserteq(x+y, y+x)											-- add commutative
asserteq(x*y, y*x)											-- mul commutative

-- pruning operations
asserteq(x, (1*x)())										-- prune 1*
asserteq(x, (x*1)())										-- prune *1
asserteq(0, (0*x)())										-- prune *0
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

-- trigonometry
asserteq((symmath.sin(x)^2+symmath.cos(x)^2)(), 1)
asserteq((y*symmath.sin(x)^2+y*symmath.cos(x)^2)(), y)
asserteq((y+y*symmath.sin(x)^2+y*symmath.cos(x)^2)(), 2*y)
asserteq((1+y*symmath.sin(x)^2+y*symmath.cos(x)^2)(), 1+y)

asserteq(1+symmath.cos(x)^2+symmath.cos(x)^2, 1+2*symmath.cos(x)^2)
asserteq(-1+symmath.cos(x)^2+symmath.cos(x)^2, -1+2*symmath.cos(x)^2)

asserteq((y-x)/(x-y), -1)
asserteq((x+y)/(x+y)^2, 1/(x+y))
asserteq((-x+y)/(-x+y)^2, 1/(-x+y))

asserteq( gUxy * (gUxy^2 - gUxx*gUyy) / (gUxx * gUyy - gUxy^2), -gUxy)
asserteq( gUxy * (gUxy - gUxx*gUyy) / (gUxx * gUyy - gUxy), -gUxy)
asserteq( gUxy * (gUxy - gUxx) / (gUxx - gUxy), -gUxy)

print(sqrt(-1)())
asserteq(sqrt(-1), i)

-- make sure, when distributing sqrt()'s, that the negative signs on the inside are simplified in advance
asserteq( ((((-x*a - x*b)))^frac(1,2)), i * (sqrt(x) * sqrt(a+b)) )
asserteq( (-(((-x*a - x*b)))^frac(1,2)), -i * (sqrt(x) * sqrt(a+b)) )

asserteq( ((((-x*a - x*b)*-1))^frac(1,2)), (sqrt(x) * sqrt(a+b)) )
asserteq( (-(((-x*a - x*b)*-1))^frac(1,2)), -(sqrt(x) * sqrt(a+b)) )
-- If sqrt, -1, and mul factor run out of order then -sqrt(-x) and sqrt(-x) will end up equal.  And that is bad for things like solve() on quadratics.
asserteq( ((((-x*a - x*b)/-1)/y)^frac(1,2)), (sqrt(x) * sqrt(a+b)) / sqrt(y) )
asserteq( (-(((-x*a - x*b)/-1)/y)^frac(1,2)), -(sqrt(x) * sqrt(a+b)) / sqrt(y) )

]=]), '\n')) do
	env.exec(line)
end
