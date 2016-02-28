#!/usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'
local Tensor = symmath.Tensor

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

local outputCode = outputMethod == 'Lua' or outputMethod == 'C' 

local printbr
if outputCode then
	printbr = print
else
	printbr = function(...)
		print(...)
		print'<br>'
	end
end

local sqrt = symmath.sqrt


-- split index into 3 and symNames components: 
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

-- tr(K) = g^ij K_ij = g^xx K_xx + g^yy K_yy + g^zz K_zz + 2 g^xy K_xy + 2 g^xz K_xz + 2 g^yz K_yz
-- so the trace scalars associated with symmetric index pairs {xx, xy, xz, yy, yz, zz} are ...
local traceScalar = {1, 2, 2, 1, 2, 1}


local f = symmath.var('f')

-- coordinates
local xNames = table{'x', 'y', 'z'}
local xs = xNames:map(function(x) return symmath.var(x) end)
Tensor.coords{{variables=xs}}

-- symmetric indexes: xx xy xz yy yz zz
local symNames = table()
for i=1,3 do
	for j=i,3 do
		symNames:insert(xNames[i]..xNames[j])
	end
end

-- symmetrically-indexed gamma upper.  i.e. stores only 6 in the symNames order
-- indexed by name or index of symmetric indexes, i.e. by .yz or [5] for matching yz/zy component
local gammaUsym = symNames:map(function(xij)
	return symmath.var(outputCode and ('gammaU'..xij) or ('\\gamma^{'..xij..'}'))
end)


-- state variables:
local alpha = symmath.var(outputCode and 'alpha' or '\\alpha')
local As = xNames:map(function(xi,i) return symmath.var('A_'..xi) end)
local gammaLsym = symNames:map(function(xij,ij) return symmath.var('\\gamma_{'..xij..'}') end)
	-- Dsym[i][jk]	for jk symmetric indexed from 1 thru 6
local Dsym = xNames:map(function(xi,i)
	return symNames:map(function(xjk,jk)
		return symmath.var('D_{'..xi..xjk..'}')
	end)
end)
	-- D_ijk unique symmetric, unraveled
local Dflattened = table():append(Dsym:unpack())
local Ksym = symNames:map(function(xij,ij) return symmath.var('K_{'..xij..'}') end)
local Vs = xNames:map(function(xi,i) return symmath.var('V_'..xi) end)


-- tensors of variables:
local gammaU = Tensor('_ij', function(i,j) return gammaUsym[from3x3to6(i,j)] end)
local gammaL = Tensor('_ij', function(i,j) return gammaLsym[from3x3to6(i,j)] end)
local A = Tensor('_i', function(i) return As[i] end)
local D = Tensor('_ijk', function(i,j,k) return Dsym[i][from3x3to6(j,k)] end)
local K = Tensor('_ij', function(i,j) return Ksym[from3x3to6(i,j)] end)
local V = Tensor('_i', function(i) return Vs[i] end)

Tensor.metric(gammaL, gammaU)

-- lookup of variables to their flattened lists and other associated information 
local vars = table{
	{name='\\alpha', flattened={alpha}},
	{name='\\gamma', flattened=gammaLsym},
	{name='A', flattened=A},
	{name='D', flattened=Dflattened},
	{name='K', flattened=Ksym},
	{name='V', flattened=V},
}
do
	local pos = 1
	for _,var in ipairs(vars) do
		local name = var.name:match('\\?(.*)')	-- remove leading \\ for greek characters
		var.size = #var.flattened
		var.pos = pos
		pos = pos + var.size
		vars[name] = var
	end
end

local timeVars = table{vars.alpha, vars.gamma}
local fieldVars = table{vars.A, vars.D, vars.K, vars.V}

-- variables flattened and combined into one table
local timeVarsFlattened = table()
local fieldVarsFlattened = table()
for _,info in ipairs{
	{timeVars, timeVarsFlattened},
	{fieldVars, fieldVarsFlattened},
} do
	local infoVars, infoVarsFlattened = table.unpack(info)
	for _,var in ipairs(infoVars) do
		infoVarsFlattened:append(var.flattened)
	end
end

local varsFlattened = table():append(timeVarsFlattened, fieldVarsFlattened)
assert(#varsFlattened == 37, "expected 37 but found "..#varsFlattened)

-- all symbolic variables for use with compiled functions
local compileVars = table():append(varsFlattened):append{f}:append(gammaUsym)

-- all variables combined into one vector
local v = symmath.Matrix(varsFlattened:map(function(v) return {v} end):unpack())


-- [[ for verification -- manual entered eigenvector inverse matrix
do
	local gU = gammaUsym:map(function(gammaUij,ij) return gammaUij, symNames[ij] end)
	local Fx = symmath.Matrix(
			{0,0,0,0,0,0,0,-sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(f)*gU.xx,2*sqrt(f)*gU.xy,2*sqrt(f)*gU.xz,sqrt(f)*gU.yy,2*sqrt(f)*gU.yz,sqrt(f)*gU.zz,-2*sqrt(gU.xx),-2*gU.xy/sqrt(gU.xx),-2*gU.xz/sqrt(gU.xx)},
			{0,0,0,0,0,0,0,0,0,0,0,-sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,-1/sqrt(gU.xx),0},
			{0,0,0,0,0,0,0,0,0,0,0,0,-sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,-1/sqrt(gU.xx)},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,-sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,-sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0},
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
			{0,0,0,0,0,0,0,1,0,0,-f*gU.xx,-2*f*gU.xy,-2*f*gU.xz,-f*gU.yy,-2*f*gU.yz,-f*gU.zz,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1/sqrt(gU.xx),0},
			{0,0,0,0,0,0,0,0,0,0,0,0,sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1/sqrt(gU.xx)},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0},
			{0,0,0,0,0,0,0,sqrt(gU.xx),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sqrt(f)*gU.xx,2*sqrt(f)*gU.xy,2*sqrt(f)*gU.xz,sqrt(f)*gU.yy,2*sqrt(f)*gU.yz,sqrt(f)*gU.zz,2*sqrt(gU.xx),2*gU.xy/sqrt(gU.xx),2*gU.xz/sqrt(gU.xx)}
		):simplify()
	if not outputCode then
		print('verify:<br>')
		print(Fx)
		print('<br>')
	end
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
			code = code:gsub('sqrt%(gammaUsym'..ii..'%)', 'sqrt_gU'..ii)
			code = code:gsub('%(gammaUsym'..ii..' %^ %(3 / 2%)%)', 'gammaUsym'..ii..'_toThe_3_2')
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

eigenfields:

--]]

local VU = V'^i':simplify()
local trK = K'^i_i':simplify()
local trDk = D'_km^m':simplify()
local delta = symmath.Matrix.identity(3)

local ms = range(3):map(function(dir)

	-- x's other than the current dir
	local oxIndexes = range(3)
	oxIndexes:remove(dir)
	local oxNames = oxIndexes:map(function(i) return xNames[i] end)

	-- symmetric, with 2nd index matching dir removed 
	local osymIndexes = range(6):filter(function(ij)
		local i,j = from6to3x3(ij)
		return i ~= dir or j ~= dir
	end)


	-- TODO all of this mess ...
	-- for indexes pq != dir, r=dir
	-- [[ TODO extract matrix entries from this
	local eigenfields = table()
	
	-- timelike:
	--[[
	the alpha and gamma don't have to be part of the flux, but i'm lazy so i'm adding them in with the rest of the lambda=0 eigenfields
	however in doing so, it makes factoring the linear system a pain, because you're not supposed to factor out alphas or gammas
	...except with the alpha and gamma eigenfields when you have to ...
	--]]
		-- alpha
	eigenfields:insert{w=alpha, lambda=0}
		-- gamma_ij
	eigenfields:append(gammaLsym:map(function(gamma_ij,ij) return {w=gamma_ij, lambda=0} end))
		-- A_x', x' != dir
	eigenfields:append(oxIndexes:map(function(p) return {w=A[p], lambda=0} end))
		-- D_x'ij, x' != dir
	eigenfields:append(oxIndexes:map(function(p)
		return Dsym[p]:map(function(D_pij)
			return {w=D_pij, lambda=0}
		end)
	end):unpack())
		-- V_i
	eigenfields:append(range(3):map(function(i) return {w=V[i], lambda=0} end))
		-- A_x - f D_xm^m, x = dir
	eigenfields:insert{w=A[dir] - f * trDk[dir], lambda=0}
	
	for sign=-1,1,2 do
		-- light cone -+
			-- K_ix'
		local loc = sign == -1 and 1 or #eigenfields+1
		for _,ij in ipairs(osymIndexes) do
			local i,j = from6to3x3(ij)
			if j == dir then i,j = j,i end
			assert(j ~= dir)
			eigenfields:insert(loc, {
				w = K[i][j] + sign * sqrt(gammaU[dir][dir]) * (D[dir][i][j] + delta[dir][i] * V[j] / gammaU[dir][dir]),
				lambda = sign * alpha * sqrt(gammaU[dir][dir]),
			})
			loc=loc+1
		end
		-- gauge -+
		local loc = sign == -1 and 1 or #eigenfields+1
		eigenfields:insert(loc, {
			w = sqrt(f) * trK + sign * sqrt(gammaU[dir][dir]) * (A[dir] + 2 * VU[dir] / gammaU[dir][dir]),
			lambda = sign * alpha * sqrt(f * gammaU[dir][dir]),
		})
	end
	--]]
	assert(#eigenfields == #varsFlattened)

--[[
	printbr()
	printbr('eigenvalues')
	printbr()
	for _,field in ipairs(eigenfields) do
		printbr(symmath.simplify(field.lambda))
	end
	printbr()
	printbr('eigenfields')
	printbr()
	for _,field in ipairs(eigenfields) do
		printbr(symmath.simplify(field.w))
	end
--]]

	-- now just do a matrix factor of the eigenfields on varsFlattened and viola.
	local A, b = symmath.factorLinearSystem(
		eigenfields:map(function(field) return field.w end),
		fieldVarsFlattened)

	-- now add in 0's for cols corresponding to the timelike vars (which aren't supposed to be in the linear system)
	-- [[ this asserts that the time vars go first and the field vars go second in the varsFlattened
	for i=1,#A do
		for j=1,#timeVarsFlattened do
			table.insert(A[i], 1, symmath.Constant(0))
		end
		assert(#A[i] == #varsFlattened)
	end
	assert(#A == #varsFlattened)
	--]]

	-- only for the eigenfields corresponding to the time vars ...
	-- I have to pick them out of the system
	-- I *should* be not including them to begin with
	assert(#b == #eigenfields)
	for _,var in ipairs(timeVarsFlattened) do
		local j = varsFlattened:find(var) 
		for i,field in ipairs(eigenfields) do
			-- if the eigenfield is the time var then ...
			if field.w == var then
				-- ... it shouldn't have been factored out.  and there shouldn't be anything else.
				assert(b[i][1] == var, "expected "..var.." but got "..b[i].." for row "..i)
				-- so manually insert it into the eigenvector inverse 
				A[i][j] = symmath.Constant(1)
				-- and manually remove it from the source term
				b[i][1] = symmath.Constant(0)
			end
		end
	end
	
	-- make sure all source terms are gone
	for i=1,#b do
		assert(#b[i] == 1)
		assert(b[i][1] == symmath.Constant(0), "expected b["..i.."] to be 0 but found "..b[i][1])
	end

	local m = A

	
	if not outputCode then 
		printbr('inverse eigenvectors in '..dir..' dir')
		printbr((tostring((m * v):equals((m*v):simplify():factorDivision():tidy())):gsub('0','\\cdot')))
		printbr()
	else
		print('-- inverse eigenvectors in '..dir..' dir:')
		print(processCode(select(2, (m*v):simplify():compile(compileVars))))		
	end
io.stdout:flush()
	printbr('inverting...')
	io.stdout:flush()
	local mInv = m:inverse()
	printbr('...done inverting')
	io.stdout:flush()
	if not outputCode then 
		printbr('eigenvectors in '..dir..' dir')
		printbr((tostring((mInv * v):equals((mInv*v):simplify():factorDivision():tidy())):gsub('0','\\cdot')))
		printbr()
	else
		print('-- eigenvectors in '..dir..' dir:')
		print(processCode(select(2, (mInv*v):simplify():compile(compileVars))))
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
	if not outputCode then
		printbr(delta)
		printbr()	
	end
io.stdout:flush()
	--[[ eigenvalues
	local l = symmath.Matrix.diagonal(
		-alpha * sqrt(f * gammaUSymNamed.xx)
	)
	--]]
end)

if outputMethod == 'MathJax' then 
	print(MathJax.footer)
end
