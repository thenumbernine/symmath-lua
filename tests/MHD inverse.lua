#!/usr/bin/env luajit
-- these are the eigenvectors provided in Trangenstein

require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='MHD inverse'}}

-- I'd like to add this to the parent class metatable
--  but since child classes are flattened upon creation,
--  that would mean manually adding it to all child classes
function expandPowers(self)
	return self()
		:map(function(x) 	-- expand powers ...
			if symmath.op.pow:isa(x) 
			and Constant:isa(x[2])
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


local vx = var'v_x'
local vy = var'v_y'
local vz = var'v_z'
local B = var'B'
local Bx = var'B_x'
local By = var'B_y'
local Bz = var'B_z'
local sigma = var'\\sigma'	-- sign(B dot n) = sign(Bx) for n = 1,0,0
local rho = var'\\rho'
local cf = var'c_f'
local c = var'c'
local cs = var'c_s'
local p = var'p'
local gamma = var'\\gamma'

local vSq = var('v^2', {vx,vy,vz})
vSq_from_v = vSq:eq(vx^2+vy^2+vz^2)

local BSq = var('B^2', {Bx,By,Bz})
BSq_from_v = BSq:eq(Bx^2+By^2+Bz^2)

local B_from_BSq = B:eq(sqrt(BSq))

-- p = (gamma - 1) rho e <=> e = p / (rho * (gamma - 1)) <=> rho e = p / (gamma - 1)
local u = Matrix{rho, rho*vx, rho*vy, rho*vz, Bx, By, Bz, p / (gamma - 1) + rho * vSq / 2 + BSq / 2}:transpose()	-- state variables
printbr(var'u':eq(u))

local w = Matrix{rho, vx, vy, vz, Bx, By, Bz, p}:transpose()	-- primitive variables
printbr(var'w':eq(w))

local du_dw = Array(table.mapi(u, function(u_i,i)
	u_i = u_i[1]
	u_i = u_i:subst(BSq_from_v, vSq_from_v)
	return table.mapi(w, function(w_j,j)
		w_j = w_j[1]
		return u_i:diff(w_j)()
	end)
end):unpack())
printbr(var'u':diff(var'w'):eq(du_dw))

local dw_du = du_dw:inverse()
printbr(var'w':diff(var'u'):eq(dw_du))

-- in the case that B dot n == 0 ...
-- assuming n = 1,0,0 ...
local degenY = Matrix(
	{(rho * cf^2 - BSq) / c^2, 1, 0, 0, 0, 0, 0, (rho * cf^2 - BSq) / c^2},
	{-cf, 0, 0, 0, 0, 0, 0, cf},
	{0, 0, 1, 0, 0, 0, 0, 0},
	{0, 0, 0, 1, 0, 0, 0, 0},
	{0, 0, 0, 0, 1, 0, 0, 0},
	{By, 0, 0, 0, 0, 1, 0, By},
	{Bz, 0, 0, 0, 0, 0, 1, Bz},
	{rho * cf^2 - BSq, 0, 0, 0, 0, -By, -Bz, rho * cf^2 - BSq}
):subst(BSq:eq(By^2+Bz^2))()
local degenYInv = degenY:inverse()
local degenYortho = expandPowers((degenYInv * degenY))()
printbr()
printbr'degen case $B \\cdot n = 0$...'
printbr(var'Y':eq(degenY))
printbr((var'Y'^-1):eq(degenYInv))
printbr((var'Y'^-1 * var'Y'):eq(degenYortho))

local Y = Matrix(
	{(rho * cf^2 - BSq) / c^2, 0, (rho * cs^2 - BSq) / c^2, 1, 0, (rho * cs^2 - BSq) / c^2, 0, (rho * cf^2 - BSq) / c^2},
	{-cf + Bx^2 / (rho * cf), 0, -cs + Bx^2 / (rho * cs), 0, 0, cs - Bx^2 / (rho * cs), 0, cf - Bx^2 / (rho * cf)},
	{Bx * By / (rho * cf), Bz * sigma, Bx * By / (rho * cs), 0, 0, -Bx * By / (rho * cs), -Bz * sigma, -Bx * By / (rho * cf)},
	{Bx * Bz / (rho * cf), -By * sigma, Bx * Bz / (rho * cs), 0, 0, -Bx * Bz / (rho * cs), By * sigma, -Bx * Bz / (rho * cf)},
	{0, 0, 0, 0, 1, 0, 0, 0},
	{By, Bz * sqrt(rho), By, 0, 0, By, Bz * sqrt(rho), By},
	{Bz, -By * sqrt(rho), Bz, 0, 0, Bz, -By * sqrt(rho), Bz},
	{rho * cf^2 - BSq, 0, rho * cs^2 - BSq, 0, 0, rho * cs^2 - BSq, 0, rho * cf^2 - BSq}
)

local YInvVars = table()
for i=1,8 do
	YInvVars[i] = table()
	for j=1,8 do
		YInvVars[i][j] = var('y^{-1}_{'..i..j..'}')
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
local YInv = Matrix(
	table.unpack(YInvVars)
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
		local lhs = Constant(i==j and 1 or 0)
		local YInvY_rhs = Constant(0)
		local YYInv_rhs = Constant(0)
		for k=1,8 do
			YInvY_rhs = YInvY_rhs + YInv[i][k] * Y[k][j]
			YYInv_rhs = YYInv_rhs + Y[i][k] * YInv[k][j]
		end
		local YInvYEqn = lhs:eq(YInvY_rhs)()
		if symmath.op.div:isa(YInvYEqn:rhs()) then YInvYEqn = (YInvYEqn * YInvYEqn:rhs()[2])() end
		YInvYEqn = YInvYEqn:subst(B_from_BSq)()
		if not YInvYEqn:isTrue() then
			YInvYEqns:insert{i,j,YInvYEqn}
		end
		local YYInvEqn = lhs:eq(YYInv_rhs)()
		if symmath.op.div:isa(YYInvEqn:rhs()) then YYInvEqn = (YYInvEqn * YYInvEqn:rhs()[2])() end
		YYInvEqn = YYInvEqn:subst(B_from_BSq)()
		if not YYInvEqn:isTrue() then
			YYInvEqns:insert{i,j,YYInvEqn}
		end
	end
end

--local Yortho = expandPowers((YInv * Y):subst(B_from_BSq))()
printbr()
printbr'full field case...'
printbr(var'Y':eq(Y))
printbr((var'Y'^-1):eq(YInv))
--printbr('$Y^{-1} \\cdot Y = $'..Yortho)

local constraints = table()
for _,eqnlist in ipairs{YInvYEqns, YYInvEqns} do
	for k=#eqnlist,1,-1 do
		local i,j,eqn = table.unpack(eqnlist[k])
		if var:isa(eqn[2]) then
			eqnlist:remove(k)
			constraints:insert(eqn:switch())
		end
	end
end
YInv = YInv:subst(constraints:unpack())
printbr'after immediate constraints:'
printbr((var'Y'^-1):eq(YInv))

-- apply constraints to remaining eqn lists
for _,eqnlist in ipairs{YInvYEqns, YYInvEqns} do
	for k=#eqnlist,1,-1 do
		eqnlist[k][3] = eqnlist[k][3]:subst(constraints:unpack())()
		if eqnlist[k][3]:isTrue() then
			eqnlist:remove(k)
		end
	end
end

-- after substituting, pick out the variables left
local YInvRemainingVars = Matrix()
for i=1,8 do
	for j=1,8 do
		if var:isa(YInv[i][j]) then
			table.insert(YInvRemainingVars, Array(YInv[i][j]))
		end
	end
end
local YInvRemainingMatrix = Matrix()
local YInvRemainingSolution = Matrix()
printbr('constraints remaining:'..(#YInvYEqns+#YYInvEqns))
printbr('variables left to solve:'..#YInvRemainingVars)
for _,info in ipairs(YInvYEqns) do
	local i,j,eqn = table.unpack(info)
	printbr('YInv row '..i..' Y col '..j..': '..eqn)
	
	local row = Array()
	table.insert(YInvRemainingMatrix, row)
	for k,vars in ipairs(YInvRemainingVars) do
		local var = vars[1]
		row[k] = eqn:rhs():polyCoeffs(var)[1] or Constant(0)
		table.insert(YInvRemainingSolution, Array(eqn:lhs()))
	end
end
for _,info in ipairs(YYInvEqns) do
	local i,j,eqn = table.unpack(info)
	printbr('Y row '..i..' YInv col '..j..': '..eqn)
	
	local row = Array()
	table.insert(YInvRemainingMatrix, row)
	for k,vars in ipairs(YInvRemainingVars) do
		local var = vars[1]
		row[k] = eqn:rhs():polyCoeffs(var)[1] or Constant(0)
		table.insert(YInvRemainingSolution, Array(eqn:lhs()))
	end
end

printbr('remaining matrix:'..YInvRemainingMatrix)
printbr('remaining vector:'..YInvRemainingVars)
printbr('remaining solution:'..YInvRemainingSolution)
printbr((YInvRemainingMatrix * YInvRemainingVars):eq(YInvRemainingSolution))
