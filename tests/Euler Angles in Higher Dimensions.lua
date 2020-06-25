#!/usr/bin/env luajit
require 'ext'
op = nil	-- make way for _G.op = symmath.op

local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Euler Angles in Higher Dimensions'}}

local r = var'r'
local phi = var'\\phi'

function Matrix:frobNorm()
	local sum = 0
	for i,v in self:iter() do
		sum = sum + v*v
	end
	return sqrt(sum)()
end

-- for dim 'dim' rotate from axis 'a' to axis 'b'
local function makeRot(dim, a, b) 
	if a == b then return Matrix.identity(dim) end
	return Matrix:lambda({dim,dim}, function(i,j) 
		if (i==a and j==a) or (i==b and j==b) then return cos(phi) end 
		if i==a and j==b then return ((-1)^math.abs(a-b) * sin(phi))() end 
		if i==b and j==a then return ((-1)^math.abs(a-b+1) * sin(phi))() end 
		if i ~= a and i ~= b and j ~= a and j ~= b and i == j then return 1 end
		return 0 
	end) 
end

for dim=2,5 do
	printbr('<h1>'..dim..'D Spherical Coordinates</h1>')

	local rotMats = table()
	for a=1,dim do
		for b=1,dim do
			rotMats[a] = rotMats[a] or table()
			rotMats[a][b] = makeRot(dim, a, b)
		end
	end

	printbr'Rotations from \\ to dimensions:'
	print'<table border="1" style="border-collapse:collapse">'
	print'<tr><th></th>'
	for b=1,dim do
		print('<th>'..b..'</th>')
	end
	print('</tr>')
	for a=1,dim do
		print('<tr><td>'..a..'</td>')
		for b=1,dim do
			print('<td>'..rotMats[a][b]..'</td>')
		end
		print('</tr>')
	end
	printbr('</table>')
	
	local coords = table{r}
	local phis = range(dim):mapi(function(i) return var('\\phi_'..(i-1)) end)
	coords:append(phis:sub(2))

	local RotFunc = class(require 'symmath.Function')
	local rotFuncs = range(dim):mapi(function(i)
		return range(dim):mapi(function(j)
			local rotFunc = class(RotFunc)
			rotFunc.name = 'R_{'..i..','..j..'}'
			rotFunc.i = i
			rotFunc.j = j
			return rotFunc
		end)
	end)

	for _,info in ipairs{
		{
			name = 'traditional',
			build = function(j, expr)
				if j == 2 then
					return rotFuncs[1][2](phis[dim]) * expr
				end
				-- TODO get trig simpliciation of sin(a+b), cos(a+b) working
				--return rotFuncs[j][1](frac(pi,2) - phis[j]) * expr
				-- until then ...
				return rotFuncs[j][1](frac(pi,2)) * rotFuncs[j][1](-phis[2+dim-j]) * expr
			end,
		},
		{
			name = 'my alternative',
			build = function(j, expr)
				local from, to = j, 1
				if j % 2 == 0 then from, to = to, from end
				return rotFuncs[from][to](phis[j]) * expr
			end,
		},
	} do
		printbr('<h3>'..info.name..'</h3>')

		local xHat =  var'\\hat{x}'
		local expr = xHat
		for j=dim,2,-1 do
			expr = info.build(j, expr)
		end

		local uVal = expr:replace(xHat, Matrix( range(dim):mapi(function(i) return i==1 and r or 0 end) ):T())
		uVal = uVal:map(function(x)
			if RotFunc.is(x) then
				local param = x[1]
				return rotMats[x.i][x.j]:replace(phi, param)
			end
		end)
		printbr(expr, '=', uVal, '=', uVal())

		local basisVars = table()
		local basis = table()
		for j=1,dim do
			local basisVar = var('\\hat{e}_{'..coords[j].name..'}')
			basisVars:insert(basisVar)
			local basisJ = uVal:diff(coords[j])()
			basis:insert(basisJ)
			printbr(basisVar:eq(
				expr:diff(coords[j])
			):eq(
				uVal:diff(coords[j])
			):eq(
				basisJ
			))
		end

		local basisLens = table()
		for j=1,dim do
			printbr(var('|'..basisVars[j].name..'|'):eq(
				basis[j]:frobNorm()
			))
		end

		local volume = Matrix(basis:mapi(function(e)
			return e:T()[1]
		end):unpack()):T()
		print('|', basisVars:mapi(tostring):concat', ', '| = ',volume)
		printbr(' = ', volume:det())
		
		printbr()
	end

	printbr()
end
