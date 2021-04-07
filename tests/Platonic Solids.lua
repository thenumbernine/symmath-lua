#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Platonic Solids'}}

-- 3-dimensions: xyz
local n = 3


-- matrix to rotate 1/sqrt(3) (1,1,1) to (1,0,0)
local M = Matrix(
	{ 1/sqrt(3), 1/sqrt(3), 1/sqrt(3) },
	{ -1/sqrt(3), (1 + sqrt(3))/(2*sqrt(3)), (1 - sqrt(3))/(2*sqrt(3)) },
	{ -1/sqrt(3), (1 - sqrt(3))/(2*sqrt(3)), (1 + sqrt(3))/(2*sqrt(3)) }
)

printbr((M * M:T())())
os.exit()

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
	-- dual of octahedron
	{
		name = 'Cube',
		
		-- TODO rotote this to [1,0,0]
		vtx1 = Matrix{sqrt(frac(1,3)), sqrt(frac(1,3)), sqrt(frac(1,3))}:T(),	-- column-matrix
		
		genxforms = {
			Matrix.rotation(frac(pi,2), {1,0,0}),
			Matrix.rotation(frac(pi,2), {0,1,0}),
			Matrix.rotation(frac(pi,2), {0,0,1}),
		},
	
		identxforms = {
			Matrix.rotation(frac(pi,2), {1,0,0}),
			Matrix.rotation(frac(pi,2), {0,1,0}),
			Matrix.rotation(frac(pi,2), {0,0,1}),
			Matrix.rotation(frac(pi,2), {-1,0,0}),
			Matrix.rotation(frac(pi,2), {0,-1,0}),
			Matrix.rotation(frac(pi,2), {0,0,-1}),
		},
	},

-- [=[
	-- dual of cube
	{
		name = 'Octahedron',
		vtx1 = Matrix{1,0,0}:T(),
		
		genxforms = {
			Matrix.rotation(frac(pi,2), {1,0,0}),
			Matrix.rotation(frac(pi,2), {0,1,0}),
			Matrix.rotation(frac(pi,2), {0,0,1}),
		},
	
		identxforms = {
			Matrix.rotation(frac(pi,2), {1,0,0}),
			Matrix.rotation(frac(pi,2), {0,1,0}),
			Matrix.rotation(frac(pi,2), {0,0,1}),
			Matrix.rotation(frac(pi,2), {-1,0,0}),
			Matrix.rotation(frac(pi,2), {0,-1,0}),
			Matrix.rotation(frac(pi,2), {0,0,-1}),
		},
	},

	{
		name = 'Tetrahedron',
		vtx1 = Matrix{1,0,0}:T(),

		-- something tells me vertex generation is going to become more complex soon 

		genxforms = {
			Matrix(
				{frac(-1,3), 0, -sqrt(frac(8,9))},
				{0, 1, 0},
				{sqrt(frac(8,9)), 0, frac(-1,3)}
			)(),
			(Matrix.rotation(frac(2*pi,3), {1,0,0}) * Matrix(
				{frac(-1,3), 0, -sqrt(frac(8,9))},
				{0, 1, 0},
				{sqrt(frac(8,9)), 0, frac(-1,3)}
			))(),
			(Matrix.rotation(frac(4*pi,3), {1,0,0}) * Matrix(
				{frac(-1,3), 0, -sqrt(frac(8,9))},
				{0, 1, 0},
				{sqrt(frac(8,9)), 0, frac(-1,3)}
			))(),
		},
		
		-- alright, we can only apply one at a time ... this is where platonic solid generation becomes tricky ...
		generateMaxDepth = 1,
		-- or another perspective is .. you can only apply a transform T_i whose axis is on an edge with the original vertex once, or three times (which is identity), but not twice ... 
		
		identxforms = {
			Matrix.rotation(frac(2*pi,3), {	1,			0, 					0 					}),
			Matrix.rotation(frac(2*pi,3), {	-frac(1,3),	0, 					sqrt(frac(8,9))		}),
			Matrix.rotation(frac(2*pi,3), {	-frac(1,3),	-sqrt(frac(2,3)), 	-sqrt(frac(2,9))	}),
			Matrix.rotation(frac(2*pi,3), {	-frac(1,3),	sqrt(frac(2,3)), 	-sqrt(frac(2,9))	}),
		},
	},

--[[
	-- dual of icosahedron
	{
		name = 'Dodecahedron',
		vtx1 = Matrix{1,0,0}:T(),
	

	},

	-- dual of dodecahedron
	{
		name = 'Icosahedron',
		vtx1 = Matrix{1,0,0}:T(),
	},
--]]
--]=]
}
for _,shape in ipairs(shapes) do
	shapes[shape.name] = shape
end

--local shape = shapes.Cube

for _,shape in ipairs(shapes) do

	printbr(shape.name..':')
	printbr()

	printbr('Initial vertex:', var'V''_1':eq(shape.vtx1))
	printbr()

	local genxforms = table(shape.genxforms)

	printbr'Transforms for vertex generation:'
	printbr()
	printbr(var'T''_i', [[$\in \{$]], genxforms:mapi(tostring):concat',', [[$\}$]])
	printbr()

	printbr'Vertexes:'
	printbr()

	local vtxs = table{shape.vtx1()}

	local function build(j, depth)
		depth = depth or 1
		if shape.generateMaxDepth and depth > shape.generateMaxDepth then return end
		local v = vtxs[j]
		for i,xform in ipairs(genxforms) do
			local xv = (xform * v)()
			if not vtxs:find(xv) then
				vtxs:insert(xv)
				local k = #vtxs
				printbr((var'T'('_'..i) * var'V'('_'..j)):eq(xv):eq(var'V'('_'..k)))
				build(k, depth + 1)
			end
		end
	end

	build(1)

	-- number of vertexes
	local nvtxs = #vtxs

	local VmatT = Matrix(vtxs:mapi(function(v) return v:T()[1] end):unpack())
	local Vmat = VmatT:T()

	printbr(var'V':eq(Vmat))
	printbr()

	printbr((var'V''^T' * var'V'):eq(Vmat:T() * Vmat):eq((Vmat:T() * Vmat)()))
	printbr()

	local identxforms = table(shape.identxforms)

	printbr'Transforms of all vertexes vs permutations of all vertexes:'
	printbr()
	printbr(var'T''_i', [[$\in \{$]], identxforms:mapi(tostring):concat',', [[$\}$]])
	printbr()

	for _,xform in ipairs(identxforms) do
		local xv = (xform * Vmat)()	
		local xvT = xv:T()

		local rx = Matrix:lambda({nvtxs, nvtxs}, function(i,j)
			return xvT[j]() == VmatT[i]() and 1 or 0 
		end)
		
		printbr((xform * var'V'):eq(xv):eq(var'V' * rx))
		printbr()

		local Vmat_rx = (Vmat * rx)()
		local diff = (xv - Vmat_rx)()
		local zeros = Matrix:zeros{n, nvtxs}
		if diff ~= zeros then
			printbr('expected', xv:eq(Vmat * rx), 'found difference', (xv - Vmat * rx)())
		end
	end

	printbr'<hr>'
end

print(export.MathJax.footer)
