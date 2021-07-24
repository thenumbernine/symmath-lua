#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'test')

timer(nil, function()

env.a = symmath.Variable('a')
env.b = symmath.Variable('b')
env.f = symmath.Variable('f')
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

asserteq( (x*y)/(x*y)^2, 1/(x*y) )

-- origin of the error:
asserteq( 1/(1-x), -1/(x-1) )
-- without needing to factor the polynomial
asserteq(((x-1)*(x+1))/(x+1), x-1)
asserteq(((x-1)*(x+1))/(x-1), x+1)
asserteq((x-1)/((x+1)*(x-1)), 1/(x+1))
asserteq((x+1)/((x+1)*(x-1)), 1/(x-1))
-- with needing to factor the polynomial
asserteq((x^2-1)/(x+1), x-1)
asserteq((x^2-1)/(x-1), x+1)
asserteq((x-1)/(x^2-1), 1/(x+1))
asserteq((x+1)/(x^2-1), 1/(x-1))
-- ... and with signs flipped
asserteq((1-x^2)/(x+1), -(x-1))
asserteq((1-x^2)/(x-1), -(x+1))
asserteq((x-1)/(1-x^2), -1/(x+1))
asserteq((x+1)/(1-x^2), -1/(x-1))

-- expand(): add div mul

-- factor(): mul add div

-- infinite.  
-- using https://en.wikipedia.org/wiki/Limit_of_a_function 
-- TODO should these be valid, or should they always produce 'invalid' 
-- and only Limit() produce valid operations on infinity?

asserteq(inf, inf)
assertne(inf, -inf)
assertne(inf, invalid)

-- q + inf = inf for q != -inf
asserteq(inf + inf, inf)
asserteq(inf + 0, inf)
asserteq(inf + 1, inf)
asserteq(inf - 1, inf)
asserteq(inf + x + y, inf)

-- q * inf = inf for q > 0 (incl q == inf)
-- q * inf = -inf for q < 0 (incl q == -inf)
asserteq((inf * inf), inf)
asserteq((inf * -inf), -inf)
asserteq((inf * -1), -inf)
asserteq((inf * -1 * -2), inf)
asserteq((inf * 1 * 2), inf)
asserteq(inf * x, inf)		-- TODO this should be unknown unless x is defined as a positive or negative real
asserteq(inf / 2, inf)

-- 0 * inf = invalid
asserteq(inf * 0, invalid)
asserteq(inf / 0, invalid)

-- q / inf = 0 for q != inf and q != -inf
asserteq(-2 / inf, 0)
asserteq(-1 / inf, 0)
asserteq(-.5 / inf, 0)
asserteq(0 / inf, 0)
asserteq(.5 / inf, 0)
asserteq(1 / inf, 0)
asserteq(2 / inf, 0)

-- inf^q = 0 for q < 0
-- inf^q = inf for q > 0
asserteq(inf ^ -inf, invalid)
asserteq(inf ^ -2, 0)
asserteq(inf ^ -1, 0)
asserteq(inf ^ -.5, 0)
asserteq(inf ^ 0, invalid)
asserteq(inf ^ .5, inf)
asserteq(inf ^ 1, inf)
asserteq(inf ^ 2, inf)
asserteq(inf ^ inf, inf)

-- q^inf = 0 for 0 < q < 1
-- q^inf = inf for 1 < q
asserteq((-2) ^ inf, invalid)
asserteq((-.5) ^ inf, invalid)
asserteq(0 ^ inf, invalid)
asserteq(.5 ^ inf, 0)
asserteq(2 ^ inf, inf)

-- q^-inf = inf for 0 < q < 1
-- q^-inf = 0 for 1 < q
asserteq((-2) ^ -inf, invalid)
asserteq((-.5) ^ -inf, invalid)
asserteq(0 ^ -inf, invalid)
asserteq(.5 ^ -inf, inf)
asserteq(2 ^ -inf, 0)

-- indeterminant:
asserteq(Constant(0) / 0, invalid)
asserteq(-inf / inf, invalid)
asserteq(inf / inf, invalid)
asserteq(inf / -inf, invalid)
asserteq(-inf / -inf, invalid)
asserteq(0 * inf, invalid)
asserteq(0 * -inf, invalid)
asserteq(inf + -inf, invalid)
asserteq(Constant(0) ^ 0, invalid)
asserteq(inf ^ 0, invalid)
asserteq((-1) ^ inf, invalid)
asserteq((-1) ^ -inf, invalid)
asserteq(1 ^ inf, invalid)
asserteq(1 ^ -inf, invalid)

-- trigonometry
asserteq((sin(x)^2+cos(x)^2)(), 1)
asserteq((y*sin(x)^2+y*cos(x)^2)(), y)
asserteq((y+y*sin(x)^2+y*cos(x)^2)(), 2*y)
asserteq((1+y*sin(x)^2+y*cos(x)^2)(), 1+y)

asserteq(1+cos(x)^2+cos(x)^2, 1+2*cos(x)^2)
asserteq(-1+cos(x)^2+cos(x)^2, -1+2*cos(x)^2)

asserteq( cos(x)^2 + sin(x)^2, 1)
asserteq( (cos(x)*y)^2 + (sin(x)*y)^2, y^2)

assert( printbr( (a * cos(b)^2 - a)() ) == -a * sin(b)^2 )
assert( printbr( (a^2 * cos(b)^2 - a^2)() ) == -a^2 * sin(b)^2 )

-- it would be nice if the final form of sin(x)^2 was exactly that.
assert( printbr((sin(x)^2)()) == sin(x)^2 )

-- some more stuff

asserteq((y-x)/(x-y), -1)
asserteq((x+y)/(x+y)^2, 1/(x+y))
asserteq((-x+y)/(-x+y)^2, 1/(-x+y))

asserteq( gUxy * (gUxy^2 - gUxx*gUyy) / (gUxx * gUyy - gUxy^2), -gUxy)
asserteq( gUxy * (gUxy - gUxx*gUyy) / (gUxx * gUyy - gUxy), -gUxy)
asserteq( gUxy * (gUxy - gUxx) / (gUxx - gUxy), -gUxy)

assert( not( Constant(0) == x * y ) )
assert( Constant(0) ~= x * y )
asserteq( Constant(0):subst( (v'^k' * v'^l' * g'_kl'):eq(var'vsq') ), Constant(0) )
asserteq( Constant(0):replace( v'^k' * v'^l' * g'_kl', var'vsq' ), Constant(0) )
asserteq( Constant(0):replace( v'^k' * v'^l', var'vsq' ), Constant(0) )
asserteq( Constant(0):replace( v'^k', var'vsq' ), Constant(0) )

-- fixed this bug with op.div.rules.Prune.negOverNeg
asserteq(-f * a^2 + f^3 * a^2 - f^5 * a^2, -f * a^2 * (1 - f^2 + f^4))	-- 'a' var lexically before 'f' var, squared, times -1's, simplification loop.  oscillates between factoring out the -1 or not.
asserteq(-f * g^2 + f^3 * g^2 - f^5 * g^2, -f * g^2 * (1 - f^2 + f^4))	-- 'g' var lexically before 'f' var, no simplification loop
asserteq(f * a^2 + f^3 * a^2 + f^5 * a^2, f * a^2 * (1 + f^2 + f^4))	-- replace -1's with +1's, no simplification loop
asserteq(-f * a + f^3 * a - f^5 * a, -f * a * (1 - f^2 + f^4))			-- replace a^2 with a, no simplification loop
asserteq(-f * a^2 + f^2 * a^2 - f^3 * a^2, -f * a^2 * (1 - f  + f^2))	-- replace f * quadratic of f^2 with f * quadratic of f, no simplification loop

]=]), '\n')) do
	env.exec(line)
end

end)
