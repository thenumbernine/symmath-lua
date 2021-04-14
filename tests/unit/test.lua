#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'test')

timer(nil, function()

env.a = symmath.Variable('a')
env.b = symmath.Variable('b')
env.g = symmath.Variable('g')
env.s = symmath.Variable('s')
env.t = symmath.Variable('t')
env.v = symmath.Variable('v')
env.x = symmath.Variable('x')
env.y = symmath.Variable('y')

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

-- it would be nice if the final form of sin(x)^2 was exactly that.
assert( printbr((sin(x)^2)()) == sin(x)^2 )

assert( not( Constant(0) == x * y ) )
assert( Constant(0) ~= x * y )
asserteq( Constant(0):subst( (v'^k' * v'^l' * g'_kl'):eq(var'vsq') ), Constant(0) )
asserteq( Constant(0):replace( v'^k' * v'^l' * g'_kl', var'vsq' ), Constant(0) )
asserteq( Constant(0):replace( v'^k' * v'^l', var'vsq' ), Constant(0) )
asserteq( Constant(0):replace( v'^k', var'vsq' ), Constant(0) )

-- simplifying expressions with sqrts in them
asserteq( 2^frac(-1,2) + 2^frac(1,2), frac(3, sqrt(2)) )
asserteq( 2*2^frac(-1,2) + 2^frac(1,2), 2 * sqrt(2) )
asserteq( 4*2^frac(-1,2) + 2^frac(1,2), 3 * sqrt(2) )

asserteq( (1 + sqrt(3))^2 + (1 - sqrt(3))^2, 8 )

asserteq( (frac(1,2)*sqrt(3))*(frac(sqrt(2),sqrt(3))) + (-frac(1,2))*(frac(1,3)*-sqrt(2)) , 2 * sqrt(2) / 3)

asserteq( -frac(1,3)*-frac(1+sqrt(3),3) + -frac(2,3)*frac(1,3) + -frac(2,3) * frac(1-sqrt(3),3), -frac(1 - sqrt(3), 3))

asserteq( -sqrt(3)*sqrt(2)/(2*sqrt(3)) + sqrt(2)/6, -sqrt(2)/3 )

asserteq( 1 + 5*sqrt(5) + sqrt(5), 1 + 6*sqrt(5) )
asserteq( 1 + 25*sqrt(5) + sqrt(5), 1 + 26*sqrt(5) )	-- powers of the sqrt sometimes get caught simplifying as merging the exponents, and don't add.
asserteq( 1 + 5*sqrt(5) - 5*sqrt(5), 1 )

asserteq( -(1 + sqrt(5))/(2*sqrt(3)) , frac(1,2)*(-frac(1,sqrt(3)))*(1 + sqrt(5)) ) 

asserteq( (-(1-sqrt(3))/3)*(frac(1,3)) + ((2+sqrt(3))/6)*(-(1-sqrt(3))/3) + (-(1+2*sqrt(3))/6)*(-(1+sqrt(3))/3) , (1 + sqrt(3))/3 )

asserteq( (-sqrt(sqrt(5) + 1) * (1 - sqrt(5))) / (4 * sqrt(sqrt(5) - 1)) , frac(1,2))

assertne( 6 + 6 * sqrt(3), 12)	-- ok this is hard to explain ..

asserteq( (sqrt(5) + 1) * (sqrt(5) - 1), 4)
asserteq( sqrt((sqrt(5) + 1) * (sqrt(5) - 1)), 2)

asserteq( (1 + 2 / sqrt(3)) / (2 * sqrt(3)), (2 + sqrt(3)) / 6 )

asserteq( (frac(1,3)*(-(1-sqrt(3)))) * (frac(1,3)*(-(1-sqrt(3)))) + (frac(1,6)*(2+sqrt(3))) * (frac(1,3)*(1+sqrt(3))) + (frac(1,6)*-(1+2*sqrt(3))) * frac(1,3), (4 - sqrt(3))/6 )

asserteq( 1/sqrt(6) + 1/sqrt(6), 2/sqrt(6) )

asserteq( (32 * sqrt(3) + 32 * sqrt(15)) / 384, (sqrt(3) + sqrt(15)) / 12 )

asserteq( sqrt(5)/(2*sqrt(3)), sqrt(15)/6 )

asserteq( -1/(2*sqrt(3)), -sqrt(frac(1,12)) )
assertne( -sqrt(frac(1,12)), sqrt(frac(1,12)) )

asserteq( (sqrt(2)*sqrt(frac(1,3))) * -frac(1,3) + (-frac(1,2)) * (sqrt(2)/sqrt(3)) + (frac(1,2)*1/sqrt(3)) * (-sqrt(2)/3), -sqrt(2) / sqrt(3) )

asserteq( 1 + ( -(7 - 3*sqrt(5)) / (3*(3 - sqrt(5))) )*(1 + frac(1,2)), (1 + sqrt(5))/4 )

asserteq( (-(sqrt(5)-1)/2)/sqrt((-(sqrt(5)-1)/2)^2 + 1), -sqrt( (sqrt(5) - 1) / (2 * sqrt(5)) ))

asserteq(sqrt(frac(15,16)) * sqrt(frac(2,3)), sqrt(5)/(2*sqrt(2)))

-- start with -1 / ( (√√5 √(√5 - 1)) / √2 ) ... what mine gets now vs what mathematica gets
asserteq( -1 / ( sqrt(sqrt(5) * (sqrt(5) - 1)) / sqrt(2) ), sqrt((5  + sqrt(5)) / 10))
asserteq( -(sqrt( 10 * (sqrt(5) - 1) ) + sqrt(2 * (sqrt(5) - 1))) / (4 * sqrt(sqrt(5))), sqrt((5  + sqrt(5)) / 10))

]=]), '\n')) do
	env.exec(line)
end

end)
