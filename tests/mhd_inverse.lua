#!/usr/bin/env luajit
-- these are the eigenvectors provided in Trangenstein

require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

-- I'd like to add this to the parent class metatable
--  but since child classes are flattened upon creation,
--  that would mean manually adding it to all child classes
function expandPowers(self)
	return self
		:simplify()
		:map(function(x) 	-- expand powers ...
			if x:isa(symmath.powOp) 
			and x[2]:isa(symmath.Constant)
			and x[2].value == math.floor(x[2].value)
			and x[2].value > 0
			then 
				local prod = x[1]:clone()
				for i=2,x[2].value do
					prod = prod * x[1]:clone()
				end
				return prod 
			end 
		end)
end


local vx = symmath.var'v_x'
local vy = symmath.var'v_y'
local vz = symmath.var'v_z'
local Bx = symmath.var'B_x'
local By = symmath.var'B_y'
local Bz = symmath.var'B_z'
local sigma = symmath.var'\\sigma'	-- sign(B dot n) = sign(Bx) for n = 1,0,0
local rho = symmath.var'\\rho'
local cf = symmath.var'c_f'
local c = symmath.var'c'
local cs = symmath.var'c_s'
local p = symmath.var'p'
local gamma = symmath.var'\\gamma'

local vSq = symmath.var'v^2'
vSq:depends(vx,vy,vz)
vSq_from_v = vSq:equals(vx^2+vy^2+vz^2)

local BSq = symmath.var'B^2'
BSq:depends(Bx,By,Bz)
BSq_from_v = BSq:equals(Bx^2+By^2+Bz^2)

-- p = (gamma - 1) rho e <=> e = p / (rho * (gamma - 1)) <=> rho e = p / (gamma - 1)
local u = symmath.Matrix{rho, rho*vx, rho*vy, rho*vz, Bx, By, Bz, p / (gamma - 1) + rho * vSq / 2 + BSq / 2}:transpose()	-- state variables
print('\\(u = \\)'..u..'<br>')

local w = symmath.Matrix{rho, vx, vy, vz, Bx, By, Bz, p}:transpose()	-- primitive variables
print('\\(w = \\)'..w..'<br>')

local du_dw = symmath.Tensor(table.map(u, function(u_i,i)
	u_i = u_i[1]
	u_i = u_i:subst(BSq_from_v, vSq_from_v)
	if type(i) ~= 'number' then return end
	return table.map(w, function(w_j,j)
		w_j = w_j[1]
		if type(j) ~= 'number' then return end
		return u_i:diff(w_j):simplify()
	end)
end):unpack())
print('\\({{du}\\over{dw}} = \\)'..du_dw..'<br>')

local dw_du = du_dw:inverse()
print('\\({{dw}\\over{du}} = \\)'..dw_du..'<br>')

-- in the case that B dot n == 0 ...
-- assuming n = 1,0,0 ...
local degenY = symmath.Matrix(
	{(rho * cf^2 - BSq) / c^2, 1, 0, 0, 0, 0, 0, (rho * cf^2 - BSq) / c^2},
	{-cf, 0, 0, 0, 0, 0, 0, cf},
	{0, 0, 1, 0, 0, 0, 0, 0},
	{0, 0, 0, 1, 0, 0, 0, 0},
	{0, 0, 0, 0, 1, 0, 0, 0},
	{By, 0, 0, 0, 0, 1, 0, By},
	{Bz, 0, 0, 0, 0, 0, 1, Bz},
	{rho * cf^2 - BSq, 0, 0, 0, 0, -By, -Bz, rho * cf^2 - BSq}
):subst(BSq:equals(By^2+Bz^2)):simplify()
local degenYInv = degenY:inverse()

local degenYortho = expandPowers((degenYInv * degenY)):simplify()
print('<br>')
print('degen case \\(B \\cdot n = 0\\)...<br>')
print('\\(Y = \\)'..degenY..'<br>')
print('\\(Y^{-1} = \\)'..degenYInv..'<br>')
print('\\(Y^{-1} \\cdot Y = \\)'..degenYortho..'<br>')

local Y = symmath.Matrix(
	{(rho * cf^2 - BSq) / c^2, 0, (rho * cs^2 - BSq) / c^2, 1, 0, (rho * cs^2 - BSq) / c^2, 0, (rho * cf^2 - BSq) / c^2},
	{-cf + Bx^2 / (rho * cf), 0, -cs + Bx^2 / (rho * cs), 0, 0, cs - Bx^2 / (rho * cs), 0, cf - Bx^2 / (rho * cf)},
	{Bx * By / (rho * cf), Bz * sigma, Bx * By / (rho * cs), 0, 0, -Bx * By / (rho * cs), -Bz * sigma, -Bx * By / (rho * cf)},
	{Bx * Bz / (rho * cf), -By * sigma, Bx * Bz / (rho * cs), 0, 0, -Bx * Bz / (rho * cs), By * sigma, -Bx * Bz / (rho * cf)},
	{0, 0, 0, 0, 1, 0, 0, 0},
	{By, Bz * symmath.sqrt(rho), By, 0, 0, By, Bz * symmath.sqrt(rho), By},
	{Bz, -By * symmath.sqrt(rho), Bz, 0, 0, Bz, -By * symmath.sqrt(rho), Bz},
	{rho * cf^2 - BSq, 0, rho * cs^2 - BSq, 0, 0, rho * cs^2 - BSq, 0, rho * cf^2 - BSq}
)

local YInvVars = table()
for i=1,8 do
	YInvVars[i] = table()
	for j=1,8 do
		YInvVars[i][j] = symmath.var('y^{-1}_{'..i..j..'}')
	end
end
--[[ imposed constraints:
YInvVars[1][1] = 0
YInvVars[1][5] = 0
YInvVars[2][1] = 0
YInvVars[2][5] = 0
YInvVars[3][1] = 0
YInvVars[3][5] = 0
YInvVars[4][1] = 1
YInvVars[4][5] = 0
YInvVars[5][1] = 0
YInvVars[5][2] = 0
YInvVars[5][3] = 0
YInvVars[5][4] = 0
YInvVars[5][5] = 1
YInvVars[5][6] = 0
YInvVars[5][7] = 0
YInvVars[5][8] = 0
YInvVars[6][1] = 0
YInvVars[6][5] = 0
YInvVars[7][1] = 0
YInvVars[7][5] = 0
YInvVars[8][1] = 0
YInvVars[8][5] = 0
--]]

--local YInv = Y:inverse()	-- dies
local YInv = symmath.Matrix(
	unpack(YInvVars)
--[[
	{	0,	0,	0,	0,	0,	0,	0,	0	},	
	{	0,	1,	0,	0,	0,	0,	0,	0	},	
	{	0,	0,	1,	0,	0,	0,	0,	0	},	
	{	1,	0,	0,	0,	0,	0,	0,	0	},	
	{	0,	0,	0,	0,	1,	0,	0,	0	},	
	{	0,	0,	0,	0,	0,	1,	0,	0	},	
	{	0,	0,	0,	0,	0,	0,	1,	0	},	
	{	0,	0,	0,	0,	0,	0,	0,	1	}
--]]
)

local YInvYEqns = table()
local YYInvEqns = table()
for i=1,8 do
	for j=1,8 do
		local lhs = symmath.Constant(i==j and 1 or 0)
		local YInvY_rhs = symmath.Constant(0)
		local YYInv_rhs = symmath.Constant(0)
		for k=1,8 do
			YInvY_rhs = YInvY_rhs + YInv[i][k] * Y[k][j]
			YYInv_rhs = YYInv_rhs + Y[i][k] * YInv[k][j]
		end
		local YInvYEqn = lhs:equals(YInvY_rhs):simplify()
		if YInvYEqn:rhs():isa(symmath.divOp) then YInvYEqn = (YInvYEqn * YInvYEqn:rhs()[2]):simplify() end
		YInvYEqn = YInvYEqn:subst(B_from_BSq):simplify()
		if not YInvYEqn:isTrue() then
			YInvYEqns:insert{i,j,YInvYEqn}
		end
		local YYInvEqn = lhs:equals(YYInv_rhs):simplify()
		if YYInvEqn:rhs():isa(symmath.divOp) then YYInvEqn = (YYInvEqn * YYInvEqn:rhs()[2]):simplify() end
		YYInvEqn = YYInvEqn:subst(B_from_BSq):simplify()
		if not YYInvEqn:isTrue() then
			YYInvEqns:insert{i,j,YYInvEqn}
		end
	end
end

--local Yortho = expandPowers((YInv * Y):subst(B_from_BSq)):simplify()
print('<br>')
print('full field case...<br>')
print('\\(Y = \\)'..Y..'<br>')
print('\\(Y^{-1} = \\)'..YInv..'<br>')
--print('\\(Y^{-1} \\cdot Y = \\)'..Yortho..'<br>')

local constraints = table()
for _,eqnlist in ipairs{YInvYEqns, YYInvEqns} do
	for k=#eqnlist,1,-1 do
		local i,j,eqn = unpack(eqnlist[k])
		if eqn[2]:isa(symmath.Variable) then
			eqnlist:remove(k)
			constraints:insert(eqn:switch())
		end
	end
end
YInv = YInv:subst(constraints:unpack())
print('after immediate constraints:<br>')
print('\\(Y^{-1} = \\)'..YInv..'<br>')

-- apply constraints to remaining eqn lists
for _,eqnlist in ipairs{YInvYEqns, YYInvEqns} do
	for k=#eqnlist,1,-1 do
		eqnlist[k][3] = eqnlist[k][3]:subst(constraints:unpack()):simplify()
		if eqnlist[k][3]:isTrue() then
			eqnlist:remove(k)
		end
	end
end

-- after substituting, pick out the variables left
local YInvRemainingVars = symmath.Matrix()
for i=1,8 do
	for j=1,8 do
		if YInv[i][j]:isa(symmath.Variable) then
			table.insert(YInvRemainingVars, symmath.Tensor(YInv[i][j]))
		end
	end
end
local YInvRemainingMatrix = symmath.Matrix()
local YInvRemainingSolution = symmath.Matrix()
print('constraints remaining:'..(#YInvYEqns+#YYInvEqns)..'<br>')
print('variables left to solve:'..#YInvRemainingVars..'<br>')
for _,info in ipairs(YInvYEqns) do
	local i,j,eqn = unpack(info)
	print('YInv row '..i..' Y col '..j..': '..eqn..'<br>')
	
	local row = symmath.Tensor()
	table.insert(YInvRemainingMatrix, row)
	for k,vars in ipairs(YInvRemainingVars) do
		local var = vars[1]
		row[k] = eqn:rhs():polyCoeffs(var)[1] or symmath.Constant(0)
		table.insert(YInvRemainingSolution, symmath.Tensor(eqn:lhs()))
	end
end
for _,info in ipairs(YYInvEqns) do
	local i,j,eqn = unpack(info)
	print('Y row '..i..' YInv col '..j..': '..eqn..'<br>')
	
	local row = symmath.Tensor()
	table.insert(YInvRemainingMatrix, row)
	for k,vars in ipairs(YInvRemainingVars) do
		local var = vars[1]
		row[k] = eqn:rhs():polyCoeffs(var)[1] or symmath.Constant(0)
		table.insert(YInvRemainingSolution, symmath.Tensor(eqn:lhs()))
	end
end

print('remaining matrix:'..YInvRemainingMatrix..'<br>')
print('remaining vector:'..YInvRemainingVars..'<br>')
print('remaining solution:'..YInvRemainingSolution..'<br>')
print((YInvRemainingMatrix * YInvRemainingVars):equals(YInvRemainingSolution) .. '<br>')
