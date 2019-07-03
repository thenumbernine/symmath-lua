#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{MathJax={useCommaDerivative=true, title='remove beta from ADM metric'}}

local B = var'B'
local g = var'g'
local n = var'n'
local Gamma = var'\\Gamma'
local Lambda = var'\\Lambda'
local alpha = var'\\alpha'
local beta = var'\\beta'
local gamma = var'\\gamma'
local delta = var'\\delta'

local g_def = Matrix(
	{-alpha^2+beta'^k'*beta'_k', beta'_j'},
	{beta'_i', gamma'_ij'}
)
printbr(g'_uv':eq(g_def))

local Lambda_def = Matrix(
	{Gamma, -Gamma * B * n'_j'},
	{-Gamma * B * n'^i', delta'^i_j' + (Gamma - 1) * n'^i' * n'_j'}
)
printbr(Lambda'^u_v':eq(Lambda_def))

local newg_def = Lambda_def:reindex{ia='ij'}:T() * g_def * Lambda_def:reindex{jb='ij'}
printbr(var"g'"'_ab'
	:eq(Lambda'^u_a' * g'_uv' * Lambda'^v_b')
	:eq(newg_def))
newg_def = newg_def()
printbr(var"g'"'_ab':eq(newg_def))

newg_def = newg_def
	-- g'_tt
	:replace(beta'^k' * beta'_k', beta^2)
	:replace((n'^i' * n'^j' * gamma'_ij')(), n^2)
	:replace(n'^i' * beta'_i', n'^k' * beta'_k')
	:replace(n'^j' * beta'_j', n'^k' * beta'_k')
	--:replace((-beta^2 + 2 * B * beta * n'^k' * beta'_k' - B^2 * n^2)(), -(beta - B * n)^2)
	-- g'_it	
	:replace(beta'_i' * delta'^i_a', beta'_a')
	:replace(delta'^i_a' * gamma'_ij', gamma'_aj')
	:replace(n'^j' * gamma'_aj', n'_a')
	-- g'_ij
	:replace(delta'^j_b' * gamma'_aj', gamma'_ab')
	:replace(delta'^j_b' * gamma'_ij', gamma'_ib')
	:replace(beta'_j' * delta'^j_b', beta'_b')
	:replace(n'^i' * gamma'_ib', n'_b')
	
	:replace(n^2, 1)
	:simplify()
printbr(var"g'"'_ab':eq(newg_def))

do
	local newg_def = newg_def:clone()
	local repl = Gamma:eq(1/sqrt(1 - B^2))
	printbr('Let', repl)
	newg_def = newg_def:subst(repl)()
	printbr(var"g'"'_ab':eq(newg_def))

	do
		local newg_def = newg_def:clone()
		local zeta = var'\\zeta'
		local repl = n'^i':eq(zeta * beta'^i')
		printbr('Let', repl)
		newg_def = newg_def
			:substIndex(repl)()
			:replaceIndex(n'_i', zeta * beta'_i')
			:replace(n^2, zeta^2 * beta^2)
			:replace(beta'^k' * beta'_k', beta^2)
			:simplify()
		printbr(var"g'"'_ab':eq(newg_def))
	end

--[=[
	print'Alternatively,'
	local repl = (n'^k' * beta'_k'):eq(0)
	printbr('let', repl)
	newg_def = newg_def:substIndex(repl)
		:simplify()
	printbr(var"g'"'_ab':eq(newg_def))
--]=]
end

--[=[
print'Alternatively,'
local zeta = var'\\zeta'
local repl2 = B:eq(sqrt(1 -  1/Gamma^2))
local repl3 = n'^i':eq(-1/zeta * beta'^i')
printbr('let', repl2, ',', repl3, 'for $\\zeta = ||\\beta||$')
newg_def = newg_def
	:subst(repl2)
	:substIndex(repl3)
	:replaceIndex(n'_a', -1/zeta * beta'_a')
	:simplify()
	:replaceIndex((beta'^k' * beta'_k')(), beta^2)
	:replace(zeta^2, beta^2)
	:simplify()
printbr(var"g'"'_ab':eq(newg_def))
local newg_ti = newg_def[2][1]
printbr(var"g'"'_ti':eq(0):eq(newg_ti), 'for...')
--[[
local solveFor = (newg_ti * Gamma^2 * beta^2 / beta'_a')():eq(0)
printbr(solveFor)
local s = var's'
solveFor = solveFor:replace(Gamma^2, s):replace(Gamma^4, s^2)()
printbr(solveFor)
local solns = table{solveFor:solve(s)}
for _,soln in ipairs(solns) do
	printbr(soln)
end
--]]
--]=]
