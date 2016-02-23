#!/usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'

local outputMethod = ... or 'MathJax'
--[[
local outputMethod = 'MathJax'		-- HTML
local outputMethod = 'SingleLine'	-- pasting into Excel
local outputMethod = 'Lua'			-- code generation
local outputMethod = 'C'			-- code gen as well
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

local gIndexed = sym3x3:map(function(var)
	if outputMethod == 'Lua' 
	or outputMethod == 'C'
	then
		return symmath.var('gU'..var)
	else
		return symmath.var('g^{'..var..'}')
	end
end)
local g = gIndexed:map(function(g_ij, ij) return g_ij, sym3x3[ij] end)

mVars = table():append{f}:append(g:map(function(x,k,t) return x, #t+1 end))

local vVars = range(37):map(function(i)
	if outputMethod == 'Lua' or outputMethod == 'C' then
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

-- split index into 3 and sym3x3 components: 
local function from18to3x6(i)
	return math.floor((i-1)/6)+1, ((i-1)%6)+1
end

local function from3x3to6(i,j)
	return ({{1,2,3},
			 {2,4,5},
			 {3,5,6}})[i][j]
end

local function from6to3x3(i)
	return table.unpack(({{1,1},{1,2},{1,3},{2,2},{2,3},{3,3}})[i])
end

local vars = table{
	alpha = {name='alpha', pos=1, size=1},
	gamma = {name='gamma', pos=2, size=6},
	A = {name='A', pos=8, size=3},
	D = {name='D', pos=11, size=3*6},
	K = {name='K', pos=29, size=6},
	V = {name='V', pos=35, size=3},
}
local ms = range(3):map(function(dir)
	return symmath.Matrix(range(37):map(function(row)
			return range(37):map(function(col)
				-- determine which variable and index block 'col' is in
				local var	-- which variable
				local varindex	-- which index of the variable, 1-based
				for _,ovar in pairs(vars) do
					if col >= ovar.pos and col < ovar.pos+ovar.size then
						var = ovar
						varindex = col - ovar.pos+1
						break
					end
				end
				assert(var and varindex)
				
				-- determine which eigenfield 'row' is in
				if row == 1 or row == 37 then	-- fast -+
					local sign = row == 1 and -1 or 1
					if var == vars.A then
						return varindex == dir and sign * sqrt(gIndexed[from3x3to6(dir,dir)]) or 0
					elseif var == vars.K then
						return sqrt(f) * gIndexed[varindex]
					elseif var == vars.V then
						return sign * 2 * gIndexed[from3x3to6(dir,varindex)] / sqrt(gIndexed[from3x3to6(dir,dir)])
					end
					return 0
				elseif (row >= 2 and row <= 6) or (row >= 32 and row <= 36) then -- light -+
					local sign = row <= 6 and -1 or 1
					local eigindex = (row <= 6) and (row-2+1) or (row-32+1)
					if var == vars.D then
						local m,pq = from18to3x6(varindex)
						local p,q = from6to3x3(pq)
						local eigindexWithDirAdded = eigindex + (eigindex >= from3x3to6(dir,dir) and 1 or 0)
						return (m == dir and pq == eigindexWithDirAdded) and sign * sqrt(gIndexed[from3x3to6(dir,dir)]) or 0
					elseif var == vars.K then	-- working for x and y (and maybe z)
						local eigindexWithDirAdded = eigindex + (eigindex >= from3x3to6(dir,dir) and 1 or 0)
						return varindex == eigindexWithDirAdded and 1 or 0
					elseif var == vars.V then	-- working for x and y (and maybe z)
						-- for dir, if eigindex has that dir and another dir then use V of the other dir
						local eigindexWithDirAdded = eigindex + (eigindex >= from3x3to6(dir, dir) and 1 or 0)
						local i,chi = from6to3x3(eigindexWithDirAdded)
						if chi == dir then i,chi = chi,i end	-- get dir in i, other dir in chi
						if chi == varindex and i == dir then return sign / sqrt(gIndexed[from3x3to6(dir,dir)]) end
						return 0
					end
					return 0
				elseif row == 7 then	-- alpha
					return var == vars.alpha and 1 or 0
				elseif row >= 8 and row <= 13 then	-- gamma
					local eigindex = row-8+1
					return (var == vars.gamma and varindex == eigindex) and 1 or 0
				elseif row >= 14 and row <= 15 then	-- A
					local eigindex = row-14+1	-- 1 or 2 
					local eigindexWithDirAdded = eigindex + (eigindex >= dir and 1 or 0)
					return (var == vars.A and eigindexWithDirAdded == varindex) and 1 or 0
				elseif row >= 16 and row <= 27 then	-- D
					local eigindex = row-16+1
					local eigindexWithDirAdded = eigindex + ((eigindex >= (dir-1)*6+1) and 6 or 0)
					return (var == vars.D and varindex == eigindexWithDirAdded) and 1 or 0
				elseif row >= 28 and row <= 30 then	-- V
					local eigindex = row-28+1
					return (var == vars.V and varindex == eigindex) and 1 or 0
				elseif row == 31 then	-- dir
					if var == vars.A and varindex == dir then return 1 end
					if var == vars.D then
						local m,pq = from18to3x6(varindex)
						if m == dir then return -f * gIndexed[pq] end
					end
					return 0
				end
			end):map(function(x)
				return symmath.Expression.is(x) and x:simplify() or x
			end)
		end):unpack())
end)
	
-- [[ for verification -- manual entered eigenvector inverse matrix
local manual = symmath.Matrix(
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
		{0,0,0,0,0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1/sqrt(g.xx),0},
		{0,0,0,0,0,0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1/sqrt(g.xx)},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0},
		{0,0,0,0,0,0,0,sqrt(g.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(f)*g.xx,sqrt(f)*g.xy,sqrt(f)*g.xz,sqrt(f)*g.yy,sqrt(f)*g.yz,sqrt(f)*g.zz,2*sqrt(g.xx),2*g.xy/sqrt(g.xx),2*g.xz/sqrt(g.xx)}
	):simplify()
if not (outputMethod == 'Lua' or outputMethod == 'C') then
	print('verify:<br>')
	print(manual)
	print('<br>')
end
--]]

local function processCode(code)
	code = code:gsub('v_(%d+)', function(i)
		if outputMethod == 'C' then return 'input['..(i-1)..']' end
		return 'v['..i..']'
	end)
	code = code:gsub('}, {', ',\n')
	-- remove the function wrapper
	code = code:match(', gUxx%) (.*) end$')
	if outputMethod == 'C' then
		code = code:match('^return {{(.*)}}$')
		code = code:gsub('math%.','')
		code = code:gsub('v%[', 'input%[')
		-- add in variables
		code = code:gsub('sqrt%(f%)', 'sqrt_f')
		for _,ii in ipairs{'xx', 'yy', 'zz'} do
			code = code:gsub('sqrt%(gU'..ii..'%)', 'sqrt_gU'..ii)
			code = code:gsub('%(gU'..ii..' %^ %(3 / 2%)%)', 'gU'..ii..'_toThe_3_2')
		end
		-- add assignments
		code = code:trim():split('\n'):map(function(line,i)
			line = line:gsub(',$','')..';'
			return 'results['..(i-1)..'] = '..line
		end):concat('\n')
		if code:find('sqrt%(') then error('found sqrt( at '..code) end
		if code:find('%^') then error('found ^ at '..code) end
		code = code:gsub('([^%[_])(%d+)([^%]_])', '%1%2%.f%3')
	end
	return code
end

for dir,m in ipairs(ms) do
	if outputMethod == 'MathJax' then 
		print('inverse eigenvectors in '..dir..' dir<br>')
		print((tostring((m * v):equals((m*v):simplify():factorDivision():tidy())):gsub('0','\\cdot')))
		print'<br><br>'
	elseif outputMethod == 'SingleLine' then
		print('inverse eigenvectors in '..dir..' dir:')
		print(m)
	elseif outputMethod == 'Lua' or outputMethod == 'C' then
		print('-- inverse eigenvectors in '..dir..' dir:')
		print(processCode(select(2, (m*v):simplify():compile(allVars))))		
	end
io.stdout:flush()
	print('inverting...')
	io.stdout:flush()
	local mInv = m:inverse()
	print('...done inverting')
	io.stdout:flush()
	if outputMethod == 'MathJax' then 
		print('eigenvectors in '..dir..' dir<br>')
		print((tostring((mInv * v):equals((mInv*v):simplify():factorDivision():tidy())):gsub('0','\\cdot')))
		print'<br><br>' 
	elseif outputMethod == 'SingleLine' then
		print('eigenvectors in '..dir..' dir')
		print(mInv)
	elseif outputMethod == 'Lua' or outputMethod == 'C' then
		print('-- eigenvectors in '..dir..' dir:')
		print(processCode(select(2, (mInv*v):simplify():compile(allVars))))
	end
io.stdout:flush()
	-- verify orthogonality
	delta = (m * mInv):simplify()
	for i=1,delta:dim()[1].value do
		for j=1,delta:dim()[2].value do
			local Constant = require 'symmath.Constant'
			assert(Constant.is(delta[i][j]))
			assert(delta[i][j].value == (i == j and 1 or 0))
		end
	end
	if not (outputMethod == 'Lua' or outputMethod == 'C') then
		print(delta)
		if outputMethod == 'MathJax' then 
			print'<br><br>'
		end
	end
io.stdout:flush()
	--[[ eigenvalues
	local l = symmath.Matrix.diagonal(
		-alpha * sqrt(f * gU.xx)
	)
	--]]
end

if outputMethod == 'MathJax' then 
	print(MathJax.footer)
end
