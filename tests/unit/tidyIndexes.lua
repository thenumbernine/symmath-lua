#!/usr/bin/env luajit
require 'symmath'.setup{MathJax={title='tidy indexes', pathToTryToFindMathJax='..'}}

local a = var'a'
local b = var'b'
local c = var'c'
local d = var'd'
local e = var'e'
local f = var'f'

for _,test in ipairs{
	{a'^i_i^j_j', a'^a_a^b_b'},
	{a'^i_i' + a'^j_j', 2 * a'^a_a'},
	{a'^ij' * (b'_jk' + c'_jk'), a'^ia' * (b'_ak' + c'_ak')},
	{a'_ijk' * b'^jk' + a'_ilm' * b'^lm', 2 * a'_iab' * b'^ab'},
	{a'_ajk' * b'^jk' + a'_alm' * b'^lm', 2 * a'_abc' * b'^bc'},
	{c'^pq' * (d'_ipqj' + d'_jpqi') - c'^mr' * (d'_imrj' + d'_jmri'), 0},
	{(a'^k' + b'^k') * (c'_k' + d'_k'), (a'^a' + b'^a') * (c'_a' + d'_a')},
	{a'^i' * (b'_i' + c'_i^j' * d'_j'), a'^a' * (b'_a' + c'_a^b' * d'_b')},
	{(a'^i' + b'^i_j' * c'^j') * (d'_i' + e'_i^k' * f'_k'), (a'^a' + b'^a_b' * c'^b') * (d'_a' + e'_a^c' * f'_c')},
	{-a'_i' * a'_j' + (d'_ji^k' + d'_ij^k' - d'^k_ij') * (a'_k' + c'_k' - d'^l_lk'), 
		-a'_i' * a'_j' + (d'_ji^a' + d'_ij^a' - d'^a_ij') * (a'_a' + c'_a' - d'^b_ba') },
	{a'^j_aj' * b'^a' - a'^k_jk' * b'^j', 0},
} do
	local expr, expect = table.unpack(test)
	printbr(expr)
	expr = expr:tidyIndexes()
	printbr(expr)
	printbr(expr, 'vs', expect, 'equal?', (expr - expect)() == Constant(0))
	printbr'<hr>'
end
