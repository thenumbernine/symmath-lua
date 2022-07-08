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

--[[
ok here's another thought ...
rotation from a to b, assuming a and b are orthonormal:

R v
	= v - a (v.a) - b (v.b)
	+ (a (v.a) + b (v.b)) cos(θ)
	+ (b (v.a) - a (v.b)) sin(θ)
	
	= v - a (v.a) - b (v.b)
	+ (a (v.a) + b (v.b)) cos(θ)
	+ (b (v.a) - a (v.b)) sin(θ)
	
	= (I + (cos(θ)-1) aa' - sin(θ) ab' + sin(θ) ba' + (cos(θ)-1) bb') v
	= (I + (cos(θ)-1) (aa' + bb') + sin(θ) (ba' - ab')) v
--]]
local function rotfromto(from, to, theta)
	from = from:unit()
	local unitto = to:unit()
	to = (Matrix.projection(from:T()[1]) * unitto)():unit()
	local costh, sinth
	if not theta then
		costh = (from:T() * to)()[1][1]
		sinth = sqrt(1 - costh * costh)()
	else
		costh = cos(theta)
		sinth = sin(theta)
	end
	return (
		Matrix.identity(#from)
		+ (costh - 1) * (from * from:T() + to * to:T())
		+ sinth * (to * from:T() - from * to:T())
	)()
end

--[[
can i write a function that just takes n vertexes for n dimensions
and creates a rotation from it?
no angle required?
such that if i provide an equilateral triangle vertexes then it'll give back an isomorphic rotation?
R A = R [a1 a2 a3] = [a2 a3 a1] = [a1 a2 a3] P = A P
so R = A P A^-1
--]]


-- convert a quaternion q = a + bi + cj + dk to a matrix M such that q * q2 (using quat mul) = M * q2 (using matrix mul)
-- the nice thing about the resulting matrix is that M * M' = I * |q|^2 , so if q is normalized then we get identity
-- so that means M is a 4D rotation matrix, and it also means a 4D rotation from any basis element through M will give us some kind of permutation of the vertex {a,b,c,d}
local function toQuatMat(a,b,c,d)
	return Matrix(
		{a, -b, -c, -d},
		{b, a, -d, c},
		{c, d, a, -b},
		{d, -c, b, a}
	)()
end

local phi = (sqrt(5) + 1) / 2
local phiminus = (sqrt(5) - 1) / 2	-- notice 1/phiminus = phi
-- two roots of Fibonacci series recurrence relation are phi and -phiminus, i.e. (1 ± √5)/2

--[=[
--[[
for a 3D platonic solid, if you know the vertices, you can make a rotation
from (proj a) * b to (proj a) * c
--]]
printbr(rotfromto(
	(Matrix.projection{1,0,0} * Matrix{-frac(1,3), sqrt(frac(2,3)), -frac(sqrt(2),3)}:T())(),
	(Matrix.projection{1,0,0} * Matrix{-frac(1,3), 0, frac(sqrt(8),3)}:T())()
	frac(2*pi,3),
))
os.exit()
--]=]
--[[	-- rotate from perm of (0, 0, 0, ±1) to perm of (±1/2, ±1/2, ±1/2, ±1/2)
printbr(rotfromto(
	Matrix{1,0,0,0}:T(),
	Matrix{frac(1,2),frac(1,2),frac(1,2),frac(1,2)}:T(),
	frac(2*pi,3)
))
os.exit()
--]]
--[[ how well does this work?
local theta = var'\\theta'
printbr((rotfromto(
	Matrix{cos(theta), sin(theta), 0, 0}:T(),
	Matrix{-sin(theta), cos(theta), 0, 0}:T(),
	theta
)() * rotfromto(
	Matrix{0, 0, cos(theta), sin(theta)}:T(),
	Matrix{0, 0, -sin(theta), cos(theta)}:T(),
	theta
)())())
os.exit()
--]]
--[[	-- rotate from perm of (0, 0, 0, ±1) to even perm of (±φ/2, ±1/2, ±1/(2φ), 0)
do
	printbr(rotfromto(
		Matrix{frac(phi,2),frac(1,2),frac(1,2*phi),0}:T(),
		Matrix{1,0,0,0}:T(),
		pi
	))
	os.exit()
end
--]]
--[[
do
	local a = {1,0,0,0}
	--local b = {0,1,0,0}
	local c = {0,0,1,0}
	--local d = {0,0,0,1}
	local b = {frac(1,2), frac(1,2), frac(1,2), frac(1,2)}
	local d = {phi/2, frac(1,2), 1/(2*phi), 0}
	printbr(rotfromto(
		(Matrix.projection(d) * Matrix.projection( (Matrix.projection(d) * Matrix(c):T())():T()[1] ) * Matrix(a):T())(),
		(Matrix.projection(d) * Matrix.projection( (Matrix.projection(d) * Matrix(c):T())():T()[1] ) * Matrix(b):T())(),
		frac(2*pi,5)
	))
end
os.exit()
--]]

-- [[
local tetRot = Matrix.identity(3)
--]]

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


-- [[ TODO getting simplification loops.
local dodVtx = Matrix{
	(-1 - sqrt(5)) / (2 * sqrt(3)),
	0,
	(1 - sqrt(5)) / (2 * sqrt(3))
}
local dodRot = Matrix.rotation(acos(dodVtx[1][1]), dodVtx[1]:cross{1, 0, 0}:unit())
--]]
--[[ TODO hmm getting bad values in the 'expected' part
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
or it can be the axis from center of object to center of any face, with rotation angle equal to 2π/n for face with n edges
or it can be the axis through any edge (?right?) with ... some other kind of rotation ...
--]]
local shapes = {
--[=[
	{
		name = 'Tetrahedron',
		dual = 'Tetrahedron',
		vtx1 = (tetRot * Matrix{0, 0, 1}:T())(),
		
		dim = 3,
		xforms = (function()
			local a = {-sqrt(frac(2,3)), -sqrt(2)/3, -frac(1,3)}
			local b = {sqrt(frac(2,3)), -sqrt(2)/3, -frac(1,3)}
			local c = {0, sqrt(8)/3, -frac(1,3)}
			local d = {0, 0, 1}
			
			return table{
				
				(tetRot *
					--Matrix.rotation(frac(2*pi,3), {	-frac(1,3),	0, 					sqrt(frac(8,9))		})
					rotfromto(
						(Matrix.projection(c) * Matrix(a):T())(),
						(Matrix.projection(c) * Matrix(b):T())(),
						frac(2*pi,3)
					)
					* tetRot:T())(),
				
				(tetRot *
					--Matrix.rotation(frac(2*pi,3), {	-frac(1,3),	-sqrt(frac(2,3)), 	-sqrt(frac(2,9))	})
					rotfromto(
						(Matrix.projection(d) * Matrix(a):T())(),
						(Matrix.projection(d) * Matrix(b):T())(),
						frac(2*pi,3)
					)
					* tetRot:T())(),
			}
		end)(),
	},
--]=]
--[=[
	{
		name = 'Cube',
		dual = 'Octahedron',
		dim = 3,
		
		--vtx1 = (cubeRot * Matrix{ 1/sqrt(3), 1/sqrt(3), 1/sqrt(3) }:T())(),
		vtx1 = (cubeRot * Matrix{ 1, 1, 1 }:T())(),
		
		xforms = {
			(cubeRot * Matrix.rotation(frac(pi,2), {1,0,0}) * cubeRot:T())(),
			(cubeRot * Matrix.rotation(frac(pi,2), {0,1,0}) * cubeRot:T())(),
			--(cubeRot * Matrix.rotation(frac(pi,2), {0,0,1}) * cubeRot:T())(),	-- z = x*y
			
			--(cubeRot * Matrix.diagonal(-1, 1, 1) * cubeRot:T())(),	reflection?
		},
	},
--]=]
--[=[
	{
		name = 'Octahedron',
		dual = 'Cube',
		dim = 3,
		
		xforms = {
			Matrix.rotation(frac(pi,2), {1,0,0})(),
			Matrix.rotation(frac(pi,2), {0,1,0})(),
			--Matrix.rotation(frac(pi,2), {0,0,1})(),	-- z = x*y
		},
	},
--]=]
--[=[
	{
		name = 'Dodecahedron',
		dual = 'Icosahedron',
		dim = 3,

		--[==[ using dodRot ... dodRot options are causing either errors or simplification loops ... and the transform table doesn't match up with the dual Icosahedron
		--vtx1 = (dodRot * Matrix{1/phiminus, 0, phiminus}:T():unit())(),
		vtx1 = (dodRot * Matrix{1/phiminus, 0, phiminus}:T())(),

		xforms = {
			-- axis will be the center of the face adjacent to the first vertex at [1,0,0]
			(dodRot * Matrix.rotation(frac(2*pi,3), Matrix{-1/phiminus, 0, phiminus}:unit()[1] ) * dodRot:T())(),	-- correctly produces 3 vertices
			(dodRot * Matrix.rotation(frac(2*pi,3), Matrix{0, phiminus, 1/phiminus}:unit()[1] ) * dodRot:T())(),	-- the first 2 transforms will produces 12 vertices and 12 transforms
			(dodRot * Matrix.rotation(frac(2*pi,3), Matrix{1,1,1}:unit()[1] ) * dodRot:T())(),		-- all 3 transforms produces all 20 vertices and 60 transforms
		},
		--]==]
		-- [==[ just use Icosahedron's transforms.  if the two are dual then they should have matching transform group.
		vtx1 = Matrix{
			((sqrt(5) - 1) / 2 + 2) / 3,	-- (3 + sqrt(5)) / 6
			0,
			-frac(1,3)
		}:T(),

		xforms = {
			(icoRot * Matrix.rotation(frac(2*pi,5), Matrix{0, -1, phiminus}:unit()[1] ) * icoRot:T())(),
			(icoRot * Matrix.rotation(frac(2*pi,5), Matrix{1, phiminus, 0}:unit()[1] ) * icoRot:T())(),
			(icoRot * Matrix.rotation(frac(2*pi,5), Matrix{-1, phiminus, 0}:unit()[1] ) * icoRot:T())(),
		},
		--]==]
	},
--]=]
--[=[
	{
		name = 'Icosahedron',
		dual = 'Dodecahedron',
		dim = 3,
	
		--vtx1 = (icoRot * Matrix{ 0, 1, phiminus }:T():unit())(),
		vtx1 = (icoRot * Matrix{ 0, 1, phiminus }:T())(),		-- don't unit.

		xforms = {
			(icoRot * Matrix.rotation(frac(2*pi,5), Matrix{0, -1, phiminus}:unit()[1] ) * icoRot:T())(),
			(icoRot * Matrix.rotation(frac(2*pi,5), Matrix{1, phiminus, 0}:unit()[1] ) * icoRot:T())(),
			(icoRot * Matrix.rotation(frac(2*pi,5), Matrix{-1, phiminus, 0}:unit()[1] ) * icoRot:T())(),
		},
	},
--]=]
--[=[
	{
		name = '5-cell',
		dual = '5-cell',
		dim = 4,
		
		vtx1 = Matrix{frac(sqrt(15),4), 0, 0, -frac(1,4)}:T(),
		--vtx1 = Matrix{0, 0, 0, 1}:T(),

		-- interesting that these aren't quaternion mats (rotations that just permute vertexes), they're 4D rots from two quat mats multiplied together
		xforms = (function()
			local a = {sqrt(15)/4, 0, 0, -frac(1,4)}
			local b = {-sqrt(frac(5,3))/4, 0, sqrt(frac(5,6)), -frac(1,4)}
			local c = {-sqrt(frac(5,3))/4, sqrt(frac(5,2))/2, -sqrt(frac(5,24)), -frac(1,4)}
			local d = {0,0,0,1}
			--local e = {-sqrt(frac(5,3))/4, -sqrt(frac(5,2))/2, -sqrt(frac(5,24)), -frac(1,4)}		-- not used, in the cd rotation plane anyways
			return table{
				-- generate a tetrahedron:
				rotfromto(
					(Matrix.projection(d) * Matrix.projection( (Matrix.projection(d) * Matrix(c):T())():T()[1] ) * Matrix(a):T())(),
					(Matrix.projection(d) * Matrix.projection( (Matrix.projection(d) * Matrix(c):T())():T()[1] ) * Matrix(b):T())(),
					frac(2*pi,3)
				),
				rotfromto(
					(Matrix.projection(d) * Matrix.projection( (Matrix.projection(d) * Matrix(a):T())():T()[1] ) * Matrix(c):T())(),
					(Matrix.projection(d) * Matrix.projection( (Matrix.projection(d) * Matrix(a):T())():T()[1] ) * Matrix(b):T())(),
					frac(2*pi,3)
				),
				-- generate the entire 5-cell
				rotfromto(
					(Matrix.projection(a) * Matrix.projection( (Matrix.projection(a) * Matrix(b):T())():T()[1] ) * Matrix(c):T())(),
					(Matrix.projection(a) * Matrix.projection( (Matrix.projection(a) * Matrix(b):T())():T()[1] ) * Matrix(d):T())(),
					frac(2*pi,3)
				),
			}
		end)(),
	}
--]=]
--[=[
	{
		name = '8-cell',	--aka hypercube
		dual = '16-cell',
		dim = 4,
		
		--vtx1 = Matrix{1/sqrt(4), 1/sqrt(4), 1/sqrt(4), 1/sqrt(4)}:T(),
		--vtx1 = Matrix{frac(1,2), frac(1,2), frac(1,2), frac(1,2)}:T(),
		vtx1 = Matrix{1, 1, 1, 1}:T(),

		xforms = {
			Matrix(	-- xy
				{0,-1,0,0},
				{1,0,0,0},
				{0,0,1,0},
				{0,0,0,1}
			)(),
			Matrix(	-- xz
				{0,0,1,0},
				{0,1,0,0},
				{-1,0,0,0},
				{0,0,0,1}
			)(),
			Matrix(	-- xw
				{0,0,0,-1},
				{0,1,0,0},
				{0,0,1,0},
				{1,0,0,0}
			)(),
		},
	},
--]=]
--[=[
	{
		name = '16-cell',
		dual = '8-cell',
		dim = 4,
		
		vtx1 = Matrix{1, 0, 0, 0}:T(),

		xforms = {
			Matrix(
				{0,-1,0,0},
				{1,0,0,0},
				{0,0,1,0},
				{0,0,0,1}
			)(),
			Matrix(
				{0,0,1,0},
				{0,1,0,0},
				{-1,0,0,0},
				{0,0,0,1}
			)(),
			Matrix(
				{0,0,0,-1},
				{0,1,0,0},
				{0,0,1,0},
				{1,0,0,0}
			)(),
		},
	},
--]=]
--[=[
	{
		name = '24-cell',
		dual = '24-cell',
		dim = 4,
		
		--vtx1 = Matrix{1/sqrt(2),1/sqrt(2),0,0}:T(),
		vtx1 = Matrix{1,1,0,0}:T(),

		xforms = {
			Matrix(
				{0,-1,0,0},
				{1,0,0,0},
				{0,0,1,0},
				{0,0,0,1}
			)(),
			Matrix(
				{0,0,1,0},
				{0,1,0,0},
				{-1,0,0,0},
				{0,0,0,1}
			)(),
			Matrix(
				{0,0,0,-1},
				{0,1,0,0},
				{0,0,1,0},
				{1,0,0,0}
			)(),
		},
	},
--]=]
--[=[ TODO FIXME
	{
		name = '120-cell',
		dual = '600-cell',
		dim = 4,
		vtx1 = Matrix{0,0,2,2}:T(),
		xforms = {
			Matrix(
				{0,-1,0,0},
				{1,0,0,0},
				{0,0,1,0},
				{0,0,0,1}
			)(),
			Matrix(
				{0,0,1,0},
				{0,1,0,0},
				{-1,0,0,0},
				{0,0,0,1}
			)(),
			Matrix(
				{0,0,0,-1},
				{0,1,0,0},
				{0,0,1,0},
				{1,0,0,0}
			)(),
			
			-- rotate from {0,0,2,2} to {1,1,1,sqrt(5)}
			rotfromto(
				Matrix{0,0,2,2}:T(),
				Matrix{1,1,1,sqrt(5)}:T(),
				frac(36 * pi, 180)
			)(),
			-- rotate to {1/φ^2, φ, φ, φ},
			-- rotate to {φ^2, 1/φ, 1/φ, 1/φ},
			
			-- even-permutations of...
			-- {0, 1/φ^2, 1, φ^2}
			-- {0, 1/φ, φ, √5},
			-- {1/φ, 1, φ, 2}
		
			-- for φ = (1 + √5)/2
		},
	},
--]=]
-- [=[ 
	{
		name = '600-cell',
		dual = '120-cell',
		dim = 4,
		vtx1 = Matrix{0,0,0,1}:T(),
		
		-- TODO rearrange prioritize whole numbers first, then fractions, then sqrts last, and try to get rid of the +1 transform (maybe get rid of the diag(-1,-1,1,1) too)
		xforms = table{
			-- these will reproduce the 8 vertexes of permutations of (0, 0, 0, ±1)
			-- x<->y rotation
			--[[
			Matrix(
				{0,-1,0,0},
				{1,0,0,0},
				{0,0,1,0},
				{0,0,0,1}
			)(),
			-- x<->z rotation
			Matrix(
				{0,0,1,0},
				{0,1,0,0},
				{-1,0,0,0},
				{0,0,0,1}
			)(),
			-- x<->w rotation
			Matrix(
				{0,0,0,-1},
				{0,1,0,0},
				{0,0,1,0},
				{1,0,0,0}
			)(),
			--]]
			--toQuatMat(1, 0, 0, 0),	--redundant? tho this produces 361 xforms instead of 360, so one isn't simplifying correctly...
			--toQuatMat(0, 1, 0, 0),	-- redundant
			-- [[ 16 vertexes permutations of (±1/2, ±1/2, ±1/2, ±1/2)
			rotfromto(
				Matrix{1,0,0,0}:T(),
				Matrix{frac(1,2),frac(1,2),frac(1,2),frac(1,2)}:T(),
				frac(2*pi,3)
			),
			--]]
			--[[ same but using a single quat-mat rot (instead of the general 4D rots which are double-quat-mat-rots)
			toQuatMat(frac(1,2), frac(1,2), frac(1,2), frac(1,2)),
			--]]
			-- 96 vertexes even permutations of (±φ/2, ±1/2, ±1/(2φ), 0)
			--[[
			rotfromto(
				Matrix{frac(phi,2),0,frac(1,2),frac(1,2*phi)}:T(),
				Matrix{0,1,0,0}:T()
			)
			--]]
			--[[
			(function()
				local a = {1,0,0,0}
				--local c = {0,1,0,0}
				local c = {0,0,1,0}
				--local d = {0,0,0,1}
				local b = {frac(1,2), frac(1,2), frac(1,2), frac(1,2)}
				local d = {phi/2, frac(1,2), phiminus/2, 0}
				return rotfromto(
					(Matrix.projection(d) * Matrix.projection( (Matrix.projection(d) * Matrix(c):T())():T()[1] ) * Matrix(a):T())(),
					(Matrix.projection(d) * Matrix.projection( (Matrix.projection(d) * Matrix(c):T())():T()[1] ) * Matrix(b):T())(),
					frac(pi,5)
				)
			end)(),
			--]]
			-- [[ once again, if all we're doing is permuting vertexes then why not use this?
			-- i guess if it's only the even permutations then maybe i'll need some extra spin on this?
			-- alone it builds just 10 vertexes
			-- with any cardinal xy xz xw rotation it goes on forever
			toQuatMat(phi/2, frac(1,2), phiminus/2, 0),
			--]]
			-- how about double-reflections?
			Matrix.diagonal(-1,-1,1,1),	-- goes from 360 to 1440
			--Matrix.diagonal(1,-1,-1,1),	-- nope
			--Matrix.diagonal(-1,1,1,-1),	-- nope
			
			-- 72' rotation along xy i.e. perpendicular to {0,0,0,1} ... might need another yz rotation to fix it
			--[[
			(Matrix(
				{cos(2*pi/5), -sin(2*pi/5), 0, 0},
				{sin(2*pi/5), cos(2*pi/5), 0, 0},
				{0, 0, 1, 0},
				{0, 0, 0, 1}
			) * Matrix(
				{1, 0, 0, 0},
				{0, cos(2*pi/5), -sin(2*pi/5), 0},
				{0, sin(2*pi/5), cos(2*pi/5), 0},
				{0, 0, 0, 1}
			))(),
			--]]
			-- [[
			--[==[
			ok if Tetrahedron is a permutation of its vertexes ...
			then all I have to do is find one tetrahedron of the 600-cell and do an equivalent permutation on its vertexes
			(assuming the remaining transforms are all intra-cell and not inter-cell)
			T = V P V^-1 for column-vertexes V and permutation P
			tetrahedron has the following permutations:
			(where indexes are the order after transformation)
			1234
			1342
			1423
			2143
			2314
			2431
			3124
			3241
			3412
			4132
			4213
			4321
			... basically, all even permutations
			
			ok i can also do icosahedron (and is more likely since i'm looking for 5x more transforms
			and this is all vertexes within 36 degrees of some vertex
			[cos(36'), sin(36')] = [(1 + √5)/4, √(10 - 2√5)/4]
			
			so look at all vertexes of an inner product of (1+√5)/2 = φ/2 from vtx1 = [0,0,0,1]
			and there are 12 of them, looks good so far, that's an icosahedron with 20 sides
			now to collect them ...

			--]==]
			--]]
			-- from taking the icosahedron T_2 permutation and applying it between the vertexes of the 600-cell icosahedron the lie at cos(theta)=phi/2 angle from the vtx1 = e_4
			( Matrix( { sqrt(5)*(3-sqrt(5))/4, -sqrt(5)/2, -sqrt(5)*(sqrt(5)-1)/4, 0 }, {sqrt(5)/2, sqrt(5)*(sqrt(5)-1)/4, sqrt(5)*(sqrt(5)-3)/4, 0}, {sqrt(5)*(sqrt(5)-1)/4, sqrt(5)*(sqrt(5)-3)/4, sqrt(5)/2, 0}, {0, 0, 0, 3*(3+sqrt(5))/2})() * Matrix.diagonal((1+sqrt(5))/(2*sqrt(5)), (1+sqrt(5))/(2*sqrt(5)), (1+sqrt(5))/(2*sqrt(5)), (3-sqrt(5))/6) )(),
		}
		--[[ how about using Tetrahedron isometries?
		:append((function()
			-- these are the vertexes of the tetrahedron ...
			local a = {0,0,0,1}
			local b = {0,0,frac(1,2),frac(1,2)}
			local c = {0,0,1,0}
			local d = {frac(1,2),0,phiminus/2,phi/2}

			local ca = (Matrix.projection(c) * Matrix(a):T())()
			local cb = (Matrix.projection(c) * Matrix(b):T())()
			
			return table{
				
				rotfromto(ca, cb, frac(2*pi,5))(),
			
				--[==[
				(
					--Matrix.rotation(frac(2*pi,3), {	-frac(1,3),	-sqrt(frac(2,3)), 	-sqrt(frac(2,9))	})
					rotfromto(
						(Matrix.projection(d) * Matrix(a):T())(),
						(Matrix.projection(d) * Matrix(b):T())(),
						frac(2*pi,5)
					)
				)(),
				--]==]
			}
		end)())
		--]]
		,
	},
--]=]

-- TODO 5D 5-simplex self-dual
-- TODO 5D 5-cube dual to 5-orthoplex
-- TODO 5D 5-orthoplex dual to 5-cube

-- TODO 6D 6-simplex
-- TODO 6D 6-orthoplex
-- TODO 6D 6-cube

-- TODO 7D 7-simplex self-dual
-- TODO 7D 7-cube dual to 7-orthoplex
-- TODO 7D 7-orthoplex dual to 7-cube

-- TODO 8D 8-simplex self-dual
-- TODO 8D 8-cube dual to 8-orthoplex
-- TODO 8D 8-orthoplex dual to 8-cube

-- ...

-- kD k-simplex self-dual with k+1 vertexes
-- kD k-cube dual to k-orthoplex with 2^k vertexes
-- kD k-orthoplex dual to k-cube with 2*k vertexes
}

for _,shape in ipairs(shapes) do
	shapes[shape.name] = shape
end



local MathJax = symmath.export.MathJax
MathJax.header.pathToTryToFindMathJax = '..'
symmath.tostring = MathJax

os.mkdir'output/Platonic Solids'
for _,shape in ipairs(shapes) do
	printbr('<a href="Platonic Solids/'..shape.name..'.html">'..shape.name..'</a> ('..shape.dim..' dim)'
		..(shape.dual and (', dual to '..shape.dual) or ''))
end
printbr()

local cache = {}
local cacheFilename = 'Platonic Solids - cache.lua'
if os.fileexists(cacheFilename) then
	cache = load('return '..io.readfile(cacheFilename), nil, nil, env)()
end

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

	print[[
<style>
table {
	border : 1px solid black;
	border-collapse : collapse;
}
table td {
	border : 1px solid black;
}
</style>
]]

	local shapeCache = cache[shape.name]
	if not shapeCache then
		shapeCache = {}
		cache[shape.name] = shapeCache
	end

--print('<a name="'..shape.name..'">')
	print('<h3>'..shape.name..'</h3>')

	local n = shape.dim
	shapeCache.n = shape.dim

	local vtx1 = shape.vtx1 or Matrix:lambda({n,1}, function(i,j) return i==1 and 1 or 0 end)
	shapeCache.vtx1 = vtx1

	printbr('Initial vertex:', var'v''_1':eq(vtx1))
	printbr()

	local xforms = table(shape.xforms)
	xforms:insert(1, Matrix.identity(n))
	shapeCache.xforms = xforms
	
	printbr'Transforms for vertex generation:'
	printbr()
	printbr(var'\\tilde{T}''_i', [[$\in \{$]], xforms:mapi(tostring):concat',', [[$\}$]])
	printbr()

	-- verify the matrices are in fact rotations ... tho i think anything above is gonna be
	-- the challenge is making it a rotation that doesn't go outside the group space of the vertexes
	for _,xform in ipairs(xforms) do
		local I = Matrix.identity(n)
		local cmp = (xform * xform:T())()
		if cmp ~= I then
			printbr('expected', (xform * xform:T()):eq(I), ' but found', cmp)
		end
	end

	printbr'Vertexes:'
	printbr()

	local vtxs = table{vtx1()}
	shapeCache.vtxs = vtxs
			
	local zerovec = Matrix:zeros{n, 1}
	local vtx1norm = (vtx1:T() * vtx1)()[1][1]

	-- so far these don't go so deep that they stack-overflow
	local function buildvtxs(j, depth)
		depth = depth or 1
		local v = vtxs[j]
--local vnorm = (v:T() * v)()[1][1]
--if Constant.isValue(vnorm, 0) then printbr("ERROR norm is zero for "..v) end
--assert(Matrix(v:dim()) == Matrix{4,1})
		for i,xform in ipairs(xforms) do
			local xv = (xform * v)()
--local xvnorm = (xv:T() * xv)()[1][1]
--assert(Matrix(xv:dim()) == Matrix{4,1})
--if not Constant.isValue((xvnorm - vtx1norm)(), 0) then
--	printbr("ERROR - norms don't match.  was "..vtx1norm.." but now is "..xvnorm)
--end
			-- [[ can 'find' work?  can equality work?
			local k = vtxs:find(xv)
			--]]
			--[[ or should i try subtracting?  does that help?
			local k = vtxs:find(nil, function(xv2)
				return (xv - xv2)() == zerovec
			end)
			--]]
			if not k then
				vtxs:insert(xv)
				k = #vtxs
				printbr((var'T'('_'..i) * var'V'('_'..j)):eq(xv):eq(var'V'('_'..k)))
				io.stderr:write('T_',i,' * V_',j,' = V_',k,'\n')
				io.stderr:flush()
				buildvtxs(k, depth + 1)
			else
--				printbr((var'T'('_'..i) * var'V'('_'..j)):eq(xv):eq(var'V'('_'..k)))
			end
		end
	end
	buildvtxs(1)
	io.stderr:write('done finding vertexes\n')
	io.stderr:flush()
	printbr()
	f:flush()

	local allxforms = table(xforms)
	shapeCache.allxforms = allxforms
-- [[
	printbr'All Transforms:'
	printbr()

--[=[ ok this is getting stack overflow ...
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
				io.stderr:write('T_',i,' * T_',j,' = T_',k,'\n')
				io.stderr:flush()
				buildxforms(k, depth + 1)
			else
--				printbr((var'T'('_'..i) * var'V'('_'..j)):eq(xv):eq(var'V'('_'..k)))
			end
		end
	end
	for i=1,#xforms do
		buildxforms(i)
	end
--]=]
-- [=[ so i'm rewriting it as a queue
	do
		local xformstack = range(#xforms)
		while #xformstack > 0 do
			local j = xformstack:remove()
			local M = allxforms[j]
			for i,xform in ipairs(xforms) do
				local xM = (xform * M)()
				local k = allxforms:find(xM)
				if not k then
					allxforms:insert(xM)
					k = #allxforms
					printbr((var'T'('_'..i) * var'T'('_'..j)):eq(xM):eq(var'T'('_'..k)))
					io.stderr:write('T_',i,' * T_',j,' = T_',k,'\n')
					io.stderr:flush()
					xformstack:insert(k)
					--buildxforms(k, depth + 1)
				else
	--				printbr((var'T'('_'..i) * var'V'('_'..j)):eq(xv):eq(var'V'('_'..k)))
				end
			end
		end
	end
--]=]
	printbr()
	io.stderr:write('done finding transforms\n')
	io.stderr:flush()
--]]

--[[ debugging helping me
	do
		--[=[
		here's the vertex indexes of the 
		ok I have no guarantee that the order of my vertexes is matching
		V600_5   = [-(sqrt(5)-1)/4, 1/2, 0, phi/2]
		V600_12  = [(sqrt(5)-1)/4, 1/2, 0, phi/2]
		V600_45  = [0, -(sqrt(5)-1)/4, 1/2, phi/2]
		V600_46  = [0, (sqrt(5)-1)/4, 1/2, phi/2]
		V600_55  = [-(sqrt(5)-1)/4, -1/2, 0, phi/2]
		V600_57  = [(sqrt(5)-1)/4, -1/2, 0, phi/2]
		V600_58  = [1/2, 0, -(sqrt(5)-1)/4, phi/2]
		V600_59  = [-1/2, 0, -(sqrt(5)-1)/4, phi/2]
		V600_66  = [1/2, 0, (sqrt(5)-1)/4, phi/2]
		V600_68  = [-1/2, 0, (sqrt(5)-1)/4, phi/2]
		V600_113 = [0, (sqrt(5)-1)/4, -1/2, phi/2]
		V600_114 = [0, -(sqrt(5)-1)/4, -1/2, phi/2]
		so now I have to match this to the original icosahedron order, in order for its permutation matrix to apply equivalently:
		here I'm swapping y and z components and dividing Vico's coordinates by 2 to get them to match
		Vico_1  = [0, 1, (sqrt(5)-1)/2]   :: V600_46 
		Vico_2  = [-1, (sqrt(5)-1)/2, 0]  :: V600_68
		Vico_3  = [-(sqrt(5)-1)/2, 0, -1] :: V600_55
		Vico_4  = [(sqrt(5)-1)/2, 0, -1]  :: V600_57
		Vico_5  = [1, (sqrt(5)-1)/2, 0]   :: V600_66
		Vico_6  = [0, 1, -(sqrt(5)-1)/2]  :: V600_45
		Vico_7  = [0, -1, -(sqrt(5)-1)/2] :: V600_114
		Vico_8  = [1, -(sqrt(5)-1)/2, 0]  :: V600_58
		Vico_9  = [(sqrt(5)-1)/2, 0, 1]   :: V600_12
		Vico_10 = [-(sqrt(5)-1)/2, 0, 1]  :: V600_5
		Vico_11 = [-1, -(sqrt(5)-1)/2, 0] :: V600_59
		Vico_12 = [0, -1, (sqrt(5)-1)/2]  :: V600_113
		--]=]
		local is = table{46, 68, 55, 57, 66, 45, 114, 58, 12, 5, 59, 113}
		local V = Matrix( is:mapi(function(i)
			return vtxs[i]:T()[1]	-- single row
		end):unpack() ):T()	-- vertexes as column vectors
		-- here I'm using the icosahedron transform T_2
		local P = Matrix.permutation(2,3,4,5,1,6,8,9,10,11,7,12)	--these are by-column, and correlate to the icosahedron vertex order
		local VP = (V * P)()
		printbr(var'V':eq(V))
		printbr(var'P':eq(P))
		printbr((var'V' * var'P'):eq( (V * P)() ))
		printbr((var'V' * var'V''^T'):eq( ( V * V:T() )() ))	
		--[=[
		-- icoVtxs is 4x12 ... so it isn't square ...
		-- T = 4x4, V = 4x12, T V = 4x12
		-- P = 12x12, V P = 4x12
		-- T V = V P
		-- hmm can't inverse ... will a pseudo-inverse work?
		-- T (V V') = V P V'
		-- T = (V P V') * (V V')^-1
		printbr('icosahedron:')
		printbr(var'V':eq(V))
		printbr(var'P':eq(P))
		local eqn = (
				( var'V' * var'P' * var'V''^T' ) * ( var'V' * var'V''^T' )^-1
			):eq(
				( VP * V:T() )() * ( V * V:T() )():inv()
			)
		printbr(eqn)
		--]=]	
		--[=[ the result is:
┌                                             ┐
│    2 + √(5)    -1 + √(5)        1 + √(5)    │
│ - ╶────────╴  ╶─────────╴    - ╶────────╴  0│
│    4 * √(5)        8                8       │
│                                             │
│    7 + √(5)    -3 + √(5)          1         │
│ - ╶────────╴  ╶─────────╴    ╶────────╴    0│
│    8 * √(5)     8 * √(5)      4 * √(5)      │
│                                             │
│   1 + √(5)          1       1 + 3 * √(5)    │
│  ╶────────╴    ╶────────╴  ╶────────────╴  0│
│   8 * √(5)      4 * √(5)      8 * √(5)      │
│                                             │
│      0             0              0        1│
└                                             ┘
		--]=]
		--[=[ might not work
		-- from pseudo-inverse:
		local T = Matrix(
			{-(2+sqrt(5))/(4*sqrt(5)), (sqrt(5)-1)/8, -(1+sqrt(5))/8, 0},
			{-(7+sqrt(5))/(8*sqrt(5)), (sqrt(5)-3)/(8*sqrt(5)), 1/(4*sqrt(5)), 0},
			{(1+sqrt(5))/(8*sqrt(5)), 1/(4*sqrt(5)), (1+3*sqrt(5))/(8*sqrt(5)), 0},
			{0, 0, 0, 1}
		)
		--]=]
		--[=[ ok how about just using the 4x4 first of (T V)_1..4 = T (V_1..4) = (V P)_1..4
		-- so T = (V P)_1..4 * (V_1..4)^-1
		local VP_1_4 = Matrix:lambda({4,4}, function(i,j) return VP[i][j] end)
		local V_1_4 = Matrix:lambda({4,4}, function(i,j) return V[i][j] end)
		printbr(var'V 1 4':eq(V_1_4))
		printbr(var'(VP) 1 4':eq(VP_1_4))
		local V_1_4_inv = V_1_4:inv()()
		printbr((var'V 1 4'^-1):eq(V_1_4_inv))
		printbr(var'T':eq(var'(VP) 1 4' * var'V 1 4'^-1):eq((VP_1_4 * V_1_4_inv)() ))
		--]=]
		--[=[ this gives us a transform of:
┌                                                                 ┐
│         1                1            - √(5)             1      │
│      - ╶─╴            - ╶─╴         ╶───────╴           ╶─╴     │
│         2                2              2                2      │
│                                                                 │
│  - (3 + √(5))     - (3 + √(5))        √(5)-9       3 * (√(5)-1) │
│╶─────────────╴  ╶─────────────╴      ╶──────╴     ╶────────────╴│
│       4                4                 4               4      │
│                                                                 │
│    1 + √(5)       - (1 + √(5))     - (1 + √(5))      1 + √(5)   │
│   ╶────────╴    ╶─────────────╴  ╶─────────────╴    ╶────────╴  │
│        4               4                4                4      │
│                                                                 │
│       0                0                0                1      │
└                                                                 ┘
		--]=]
		--[=[
		local T = Matrix( 
			{-frac(1,2), -frac(1,2), -sqrt(5)/2, frac(1,2)}, 
			{-(3+sqrt(5))/4, -(3+sqrt(5))/4, (sqrt(5)-9)/4, 3*(sqrt(5)-1)/4},
			{(1+sqrt(5))/4, -(1+sqrt(5))/4, -(1+sqrt(5))/4, (1+sqrt(5))/4}, 
			{0,0,0,1}
		)
		--]=]
		--[=[ ok i fixed the 600-cell icoshaedron vertex permutation order
┌                                                            ┐
│ -1 + √(5)                   √(5) * (1 + √(5))        1     │
│╶─────────╴       0       - ╶─────────────────╴      ╶─╴    │
│     4                               4                2     │
│                                                            │
│  1 + √(5)        1             1 - √(5)                    │
│ ╶────────╴      ╶─╴           ╶────────╴             0     │
│      4           2                 4                       │
│                                                            │
│     1        3 - √(5)                            -1 + √(5) │
│    ╶─╴      ╶────────╴             0            ╶─────────╴│
│     2            4                                   4     │
│                                                            │
│              1 - √(5)              1              1 + √(5) │
│     0       ╶────────╴            ╶─╴            ╶────────╴│
│                  4                 2                  4    │
└                                                            ┘
		--]=]
		--[=[ 1-4 vertex permutation rotation still doesn't work
		local T = Matrix( 
			{ (sqrt(5)-1)/4, 0, -sqrt(5)*(sqrt(5)+1)/4, frac(1,2) }, 
			{(sqrt(5)+1)/4, frac(1,2), -(sqrt(5)-1)/4, 0}, 
			{frac(1,2), (3-sqrt(5))/4, 0, (sqrt(5)-1)/4}, 
			{0, -(sqrt(5)-1)/4, frac(1,2), (sqrt(5)+1)/4}
		)
		--]=]
		--[=[ how about pseudo-inverse
┌                                         ┐
│ -1 + √(5)       1 + √(5)         1      │
│╶─────────╴   - ╶────────╴     - ╶─╴    0│
│     4               4            2      │
│                                         │
│  1 + √(5)         1         1 - √(5)    │
│ ╶────────╴       ╶─╴       ╶────────╴  0│
│      4            2             4       │
│                                         │
│     1          1 - √(5)     1 + √(5)    │
│    ╶─╴        ╶────────╴   ╶────────╴  0│
│     2              4            4       │
│                                         │
│     0             0             0      1│
└                                         ┘

		--]=]
		--[=[ WORKS
		local T = ( Matrix( { sqrt(5)*(3-sqrt(5))/4, -sqrt(5)/2, -sqrt(5)*(sqrt(5)-1)/4, 0 }, {sqrt(5)/2, sqrt(5)*(sqrt(5)-1)/4, sqrt(5)*(sqrt(5)-3)/4, 0}, {sqrt(5)*(sqrt(5)-1)/4, sqrt(5)*(sqrt(5)-3)/4, sqrt(5)/2, 0}, {0, 0, 0, 3*(3+sqrt(5))/2})() * Matrix.diagonal((1+sqrt(5))/(2*sqrt(5)), (1+sqrt(5))/(2*sqrt(5)), (1+sqrt(5))/(2*sqrt(5)), (3-sqrt(5))/6) )()
		printbr(var'T':eq(T))
		printbr((var'T' * var'V'):eq( (T * V)() ))
		--]=]	
	end
io.stderr:write('done finding icosahedron transform in 600-cell\n')
io.stderr:flush()
f:flush()
f:close()
do return end
--]]
	
	io.stderr:write('vertex inner products...\n')
	io.stderr:flush()

	-- number of vertexes
	local nvtxs = #vtxs
	shapeCache.nvtxs = nvtxs

-- [[ show vertex inner products
-- before or after finding all transforms?
	local VmatT = Matrix(vtxs:mapi(function(v) return v:T()[1] end):unpack())
	local Vmat = VmatT:T()
	shapeCache.Vmat = Vmat

	printbr'Vertexes as column vectors:'
	printbr()

	printbr(var'V':eq(Vmat))
	printbr()

	printbr'Vertex inner products:'
	printbr()

	local vdots = (Vmat:T() * Vmat)()
	shapeCache.vdots = vdots
	printbr((var'V''^T' * var'V'):eq(Vmat:T() * Vmat):eq(vdots))
	printbr()
	
	io.stderr:write('...done vertex inner products\n')
	io.stderr:flush()
--]]

--[[ to help me with creating the transform of the 600-cell
	do
		printbr("vertexes within ", phi/2, " of vtx1:")
		local comma = ''
		for i=1,nvtxs do
			if Constant.isValue((vdots[1][i] - (1 + sqrt(5))/4)(), 0) then
				printbr(comma, i)
				comma = ', '
			end
		end
		printbr()
	end
--]]



--[[
T V = V P
we are first finding all T's from a basis of T's, then using all T's to determine associated P's
but alternatively, because there are a fixed number of P's, we can solve: T = V P V^T
and then filter only T's that coincide with proper rotations: A^-1 = A^T <=> A A^T = I
actually depending on the permutation (i.e. a permutation that flipped vertexes 1 and 2 but left 3-n untouched),
 they can't be represented by linear transforms, will the result T be zero?  or have a >{} nullspace at least?
either way, if you have all the vertices, here's how you can find all the transforms.  especially easy for simplexes.
--]]

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

	-- show if there are any simplification errors
	for j=2,#allxforms do
		for i=1,j-1 do
			if (allxforms[i] - allxforms[j])() == Matrix:zeros{n,n} then
				printbr(var'T'('_'..i), 'should equal', var'T'('_'..j), ':',
					allxforms[i], ',', allxforms[j])
			end
		end
	end


	-- show vtx multiplication table
	-- btw, do i need to show the details of this above?  or should I just show this?
	local function printVtxMulTable()
		printbr[[Table of $T_i \cdot v_j = v_k$:]]
		print'<table>\n'
		print'<tr><td></td>'
		for j=1,#vtxs do
			print('<td>V'..j..'</td>')
		end
		print'</tr>\n'
		-- print the multiplcation table
		for i,xi in ipairs(allxforms) do
			print('<tr><td>T'..i..'</td>')
			for j,vj in ipairs(vtxs) do
				local k = vtxs:find((xi * vj)())
				print'<td>'
				if not k then
					print("couldn't find xform for ", var'T'('_'..i) * var'V'('_'..j))
				else
					print('V'..k)
				end
				print'</td>'
			end
			print('</tr>\n')
		end
		print'</table>\n'
		printbr()
		printbr()
	end
	printVtxMulTable()


	local mulTable = {}
	shapeCache.mulTable = mulTable
	for i,xi in ipairs(allxforms) do
		mulTable[i] = {}
		for j,xj in ipairs(allxforms) do
			mulTable[i][j] = allxforms:find((xi * xj)())
		end
	end

	local function printXformMulTable()
		printbr[[Table of $T_i \cdot T_j = T_k$:]]
		print'<table>\n'
		print'<tr><td></td>'
		for i=1,#allxforms do
			print('<td>T'..i..'</td>')
		end
		print'</tr>\n'
		-- print the multiplcation table
		for i=1,#allxforms do
			print('<tr><td>T'..i..'</td>')
			for j=1,#allxforms do
				local k = mulTable[i][j]
				print'<td>'
				if not k then
					print("couldn't find xform for ", var'T'('_'..i) * var'T'('_'..j))
				else
					print('T'..k)
				end
				print'</td>'
			end
			print('</tr>\n')
		end
		print'</table>\n'
		printbr()
		printbr()
	end

	printXformMulTable()


	--[=[ rename by trying to put the Ti*Tj=T1 transforms closest to the diagonal:
	
	local dist = table()
	for i=1,#allxforms do
		for j=1,#allxforms do
			if mulTable[i][j] == 1 then
				dist[i] = math.abs(i - j)
				break
			end
		end
	end
	dist = dist:mapi(function(v,k) return {k,v} end):sort(function(a,b)
		if a[2] == b[2] then return a[1] < b[1] end	-- for matching dist's, keep smallest indexes first
		return a[2] < b[2]
	end)
	-- ok now, the renaming: dist[i][1] is the 'from', i is the 'to'
	local rename = table()
	for i=1,#dist do
		rename[dist[i][1]] = i
	end
	--]=]

	--[=[ rename by grouping transforms

	-- rename[to] = from
	local whatsleft = range(#allxforms)
	local rename = table()
	rename:insert(whatsleft:remove(1))
	
	local function process(last)
		if not last then
			if #whatsleft == 0 then return end
			last = whatsleft:remove(1)
			rename:insert(last)
			return process(last)
		end
		
		local next = mulTable[2][last]
		local k = whatsleft:find(next)
		if not k then return process() end
		
		whatsleft:remove(k)
		rename:insert(next)
		return process(next)
	end
	process()

	-- change to rename[from] = to
	rename = rename:mapi(function(v,k) return k,v end)
	--]=]

	--[=[
	-- now first remap mulTable[i][j]
	-- then remap the indexes of mulTable
	local mulTableRenamed = {}
	for i=1,#allxforms do
		mulTableRenamed[rename[i]] = {}
		for j=1,#allxforms do
			mulTableRenamed[rename[i]][rename[j]] = rename[mulTable[i][j]]
		end
	end
	
	printbr('relabeled', tolua(rename))
	printbr()

	mulTable = mulTableRenamed
	printXformMulTable()
	--]=]

--[=[ not sure if this is useful.  can't seem to visualize anything useful from it.
	file['tmp.dot'] = table{
		'digraph {',
	}:append(edges:mapi(function(e)
		return '\t'..table.concat(e, ' -> ')..';'
	end)):append{
		'}',
	}:concat'\n'

	os.execute('circo tmp.dot -Tsvg > "Platonic Solids/'..shape.name..'.svg"')
	os.remove'tmp.dot'

	printbr("<img src='"..shape.name..".svg'>/")
--]=]


	print(MathJax.footer)
	f:close()
end

-- can symmath.export.SymMath export Lua tables?
--io.writefile(cacheFilename, symmath.export.SymMath(cache))
io.writefile(cacheFilename, tolua(cache, {
	serializeForType = {
		table = function(state, x, tab, path, keyRef, ...)
			local mt = getmetatable(x)
			if mt and (
				Expression:isa(mt)
				-- TODO 'or' any other classes in symmath that aren't subclasses of Expression (are there any?)
			) then
				return symmath.export.SymMath(x)
			end
			return tolua.defaultSerializeForType.table(state, x, tab, path, keyRef, ...)
		end,
	}
}))
-- is there some sort of tolua args that will encode the symmath with symmath.export.SymMath?
--[[
local s = table()
s:insert'{'
for k,v in pairs(cache) do
	
end
s:insert'}'
io.writefile(cacheFilename, s:concat'\n')
--]]

print(export.MathJax.footer)
