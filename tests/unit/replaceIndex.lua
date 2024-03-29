#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/replaceIndex')

timer(nil, function()

--[[
TODO
expr:replaceIndex(a'_i', b)
does that mean all a'_a' through a'_z' get replaced with 'b' (as a fixed index)
or does it mean that only a'_i' gets replaced with 'b' and the rest of a'_j' a'_k' etc remain unchanged?

this is a practical question, since I do my index notation stuff with _ij being arbitary indexes, but with _t being the specific time index
how to specify that '_t' should be a specific index, while the others are arbitrary?

for now I'll say that, if the index isn't matched between find and replace, it is assumed to be an extra index (not-to-be-remapped)
--]]

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
		if Variable:isa(t) then
			if #indexes ~= 0 then
				error(t.." expected no indexes, but found "..tolua(indexes))
			end
		else
			local expr = TensorRef(t[1], indexes:unpack())
			return simplifyAssertEq(expr, t)
		end
	end
end

for _,line in ipairs(string.split(string.trim([=[

simplifyAssertEq( a:replaceIndex(a, b), b )				-- if there are no indexes in the expr or in find then it falls back on 'replace'

simplifyAssertEq( a'_a':replaceIndex(a'^u', b'^u'), a'_a' )			-- variance must match in order for the replace to work
simplifyAssertEq( a'^a':replaceIndex(a'^b', b'^b'), b'^a' )
simplifyAssertEq( a'^a':replaceIndex(a'^b', b'^b' + c'^b'), b'^a' + c'^a' )
simplifyAssertEq( a'^a':replaceIndex(a'^b', b'^bc' * c'_c'), b'^ab' * c'_b' )		-- the sum indexes won't use the same symbol, because the symbols are not preserved and instead chosen among unused symbols in the result expression
simplifyAssertEq( a'^a':replaceIndex(a'^b', b'^b' + c'^bc' * d'_c'), b'^a' + c'^ab' * d'_b' )

simplifyAssertEq( a'_ab':replaceIndex(a'_uv', b'_uv'), b'_ab' )
simplifyAssertEq( a'_ab':replaceIndex(a'_uv', b'_vu'), b'_ba' )
simplifyAssertEq( a'_ba':replaceIndex(a'_uv', b'_vu'), b'_ab' )
simplifyAssertEq( a'_ab':replaceIndex(a'_vu', b'_uv'), b'_ba' )
simplifyAssertEq( a'_ba':replaceIndex(a'_vu', b'_uv'), b'_ab' )


simplifyAssertEq( (g'^am' * c'_mbc'):replaceIndex( g'^am' * c'_mbc', c'^a_bc' ), c'^a_bc')
simplifyAssertEq( (g'^am' * c'_mbc'):replaceIndex( g'^an' * c'_nbc', c'^a_bc' ), c'^a_bc')	-- mapping the sum index
simplifyAssertEq( (g'^am' * c'_mbc'):replaceIndex( g'^im' * c'_mjk', c'^i_jk' ), c'^a_bc')	-- mapping the fixed indexes
simplifyAssertEq( (g'^am' * c'_mbc'):replaceIndex( g'^id' * c'_djk', c'^i_jk' ), c'^a_bc')	-- mapping both

simplifyAssertEq( (a'_a' + b'_ab' * c'^b'):replaceIndex(a'_u', b'_u'), b'_a' + b'_ab' * c'^b' )

simplifyAssertEq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', c'_uv'), a'_a' + c'_ab' * c'^b' )	-- TODO this should preserve the order of b_ab -> c_ab

simplifyAssertEq( (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', d'_uv'), a'_a' + d'_ab' * c'^b' )	-- TODO this should preserve the order of b_ab -> d_ab

simplifyAssertEq( a'^a_a':replaceIndex(a'^a_a', b'^a_a'), b'^a_a')
simplifyAssertEq( a'^a_a':replaceIndex(a'^u_u', b'^u_u'), b'^a_a')

simplifyAssertEq( (a'^a_a' * a'^b_b'):replaceIndex(a'^u_u', b'^u_u'), b'^a_a' * b'^b_b')

simplifyAssertEq( a'^a_ab':replaceIndex(a'^a_ab', b'_b'), b'_b' )
simplifyAssertEq( a'^a_ab':replaceIndex(a'^a_ab', b'_b' + c'_a^a_b'), b'_b' + c'_a^a_b' )

-- hmm, how to account for this?  if the fixed indexes don't match then I still want it to fall back on a plain replace()
simplifyAssertEq( a'_t':replaceIndex(a'_t', b), b)
simplifyAssertEq( a'_t':replaceIndex(a'_t', b'_u'), b'_u')
-- but in the event of a regular replace, I still want it to not collide sum indexes
simplifyAssertEq( (a'_t' * b'^a_a'):replaceIndex(a'_t', c'_u' * d'^a_a'), c'_u' * b'^a_a' * d'^b_b')
-- what does this mean? the fixed indexes shouldn't have to match ...
-- if they don't match then assume they are not correlated between the 'find' and 'replace'

simplifyAssertEq( (a'_ij' + c'_,t' * b'_ij'):replaceIndex( c'_,t', c * d'^i_i' ), a'_ij' + c * d'^a_a' * b'_ij' )
simplifyAssertEq( (a'_ab' + c'_,t' * b'_ab'):replaceIndex( c'_,t', c * d'^a_a' ), a'_ab' + c * d'^c_c' * b'_ab' )

-- TODO so it looks like, when the replace expression has sum terms *AND* it is an Expression instead of just a TensorRef
--  that's when the sum indexes aren't replaced correctly
simplifyAssertEq( (a'_ij' + c'_,t' * b'_ij'):replaceIndex( c'_,t', c * d'^i_i' + e'^i_i' ), a'_ij' + (c * d'^a_a' + e'^a_a') * b'_ij' )

printbr( g'_ij,t':eq(d * (d * b'^k_,i' * g'_kj' + d * b'^k_,j' * g'_ki' + d * b'^k' * c'_ijk' + d * b'^k' * c'_jik' + 2 * d'_,t' * g'_ij' - 2 * d * a * e'_ij') ):replaceIndex( d'_,t',  frac(1,3) * (3 * d'_,i' * b'^i' - d * b'^i_,i' - frac(1,2) * d * b'^i' * g'_,i' / g + e * d * a) ) )

-- only if extra indexes match.  in this case, extra is 'k'.
simplifyAssertEq( (g'_ab,t' * g'_cd,e'):replaceIndex(g'_ij,k', c'_ij'), g'_ab,t' * g'_cd,e')
simplifyAssertEq( (g'_ab,t' * g'_cd,e'):replaceIndex(g'_ij,t', c'_ij'), c'_ab' * g'_cd,e')

-- TODO make sure summed indexes aren't matched incorreclty
simplifyAssertEq( a'^a_a':replaceIndex( a'^a_b', b'^a_b'), b'^a_a')	-- replaceIndex with more general indexes should work
simplifyAssertEq( a'^a_b':replaceIndex( a'^a_a', b'^a_a'), a'^a_b')	-- replaceIndex with more specific (summed) indexes shouldn't
simplifyAssertEq( (a'^a_b' * a'^c_c'):replaceIndex( a'^a_a', b'^a_a'), (a'^a_b' * b'^c_c'))	-- and the two should be discernable
-- same but replace with scalars
simplifyAssertEq( a'^a_a':replaceIndex( a'^a_b', b), a'^a_a')			-- in this case, a^a_b's indexes are considered extra since they are not in b as well, so they will be exactly matched in the expression.  since no a^a_b exists, it will not match and not replace.
simplifyAssertEq( a'^a_b':replaceIndex( a'^a_a', b), a'^a_b')
simplifyAssertEq( (a'^a_b' * a'^c_c'):replaceIndex( a'^a_a', b), (a'^a_b' * b))

printbr( d'_,t':eq( frac(1,6) * ( d * ( 2 * e * a - b'^k_,i' * g'^ij' * g'_jk' - b'^k_,j' * g'_ik' * g'^ij' - b'^k' * g'^ij' * g'_ij,k' ) )):replaceIndex( g'_ij', c'_ij' / d^2  ) )
printbr( d'_,t':eq( 2 * e * a - b'^k_,i' * g'^ij' * g'_jk' - b'^k_,j' * g'_ik' * g'^ij' - b'^k' * g'^ij' * g'_ij,k' ):replaceIndex( g'_ij', c'_ij' / d^2  ) )

simplifyAssertEq( d'_,t':eq( b'^k_,i' * g'^ij' * g'_jk' ):replaceIndex( g'_ij', c'_ij' / d^2  ), d'_,t':eq(b'^k_,i' * g'^ij' * c'_jk' / d^2) )

simplifyAssertEq( d'_,t':eq( g'^jk' * g'_jk' ):replaceIndex( g'_ij', c'_ij' / d^2  ), d'_,t':eq( g'^jk' * c'_jk' / d^2) )

-- does fixed in the find/repl to map into sums in the expr
simplifyAssertEq( a'^i_i':replaceIndex(a'^i_j', b'^i_j'), b'^i_i')

-- why do neither of these work?  because if there are *only* sum-indexes won't match, however if there are extra indexes then it will match.  why do we have this constraint again?
-- internal sum indexes do seem to work in replaceIndex, like A^a_a, but externally shared between two tensors don't: A^a * A_a ... why distinguish?
print( (a'^a' * a'_a'):replaceIndex(a'^a' * a'_a', 2))
print( (a'^a' * a'_a'):replaceIndex(a'^a' * a'_a', b'^a' * b'_a'))
print( (c'_b' * a'^a' * a'_a'):replaceIndex(c'_b' * a'^a' * a'_a', 2))

-- and what about when find/replace has a partial number of fixed indexes
assertError(function() return (a'_a' + b'_ab' * c'^b'):replaceIndex(b'_uv', c'_bv') end )	-- what should this produce?  Technically it is invalid match, since the from and to don't have matching fixed indexes.  So... assert error?

]=]), '\n')) do
	env.exec(line)
end

env.done()
end)
