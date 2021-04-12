#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Platonic Solids'}}

printbr[[
$n =$ dimension of manifold which our shape resides in.<br>
$\tilde{T}_i \in \mathbb{R}^{n \times n} =$ i'th isomorphic transform in the minimal set.<br>
$\tilde{\textbf{T}} = \{ 1 \le i \le p, \tilde{T}_i \} =$ minimum set of isomorphic transforms that can be used to recreate all isomorphic transforms.<br>
$p = |\tilde{\textbf{T}}| =$ the number of minimal isomorphic transforms.<br>
$T_i \in \mathbb{R}^{n \times n} =$ i'th isomorphic transform in the set of all unique transforms.<br>
$\textbf{T} = \{ T_i \} = \{ 1 \le k, i_1, ..., i_k \in [1,m], \tilde{T}_{i_1} \cdot ... \cdot \tilde{T}_{i_k} \} =$ set of all unique isomorphic transforms.<br>
$q = |\textbf{T}| =$ the number of unique isomorphic transforms.<br>
$v_1 \in \mathbb{R}^n =$ some arbitrary initial vertex.<br>
$\textbf{v} = \{v_i \} = \{ T_i \cdot v_1 \} =$ the set of all vertices.<br>
$m = |\textbf{v}| =$ the number of vertices.<br>
(Notice that $m \le q$, i.e. the number of vertices is $\le$ the number of unique isomorphic transforms.) <br>
$V \in \mathbb{R}^{n \times m}=$ matrix with column vectors the set of all vertices, such that $V_{ij} = (v_j)_i$.<br>
$P_i \in \mathbb{R}^{m \times m} =$ permutation transform of vertices corresponding with i'th transformation, such that $T_i V = V P_i$.<br>
<br>
]]

-- 3-dimensions: xyz
local n = 3

local phi = (sqrt(5) - 1) / 2


--[[ matrix to rotate 1/sqrt(3) (1,1,1) to (1,0,0)
-- applying this isn't as isometric as I thought it would be
-- cubeRot = Matrix.rotation(acos(1/sqrt(3)), Matrix(1,1,1):cross{1,0,0}:unit())		-- rotate from unit(1,1,1) to (1,0,0)
local cubeRot = Matrix(
	{ 1/sqrt(3), 1/sqrt(3), 1/sqrt(3) },
	{ -1/sqrt(3), (1 + sqrt(3))/(2*sqrt(3)), (1 - sqrt(3))/(2*sqrt(3)) },
	{ -1/sqrt(3), (1 - sqrt(3))/(2*sqrt(3)), (1 + sqrt(3))/(2*sqrt(3)) }
)
--]]
-- [[ use [1,1,1]/sqrt(3)
local cubeRot = Matrix.identity(3)
--]]


--[[
local dodVtx = Matrix{
	(-1 - sqrt(5)) / (2 * sqrt(3)),
	0,
	(1 - sqrt(5)) / (2 * sqrt(3))
}
local dodRot = Matrix.rotation(acos(dodVtx[1][1]), dodVtx[1]:cross{1, 0, 0}:unit())
--]]
-- [[
local dodRot = Matrix.identity(3)
--]]


--[[ produces an overly complex poly that can't simplify 
--[=[
local icoRot = Matrix.rotation(acos(0), Array(0, 1, phi):cross{1,0,0}:unit())
--]=]
local icoVtx = Matrix{0, 1, phi}
printbr(icoVtx)
local icoRot = Matrix.rotation(
	acos(icoVtx[1][1]), 
	icoVtx[1]:cross{1,0,0}:unit())
--]]
-- [[ works
local icoRot = Matrix.identity(3)
--]]


--[[
how to define the transforms?
these should generate the vertexes, right?
the vertex set should be some identity vertex times any combination of these transforms

so we should be able to define a cube by a single vertex 
v_0 = [1,1,1] 
times any combination of traversals along its edges
which for [1,1,1] would just three transforms, where the other 3 are redundant:


identity transforms:
this can be the axis from the center of object to any vertex, with rotation angle equal to the edge-vertex-edge angle
or it can be the axis from center of object to center of any face, with rotation angle equal to 2pi/n for face with n edges
or it can be the axis through any edge (?right?) with ... some other kind of rotation ...
--]]
local shapes = {
-- [=[
	-- dual of octahedron
	{
		name = 'Cube',
		
		vtx1 = (cubeRot * Matrix{ 1/sqrt(3), 1/sqrt(3), 1/sqrt(3) }:T():unit())(),
		
		xforms = {
			(cubeRot * Matrix.rotation(frac(pi,2), {1,0,0}) * cubeRot:T())(),
			(cubeRot * Matrix.rotation(frac(pi,2), {0,1,0}) * cubeRot:T())(),
			(cubeRot * Matrix.rotation(frac(pi,2), {0,0,1}) * cubeRot:T())(),
		},
	},
--]=]
-- [=[
	-- dual of cube
	{
		name = 'Octahedron',
		
		xforms = {
			Matrix.rotation(frac(pi,2), {1,0,0})(),
			Matrix.rotation(frac(pi,2), {0,1,0})(),
			Matrix.rotation(frac(pi,2), {0,0,1})(),
		},
	},
--]=]
-- [=[
	{
		name = 'Tetrahedron',

		xforms = {
			Matrix.rotation(frac(2*pi,3), {	-frac(1,3),	0, 					sqrt(frac(8,9))		})(),
			Matrix.rotation(frac(2*pi,3), {	-frac(1,3),	-sqrt(frac(2,3)), 	-sqrt(frac(2,9))	})(),
		},
	},
--]=]
-- [=[
	-- dual of icosahedron
	{
		name = 'Dodecahedron',

		vtx1 = (dodRot * Matrix{1/phi, 0, phi}:T():unit())(),

		xforms = {
			-- axis will be the center of the face adjacent to the first vertex at [1,0,0]
			(dodRot * Matrix.rotation(frac(2*pi,3), Matrix{-1/phi, 0, phi}:unit()[1] ) * dodRot:T())(),	-- correctly produces 3 vertices 
			(dodRot * Matrix.rotation(frac(2*pi,3), Matrix{0, phi, 1/phi}:unit()[1] ) * dodRot:T())(),
			(dodRot * Matrix.rotation(frac(2*pi,3), Matrix{1,1,1}:unit()[1] ) * dodRot:T())(),
		},
	},
--]=]
-- [=[
	-- dual of dodecahedron
	{
		name = 'Icosahedron',
	
		--vtx1 = (icoRot * Matrix{ 0, 1, phi }:T():unit())(),
		vtx1 = (icoRot * Matrix{ 0, 1, phi }:T())(),		-- don't unit.

		xforms = {
			(icoRot * Matrix.rotation(frac(2*pi,5), Matrix{0, -1, phi}:unit()[1] ) * icoRot:T())(),
			(icoRot * Matrix.rotation(frac(2*pi,5), Matrix{1, phi, 0}:unit()[1] ) * icoRot:T())(),
			(icoRot * Matrix.rotation(frac(2*pi,5), Matrix{-1, phi, 0}:unit()[1] ) * icoRot:T())(),
		},
	},
--]=]
}

for _,shape in ipairs(shapes) do
	shapes[shape.name] = shape
end



local MathJax = symmath.export.MathJax
MathJax.header.pathToTryToFindMathJax = '..'
symmath.tostring = MathJax

os.mkdir'output/Platonic Solids'
for _,shape in ipairs(shapes) do
	printbr('<a href="Platonic Solids/'..shape.name..'.html">'..shape.name..'</a>')
end
printbr()

for _,shape in ipairs(shapes) do

	io.stderr:write(shape.name,'\n')
	io.stderr:flush()

	MathJax.header.title = shape.name

	local f = assert(io.open('output/Platonic Solids/'..shape.name..'.html', 'w'))
	local function write(...)
		return f:write(...)
	end
	local function print(...)
		write(table{...}:mapi(tostring):concat'\t'..'\n')
	end
	local function printbr(...)
		print(...)
		print'<br>'
	end
	
	print(MathJax.header)

--print('<a name="'..shape.name..'">')
	print('<h3>'..shape.name..'</h3>')



	local vtx1 = shape.vtx1 or Matrix{1,0,0}:T()

	printbr('Initial vertex:', var'v''_1':eq(vtx1))
	printbr()

	local xforms = table(shape.xforms)
	xforms:insert(1, Matrix.identity(3))

	printbr'Transforms for vertex generation:'
	printbr()
	printbr(var'\\tilde{T}''_i', [[$\in \{$]], xforms:mapi(tostring):concat',', [[$\}$]])
	printbr()

	printbr'Vertexes:'
	printbr()

	local vtxs = table{vtx1()}

	local function buildvtxs(j, depth)
		depth = depth or 1
		local v = vtxs[j]
		for i,xform in ipairs(xforms) do
			local xv = (xform * v)()
			local k = vtxs:find(xv)
			if not k then
				vtxs:insert(xv)
				k = #vtxs
				printbr((var'T'('_'..i) * var'V'('_'..j)):eq(xv):eq(var'V'('_'..k)))
				buildvtxs(k, depth + 1)
			else
--				printbr((var'T'('_'..i) * var'V'('_'..j)):eq(xv):eq(var'V'('_'..k)))
			end
		end
	end
	buildvtxs(1)
	printbr()

	-- number of vertexes
	local nvtxs = #vtxs

	local allxforms = table(xforms)
-- [[
	printbr'All Transforms:'
	printbr()

	local function buildxforms(j, depth)
		depth = depth or 1
		local M = allxforms[j]
		for i,xform in ipairs(xforms) do
			local xM = (xform * M)()
			local k = allxforms:find(xM)
			if not k then
				allxforms:insert(xM)
				k = #allxforms
				printbr((var'T'('_'..i) * var'T'('_'..j)):eq(xM):eq(var'T'('_'..k)))
				buildxforms(k, depth + 1)
			else
--				printbr((var'T'('_'..i) * var'V'('_'..j)):eq(xv):eq(var'V'('_'..k)))
			end
		end
	end
	for i=1,#xforms do
		buildxforms(i)
	end
	printbr()
--]]

	local VmatT = Matrix(vtxs:mapi(function(v) return v:T()[1] end):unpack())
	local Vmat = VmatT:T()

	printbr'Vertexes as column vectors:'
	printbr()

	printbr(var'V':eq(Vmat))
	printbr()

	printbr'Vertex inner products:'
	printbr()

	printbr((var'V''^T' * var'V'):eq(Vmat:T() * Vmat):eq((Vmat:T() * Vmat)()))
	printbr()

	printbr'Transforms of all vertexes vs permutations of all vertexes:'
	printbr()
	printbr(var'T''_i', [[$\in \{$]], allxforms:mapi(tostring):concat',', [[$\}$]])
	printbr()

	for i,xform in ipairs(allxforms) do
		local xv = (xform * Vmat)()	
		local xvT = xv:T()

		local rx = Matrix:lambda({nvtxs, nvtxs}, function(i,j)
			return xvT[j]() == VmatT[i]() and 1 or 0 
		end)
		
		printbr((var'T'('_'..i) * var'V'):eq(xv):eq(var'V' * rx))
		printbr()

		local Vmat_rx = (Vmat * rx)()
		local diff = (xv - Vmat_rx)()
		local zeros = Matrix:zeros{n, nvtxs}
		if diff ~= zeros then
			printbr('expected', xv:eq(Vmat * rx), 'found difference', (xv - Vmat * rx)())
		end
	end

	for j=2,#allxforms do
		for i=1,j-1 do
			if (allxforms[i] - allxforms[j])() == Matrix:zeros{3,3} then
				printbr(var'T'('_'..i), 'should equal', var'T'('_'..j), ':',
					allxforms[i], ',', allxforms[j])
			end
		end
	end

	print(MathJax.footer)
	f:close()
end

print(export.MathJax.footer)
