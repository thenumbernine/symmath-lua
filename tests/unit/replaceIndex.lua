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

asserteq( a'_a':replaceIndex(a'^u', b'^u'), a'_a')			-- variance must match in order for the replace to work
asserteq( a'^a':replaceIndex(a'^b', b'^b'), b'^a' )
asserteq( a'^a':replaceIndex(a'^b', b'^b' + c'^b'), b'^a' + c'^a' )
asserteq( a'^a':replaceIndex(a'^b', b'^bc' * c'_c'), b'^ab' * c'_b' )		-- the sum indexes won't use the same symbol, because the symbols are not preserved and instead chosen among unused symbols in the result expression
asserteq( a'^a':replaceIndex(a'^b', b'^b' + c'^bc' * d'_c'), b'^a' + c'^ab' * d'_b' )

asserteq( a'_ab':replaceIndex(a'_uv', b'_uv'), b'_ab')			-- TODO looks like indexes get reversed
asserteq( a'_ab':replaceIndex(a'_uv', b'_vu'), b'_ba')

asserteq( (a'_a' + b'_ab' * c'^b'):replaceIndex(a'_u', b'_u'), b'_a' + b'_ab' * c'^b')

asserteq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', c'_uv'), a'_a' + c'_ab' * c'^b')	-- TODO this should preserve the order of b_ab -> c_ab

asserteq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', d'_uv'), a'_a' + d'_ab' * c'^b')	-- TODO this should preserve the order of b_ab -> d_ab

asserteq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', c'_bv'), a'_a' + c'_ab' * c'^b')	-- what should this produce?  Technically it is invalid match, only matching one index.  All indexes should match for a replacement to be made.  Technically this maybe should be an error?

]=]), '\n')) do
	env.exec(line)
end
