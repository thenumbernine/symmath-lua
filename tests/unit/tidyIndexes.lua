#!/usr/bin/env luajit
require 'symmath'.setup{implicitVars=true, MathJax=true}
for _,test in ipairs{
	{K'^i_i' + K'^j_j', 2 * K'^a_a'},
	{a'^ij' * (b'_jk' + B'_jk'), a'^ia' * (b'_ak' + B'_ak')},
	{a'_ijk' * b'^jk' + a'_ilm' * b'^lm', 2 * a'_ibc' * b'^bc'},
	{a'_ajk' * b'^jk' + a'_alm' * b'^lm', 2 * a'_abc' * b'^bc'},
} do
	local expr, expect = table.unpack(test)
	printbr(expr)
	expr = expr:tidyIndexes()
	printbr(expr)
	expr = expr:simplify()
	printbr(expr)
	printbr'<hr>'
end
