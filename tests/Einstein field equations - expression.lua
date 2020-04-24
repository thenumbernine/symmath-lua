#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{implicitVars=true, fixVariableNames=true, MathJax={title='Einstein field equations - expression'}}

local g_def = g'_ab'
printbr(g_def)

local ConnL_def = Gamma'_abc':eq(frac(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a'))
printbr(ConnL_def)

local Conn_def = Gamma'^a_bc':eq(g'^ad' * Gamma'_dbc')
printbr(Conn_def)

Conn_def = Conn_def:subst(ConnL_def:reindex{abc='dbc'})
printbr(Conn_def)

dConn_def = Conn_def:reindex{d='e'}'_,d'()
printbr(dConn_def)

Riemann_def = R'^a_bcd':eq(Gamma'^a_bd,c' - Gamma'^a_bc,d' + Gamma'^a_ec' * Gamma'^e_bd' - Gamma'^a_ed' * Gamma'^e_bc')
printbr(Riemann_def)

-- sort symmetric indexes alphabetically
local function g_sortSymIndexes(expr)
	local TensorRef = require 'symmath.tensor.TensorRef'
	if TensorRef.is(expr)
	and expr[1] == var'g'
	then
		local indexes = table{table.unpack(expr,2)}
		local nonderiv = table()
		while indexes[1] and not indexes[1].derivative do
			nonderiv:insert(indexes:remove(1))
		end
		indexes:sort(function(a,b) return a.symbol < b.symbol end)
		nonderiv:sort(function(a,b) return a.symbol < b.symbol end)
		indexes = table(nonderiv):append(indexes)
		local result = TensorRef(expr[1], indexes:unpack())
		--printbr('changing', nonderiv:map(tostring):concat',', expr, 'to',result)
		return result
	end
end

Riemann_def = Riemann_def:subst(
	dConn_def,
	dConn_def:reindex{abcd='abdc'},
	Conn_def:reindex{abcd='aecf'},
	Conn_def:reindex{abcd='ebdg'},
	Conn_def:reindex{abcd='aedf'},
	Conn_def:reindex{abcd='ebcg'}
):map(g_sortSymIndexes):simplify()
-- TODO sum indexes, e,f,g, can be rearranged
printbr(Riemann_def)

local Ricci_def = R'_bd':eq(Riemann_def:rhs():reindex{a='c'})
	:map(g_sortSymIndexes):simplify()
	:reindex{abcd='cadb'}
printbr(Ricci_def)

local Gaussian_def = R:eq(g'^bd' * Ricci_def:rhs())
	:map(g_sortSymIndexes):simplify()
	:factorDivision()
printbr(Gaussian_def)

local Einstein_def = G'_ab':eq(R'_ab' - frac(1,2) * g'_ab' * R)
printbr(Einstein_def)

Einstein_def = Einstein_def:subst(Ricci_def, Gaussian_def)():factorDivision()
printbr(Einstein_def)
