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

local m = symmath.Matrix(
{0,0,0,0,0,0,0,-sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(f)*g.xx,sqrt(f)*g.xy,sqrt(f)*g.xz,sqrt(f)*g.yy,sqrt(f)*g.yz,sqrt(f)*g.zz,-2*sqrt(g.xx),-2*g.xy/sqrt(g.xx),-2*g.xz/sqrt(g.xx)},
{0,0,0,0,0,0,0,0,0,0,0,-sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,-1/g.xx,0},
{0,0,0,0,0,0,0,0,0,0,0,0,-sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,-1/g.xx},
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
{0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(f)*g.xx,sqrt(f)*g.xy,sqrt(f)*g.xz,sqrt(f)*g.yy,sqrt(f)*g.yz,sqrt(f)*g.zz,2/g.xx,0,0}
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

mInv = m:inverse()

if outputMethod == 'MathJax' then 
	print((tostring((mInv * v):equals((mInv*v):simplify():factorDivision():tidy())):gsub('0','\\cdot')))
	print'<br><br>' 
	print(MathJax.footer)
elseif outputMethod == 'SingleLine' then
	print(mInv)
elseif outputMethod == 'Lua' then
	print(select(2, (mInv*v):simplify():compile(allVars)))
end

