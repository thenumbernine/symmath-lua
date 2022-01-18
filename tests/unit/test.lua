#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/test')

-- TODO rename this to tests/unit/simplify.lua maybe?

timer(nil, function()

env.a = var'a'
env.b = var'b'
env.f = var'f'
env.g = var'g'
env.r = var'r'
env.s = var's'
env.t = var't'
env.v = var'v'
env.x = var'x'
env.y = var'y'

env.gUxx = var'\\gamma^{xx}'
env.gUxy = var'\\gamma^{xy}'
env.gUyy = var'\\gamma^{yy}'

env.l = var'l'
env.lambda = var'lambda'
env.delta = var'delta'

-- constant simplificaiton
for _,line in ipairs(string.split(string.trim([=[

simplifyAssertEq(1, (Constant(1)*Constant(1))())					-- multiply by 1
simplifyAssertEq(1, (Constant(1)/Constant(1))())					-- divide by 1
simplifyAssertEq(-1, (-Constant(1)/Constant(1))())					-- divide by -1
simplifyAssertEq(1, (Constant(1)/(Constant(1)*Constant(1)))())		-- multiply and divide by 1

-- commutativity
simplifyAssertEq(x+y, y+x)											-- add commutative
simplifyAssertEq(x*y, y*x)											-- mul commutative

-- pruning operations
simplifyAssertEq(x, (1*x)())										-- prune 1*
simplifyAssertEq(x, (x*1)())										-- prune *1
simplifyAssertEq(0, (0*x)())										-- prune *0
simplifyAssertEq((x/x)(), 1)

simplifyAssertEq(x^2, (x*x)())

-- simplify(): div add mul
simplifyAssertEq(((x+1)*y)(), (x*y + y)())
simplifyAssertEq(((x+1)*(y+1))(), (x*y + x + y + 1)())
simplifyAssertEq((2/(2*x*y))(), (1/(x*y))())
simplifyAssertEq((1-(1-x))(), x)
simplifyAssertEq(((1-(1-x))/x)(), 1)
simplifyAssertEq((1 + 1/x + 1/x)(), (1 + 2/x)())
simplifyAssertEq((1 + 1/x + 2/x)(), (1 + 3/x)())

-- factoring integers
simplifyAssertEq((Constant(2)/Constant(2))(), Constant(1))
simplifyAssertEq((Constant(2)/Constant(4))(), (Constant(1)/Constant(2))())

simplifyAssertEq(((2*x + 2*y)/2)(), (x+y)())
simplifyAssertEq(((-2*x + 2*y)/2)(), (-x+y)())

simplifyAssertEq(-1-x, -(1+x))

simplifyAssertEq((-x)/x, -1)
simplifyAssertEq((x/(-x)), -1)
simplifyAssertEq((-x-1)/(x+1), -1)
simplifyAssertEq((x-1)/(1-x), -1)

simplifyAssertEq( (x*y)/(x*y)^2, 1/(x*y) )

-- origin of the error:
simplifyAssertEq( 1/(1-x), -1/(x-1) )
-- without needing to factor the polynomial
simplifyAssertEq(((x-1)*(x+1))/(x+1), x-1)
simplifyAssertEq(((x-1)*(x+1))/(x-1), x+1)
simplifyAssertEq((x-1)/((x+1)*(x-1)), 1/(x+1))
simplifyAssertEq((x+1)/((x+1)*(x-1)), 1/(x-1))
-- with needing to factor the polynomial
simplifyAssertEq((x^2-1)/(x+1), x-1)
simplifyAssertEq((x^2-1)/(x-1), x+1)
simplifyAssertEq((x-1)/(x^2-1), 1/(x+1))
simplifyAssertEq((x+1)/(x^2-1), 1/(x-1))
-- ... and with signs flipped
simplifyAssertEq((1-x^2)/(x+1), -(x-1))
simplifyAssertEq((1-x^2)/(x-1), -(x+1))
simplifyAssertEq((x-1)/(1-x^2), -1/(x+1))
simplifyAssertEq((x+1)/(1-x^2), -1/(x-1))

-- make sure sorting of expression terms works
simplifyAssertEq(y-a, -a+y)
simplifyAssertEq( (y-a)/(b-a) , y/(b-a) - a/(b-a) )

print((a^2 * x^2 - a^2)())	-- just printing this, i was getting simplification loops

simplifyAssertEq( (t - r) / (-r^2 - t^2 + 2 * r * t), -1 / (t - r))	-- this won't simplify correctly unless you negative , simplify, negative again ...

simplifyAssertEq( (-128 + 64*sqrt(5))/(64*sqrt(5)), -2 / sqrt(5) + 1 )

-- expand(): add div mul

-- factor(): mul add div

-- trigonometry

simplifyAssertEq((sin(x)^2+cos(x)^2)(), 1)
simplifyAssertEq((y*sin(x)^2+y*cos(x)^2)(), y)
simplifyAssertEq((y+y*sin(x)^2+y*cos(x)^2)(), 2*y)
simplifyAssertEq((1+y*sin(x)^2+y*cos(x)^2)(), 1+y)

simplifyAssertEq(1+cos(x)^2+cos(x)^2, 1+2*cos(x)^2)
simplifyAssertEq(-1+cos(x)^2+cos(x)^2, -1+2*cos(x)^2)

simplifyAssertEq( cos(x)^2 + sin(x)^2, 1)
simplifyAssertEq( (cos(x)*y)^2 + (sin(x)*y)^2, y^2)

assert( printbr( (cos(b)^2 - 1)() ) == -sin(b)^2 )
assert( printbr( (a * cos(b)^2 - a)() ) == -(a * sin(b)^2) )
assert( printbr( (a^2 * cos(b)^2 - a^2)() ) == -(a^2 * sin(b)^2) )		-- the only one that doesn't work
assert( printbr( (a^3 * cos(b)^2 - a^3)() ) == -(a^3 * sin(b)^2) )
assert( printbr( (a^4 * cos(b)^2 - a^4)() ) == -(a^4 * sin(b)^2) )

assert( printbr( (1 - cos(b)^2)() ) == sin(b)^2 )
assert( printbr( (a - a * cos(b)^2)() ) == a * sin(b)^2 )
assert( printbr( (a^2 - a^2 * cos(b)^2)() ) == a^2 * sin(b)^2 )			-- also the only one that doesn't work
assert( printbr( (a^3 - a^3 * cos(b)^2)() ) == a^3 * sin(b)^2 )
assert( printbr( (a^4 - a^4 * cos(b)^2)() ) == a^4 * sin(b)^2 )



-- it would be nice if the final form of sin(x)^2 was exactly that.
assert( printbr((sin(x)^2)()) == sin(x)^2 )

-- some more stuff

simplifyAssertEq((y-x)/(x-y), -1)
simplifyAssertEq((x+y)/(x+y)^2, 1/(x+y))
simplifyAssertEq((-x+y)/(-x+y)^2, 1/(-x+y))

simplifyAssertEq( gUxy * (gUxy^2 - gUxx*gUyy) / (gUxx * gUyy - gUxy^2), -gUxy)
simplifyAssertEq( gUxy * (gUxy - gUxx*gUyy) / (gUxx * gUyy - gUxy), -gUxy)
simplifyAssertEq( gUxy * (gUxy - gUxx) / (gUxx - gUxy), -gUxy)

assert( not( Constant(0) == x * y ) )
assert( Constant(0) ~= x * y )
simplifyAssertEq( Constant(0):subst( (v'^k' * v'^l' * g'_kl'):eq(var'vsq') ), Constant(0) )
simplifyAssertEq( Constant(0):replace( v'^k' * v'^l' * g'_kl', var'vsq' ), Constant(0) )
simplifyAssertEq( Constant(0):replace( v'^k' * v'^l', var'vsq' ), Constant(0) )
simplifyAssertEq( Constant(0):replace( v'^k', var'vsq' ), Constant(0) )

-- fixed this bug with op.div.rules.Prune.negOverNeg
simplifyAssertEq(-f * a^2 + f^3 * a^2 - f^5 * a^2, -f * a^2 * (1 - f^2 + f^4))	-- 'a' var lexically before 'f' var, squared, times -1's, simplification loop.  oscillates between factoring out the -1 or not.
simplifyAssertEq(-f * g^2 + f^3 * g^2 - f^5 * g^2, -f * g^2 * (1 - f^2 + f^4))	-- 'g' var lexically before 'f' var, no simplification loop
simplifyAssertEq(f * a^2 + f^3 * a^2 + f^5 * a^2, f * a^2 * (1 + f^2 + f^4))	-- replace -1's with +1's, no simplification loop
simplifyAssertEq(-f * a + f^3 * a - f^5 * a, -f * a * (1 - f^2 + f^4))			-- replace a^2 with a, no simplification loop
simplifyAssertEq(-f * a^2 + f^2 * a^2 - f^3 * a^2, -f * a^2 * (1 - f  + f^2))	-- replace f * quadratic of f^2 with f * quadratic of f, no simplification loop

-- this runs forever (unless I push certain rules)
(b^2 * (a * r^2 + (a + 3 * sqrt(b^2 + delta^2))) * (a + sqrt(b^2 + delta^2))^2 / (3 * (r^2 + (a + sqrt(b^2 + delta^2))^2)^frac(5,2) * (b^2 + delta^2)^frac(3,2)) - lambda * exp(-l^2 / 2)):diff(delta)()

]=]), '\n')) do
	env.exec(line)
end

end)
