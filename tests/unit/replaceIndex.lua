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
env.g = var'g'
env.fixed = var'fixed'
env.summed = var'summed'
require 'ext.env'(env)

function env.assertIndexesUsed(expr, ft, st)
	local f, s = expr:getIndexesUsed()

	for _,info in ipairs{
		{f, ft},
		{s, st},
	} do 
		local indexes, t = table.unpack(info)
		if Variable.is(t) then
			if #indexes ~= 0 then
				error(t.." expected no indexes, but found "..tolua(indexes))
			end
		else
			local expr = TensorRef(t[1], indexes:unpack())
			return asserteq(expr, t)
		end
	end
end

for _,line in ipairs(string.split(string.trim([=[

asserteq( a:replaceIndex(a, b), b )

asserteq( a'_a':replaceIndex(a'^u', b'^u'), a'_a' )			-- variance must match in order for the replace to work
asserteq( a'^a':replaceIndex(a'^b', b'^b'), b'^a' )
asserteq( a'^a':replaceIndex(a'^b', b'^b' + c'^b'), b'^a' + c'^a' )
asserteq( a'^a':replaceIndex(a'^b', b'^bc' * c'_c'), b'^ab' * c'_b' )		-- the sum indexes won't use the same symbol, because the symbols are not preserved and instead chosen among unused symbols in the result expression
asserteq( a'^a':replaceIndex(a'^b', b'^b' + c'^bc' * d'_c'), b'^a' + c'^ab' * d'_b' )

asserteq( a'_ab':replaceIndex(a'_uv', b'_uv'), b'_ab' )			-- TODO looks like indexes get reversed
asserteq( a'_ab':replaceIndex(a'_uv', b'_vu'), b'_ba' )
asserteq( a'_ba':replaceIndex(a'_uv', b'_vu'), b'_ab' )
asserteq( a'_ab':replaceIndex(a'_vu', b'_uv'), b'_ba' )
asserteq( a'_ba':replaceIndex(a'_vu', b'_uv'), b'_ab' )


asserteq( (g'^am' * c'_mbc'):replaceIndex( g'^am' * c'_mbc', c'^a_bc' ), c'^a_bc')
asserteq( (g'^ad' * c'_dbc'):replaceIndex( g'^im' * c'_mjk', c'^i_jk' ), c'^a_bc')

asserteq( (a'_a' + b'_ab' * c'^b'):replaceIndex(a'_u', b'_u'), b'_a' + b'_ab' * c'^b' )

asserteq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', c'_uv'), a'_a' + c'_ab' * c'^b' )	-- TODO this should preserve the order of b_ab -> c_ab

asserteq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', d'_uv'), a'_a' + d'_ab' * c'^b' )	-- TODO this should preserve the order of b_ab -> d_ab

asserteq( a'^a_a':replaceIndex(a'^a_a', b'^a_a'), b'^a_a')
asserteq( a'^a_a':replaceIndex(a'^u_u', b'^u_u'), b'^a_a')

asserteq( (a'^a_a' * a'^b_b'):replaceIndex(a'^u_u', b'^u_u'), b'^a_a' * b'^b_b')

asserteq( a'^a_ab':replaceIndex(a'^a_ab', b'_b'), b'_b' )
asserteq( a'^a_ab':replaceIndex(a'^a_ab', b'_b' + c'_a^a_b'), b'_b' + c'_a^a_b' )

-- hmm, how to account for this?  if the fixed indexes don't match then I still want it to fall back on a plain replace()
asserteq( a'_t':replaceIndex(a'_t', b), b)
asserteq( a'_t':replaceIndex(a'_t', b'_u'), b'_u')
-- but in the event of a regular replace, I still want it to not collide sum indexes
asserteq( (a'_t' * b'^a_a'):replaceIndex(a'_t', c'_u' * d'^a_a'), c'_u' * b'^a_a' * d'^b_b')
-- what does this mean? the fixed indexes shouldn't have to match ...
-- if they don't match then assume they are not correlated between the 'find' and 'replace'

asserteq( (a'_ij' + c'_,t' * b'_ij'):replaceIndex( c'_,t', c * d'^i_i' ), a'_ij' + c * d'^a_a' * b'_ij' )
asserteq( (a'_ab' + c'_,t' * b'_ab'):replaceIndex( c'_,t', c * d'^a_a' ), a'_ab' + c * d'^c_c' * b'_ab' )

-- TODO so it looks like, when the replace expression has sum terms *AND* it is an Expression instead of just a TensorRef
--  that's when the sum indexes aren't replaced correctly
asserteq( (a'_ij' + c'_,t' * b'_ij'):replaceIndex( c'_,t', c * d'^i_i' + e'^i_i' ), a'_ij' + (c * d'^a_a' + e'^a_a') * b'_ij' )

printbr( g'_ij,t':eq(d * (d * b'^k_,i' * g'_kj' + d * b'^k_,j' * g'_ki' + d * b'^k' * c'_ijk' + d * b'^k' * c'_jik' + 2 * d'_,t' * g'_ij' - 2 * d * a * e'_ij') ):replaceIndex( d'_,t',  frac(1,3) * (3 * d'_,i' * b'^i' - d * b'^i_,i' - frac(1,2) * d * b'^i' * g'_,i' / g + e * d * a) ) )

-- and what about when find/replace has a partial number of fixed indexes
asserterror(function() (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', c'_bv') end )	-- what should this produce?  Technically it is invalid match, since the from and to don't have matching fixed indexes.  So... assert error?

]=]), '\n')) do
	env.exec(line)
end
