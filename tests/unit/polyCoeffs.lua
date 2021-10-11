#!/usr/bin/env lua
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/polyCoeffs')

timer(nil, function()

env.a = var'a'
env.x = var'x'
env.const = env.Constant
env.verbose = true

for _,line in ipairs(string.split(string.trim([=[

for k,v in pairs( const(1):polyCoeffs(x) ) do printbr(k, '=', v) end

simplifyAssertAllEq( const(1):polyCoeffs(x), {[0]=const(1)})

simplifyAssertAllEq( x:polyCoeffs(x), {[1]=const(1)} )
simplifyAssertAllEq( sin(x):polyCoeffs(x), {extra=sin(x)} )
simplifyAssertAllEq( (x^2 - a):polyCoeffs(x), {[0]=-a, [2]=const(1)} )
simplifyAssertAllEq( (x^2 - 2 * a * x + a^2):polyCoeffs(x), {[0]=a^2, [1]=-2*a, [2]=const(1)} )

]=]), '\n')) do
	env.exec(line)
end

end)
