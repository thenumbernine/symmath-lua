#!/usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'

local outputMethod = ... or 'MathJax'
--[[
local outputMethod = 'MathJax'		-- HTML
local outputMethod = 'SingleLine'	-- pasting into Excel
local outputMethod = 'Lua'			-- code generation
--]]

local MathJax
if outputMethod == 'MathJax' then
	MathJax = require 'symmath.tostring.MathJax'
	symmath.tostring = MathJax 
	print(MathJax.header)
elseif outputMethod == 'SingleLine' then
	symmath.tostring = require 'symmath.tostring.SingleLine'
end

local sqrt = symmath.sqrt

local m = symmath.Matrix({1,1},{1,0})

local sym3x3 = table{'xx', 'xy', 'xz', 'yy', 'yz', 'zz'}

local f = symmath.var'f'
local g = sym3x3:map(function(ij) 
	if outputMethod == 'Lua' then
		return symmath.var('gU'..ij), ij
	else
		return symmath.var('g^{'..ij..'}'), ij
	end
end)
mVars = table():append{f}:append(g:map(function(x,k,t) return x, #t+1 end))

local vVars = range(37):map(function(i)
	if outputMethod == 'Lua' then
		return symmath.var('v_'..i)
	else
		-- TODO correct naming of variables?
		return symmath.var('v_{'..i..'}')
	end
end)
local allVars = table():append(vVars):append(mVars)

local v = symmath.Matrix(vVars:map(function(v) return {v} end):unpack())

--[[
alpha
gamma_xx, gamma_xy, gamma_xz, gamma_yy, gamma_yz, gamma_zz,
a_x, a_y, a_z
d_xxx, d_xxy, d_xxz, d_xyy, d_xyz, d_xzz,
d_yxx, d_yxy, d_yxz, d_yyy, d_yyz, d_yzz,
d_zxx, d_zxy, d_zxz, d_zyy, d_zyz, d_zzz,
K_xx, K_xy, K_xz, K_yy, K_yz, K_zz,
V_x, V_y, V_z

hyperbolic system:

partial_t alpha = -alpha^2 f tr K
partial_t g_ij = -2 alpha K_ij
partial_t A_k + alpha f g^ij partial_k K_ij = -alpha tr K (f + alpha f') A_k + 2 alpha f K^ij D_kij
partial_t D_kij + alpha partial_k K_ij = -alpha A_k K_ij
partial_t K_ij + alpha (g^km partial_k D_mij + 1/2 (delta^k_i partial_k A_j + delta^k_j partial_k A_i) + delta^k_i partial_k V_j + delta^k_j partial_k V_i) = alpha S_ij - alpha lambda^k_ij A_k + 2 alpha D_mij D_k^km
partial_t V_k = alpha P_k

--]]
local m = symmath.Matrix(
{0,0,0,0,0,0,0,-sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(f)*g.xx,sqrt(f)*g.xy,sqrt(f)*g.xz,sqrt(f)*g.yy,sqrt(f)*g.yz,sqrt(f)*g.zz,-2*sqrt(g.xx),-2*g.xy/sqrt(g.xx),-2*g.xz/sqrt(g.xx)},
{0,0,0,0,0,0,0,0,0,0,0,-sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,-1/sqrt(g.xx),0},
{0,0,0,0,0,0,0,0,0,0,0,0,-sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,-1/sqrt(g.xx)},
{0,0,0,0,0,0,0,0,0,0,0,0,0,-sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,-sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{0,0,0,0,0,0,0,1,0,0,-f*g.xx,-f*g.xy,-f*g.xz,-f*g.yy,-f*g.yz,-f*g.zz,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1/g.xx,0},
{0,0,0,0,0,0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1/g.xx},
{0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0},
{0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(f)*g.xx,sqrt(f)*g.xy,sqrt(f)*g.xz,sqrt(f)*g.yy,sqrt(f)*g.yz,sqrt(f)*g.zz,2*sqrt(g.xx),2*g.xy/sqrt(g.xx),2*g.xz/sqrt(g.xx)}
)
m = m:simplify()
if outputMethod == 'MathJax' then 
	print((tostring((m * v):equals((m*v):simplify():factorDivision():tidy())):gsub('0','\\cdot')))
	print'<br><br>'
elseif outputMethod == 'SingleLine' then
	print(m)
elseif outputMethod == 'Lua' then
	print(select(2, (m*v):simplify():compile(allVars)))
end

local mInv = m:inverse()

if outputMethod == 'MathJax' then 
	print((tostring((mInv * v):equals((mInv*v):simplify():factorDivision():tidy())):gsub('0','\\cdot')))
	print'<br><br>' 
elseif outputMethod == 'SingleLine' then
	print(mInv)
elseif outputMethod == 'Lua' then
	print(select(2, (mInv*v):simplify():compile(allVars)))
end

-- verify orthogonality
delta = (m * mInv):simplify()
for i=1,delta:dim()[1].value do
	for j=1,delta:dim()[2].value do
		local Constant = require 'symmath.Constant'
		assert(Constant.is(delta[i][j]))
		assert(delta[i][j].value == (i == j and 1 or 0))
	end
end
if outputMethod ~= 'Lua' then
	print(delta)
	if outputMethod == 'MathJax' then 
		print'<br><br>'
	end
end

--[[ eigenvalues
local l = symmath.Matrix.diagonal(
	-alpha * sqrt(f * gU.xx)
)
--]]
if outputMethod == 'MathJax' then 
	print(MathJax.footer)
end
