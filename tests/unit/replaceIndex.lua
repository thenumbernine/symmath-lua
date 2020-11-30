#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'unit'(env, 'replaceIndex')

env.a = var'a'
env.b = var'b'
env.c = var'c'
env.d = var'd'
env.e = var'e'
env.f = var'f'


for _,line in ipairs(string.split(string.trim([=[

asserteq( a:replaceIndex(a, b), b )

asserteq( a'_a':replaceIndex(a'^u', b'^u'), a'_a' )			-- variance must match in order for the replace to work
asserteq( a'^a':replaceIndex(a'^b', b'^b'), b'^a' )
asserteq( a'^a':replaceIndex(a'^b', b'^b' + c'^b'), b'^a' + c'^a' )
asserteq( a'^a':replaceIndex(a'^b', b'^bc' * c'_c'), b'^ab' * c'_b' )		-- the sum indexes won't use the same symbol, because the symbols are not preserved and instead chosen among unused symbols in the result expression
asserteq( a'^a':replaceIndex(a'^b', b'^b' + c'^bc' * d'_c'), b'^a' + c'^ac' * d'_c' )

asserteq( a'_ab':replaceIndex(a'_uv', b'_uv'), b'_ab' )			-- TODO looks like indexes get reversed
asserteq( a'_ab':replaceIndex(a'_uv', b'_vu'), b'_ba' )
asserteq( a'_ba':replaceIndex(a'_uv', b'_vu'), b'_ab' )
asserteq( a'_ab':replaceIndex(a'_vu', b'_uv'), b'_ba' )
asserteq( a'_ba':replaceIndex(a'_vu', b'_uv'), b'_ab' )

asserteq( (a'_a' + b'_ab' * c'^b'):replaceIndex(a'_u', b'_u'), b'_a' + b'_ab' * c'^b' )

asserteq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', c'_uv'), a'_a' + c'_ab' * c'^b' )	-- TODO this should preserve the order of b_ab -> c_ab

asserteq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', d'_uv'), a'_a' + d'_ab' * c'^b' )	-- TODO this should preserve the order of b_ab -> d_ab

asserterror(function() (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', c'_bv') end )	-- what should this produce?  Technically it is invalid match, since the from and to don't have matching fixed indexes.  So... assert error?

asserteq( a'^a_a':replaceIndex(a'^a_a', b'^a_a'), b'^a_a')
asserteq( a'^a_a':replaceIndex(a'^u_u', b'^u_u'), b'^a_a')

asserteq( (a'^a_a' * a'^b_b'):replaceIndex(a'^u_u', b'^u_u'), b'^a_a' * b'^b_b')

asserteq( a'^a_ab':replaceIndex(a'^a_ab', b'_b'), b'_b' )
asserteq( a'^a_ab':replaceIndex(a'^a_ab', b'_b' + c'_a^a_b'), b'_b' + c'_a^a_b' )

]=]), '\n')) do
	env.exec(line)
end
