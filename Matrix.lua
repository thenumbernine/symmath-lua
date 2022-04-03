--[[
Matrix is a Array with some added Matrix-specific stuff to the namespace
--]]
local class = require 'ext.class'
local Array = require 'symmath.Array'
local Matrix = class(Array)

-- class() assigns __index to self ... so set it back
Matrix.__index = Matrix.super.__index

Matrix.name = 'Matrix'

-- TODO "invert"
Matrix.inverse = require 'symmath.matrix.inverse'
Matrix.inv = Matrix.inverse	-- shorthand

Matrix.determinant = require 'symmath.matrix.determinant'
Matrix.det = Matrix.determinant	-- shorthand

Matrix.identity = require 'symmath.matrix.identity'

Matrix.transpose = require 'symmath.matrix.transpose'
Matrix.T = Matrix.transpose	-- shorthand

Matrix.diagonal = require 'symmath.matrix.diagonal'
Matrix.trace = require 'symmath.matrix.trace'
Matrix.pseudoInverse = require 'symmath.matrix.pseudoInverse'
Matrix.nullspace = require 'symmath.matrix.nullspace'

-- TODO "rotate"
Matrix.rotation = require 'symmath.matrix.Rotation'

Matrix.eulerAngles = require 'symmath.matrix.EulerAngles'
Matrix.eigen = require 'symmath.matrix.eigen'
Matrix.exp = require 'symmath.matrix.exp'


function Matrix:charpoly(lambdaVar)
	if not lambdaVar then
		local Variable = require 'symmath.Variable'
		-- TODO same as matrix/eigen.lua, call this 'λ'? otherwise fixVariableNames and MathJax can screw up
		lambdaVar = Variable'λ'
	end
	local charPolyMat = (self - Matrix.identity(#self) * lambdaVar)()
	local charPolyEqn = charPolyMat:determinant{dontSimplify=true}:eq(0)

	-- ok simplify all we can *without* distributing mul into add
	local mul = require 'symmath.op.mul'
	local wasPushed = mul:pushRule'Expand/apply'
	charPolyEqn = charPolyEqn()
	if not wasPushed then mul:popRule'Expand/apply' end

	return charPolyEqn
end

function Matrix.permutation(...)
	local n = select('#', ...)
	local is = {...}
	return Matrix:lambda({n, n}, function(i,j)
		return is[j] == i and 1 or 0
	end)
end

--[[
create a projection matrix which removes component of 'normal'

'normal' is a table / row vector / Array

TODO call it "project"
and maybe TODO put it in Array if it is a vector operation?
and maybe TODO the implicit inner multiplication of first and last ranks like 'matrix' my numerical matrix library uses?


v' = v - n (v.n) / (n.n)
	= (I - n n' / n' n) v

v" = (I - a a' / a' a) (I - b b' / b' b) v
	= (I - a a' / a' a - b b' / b' b + a a' b b' / ((a' a) (b' b))) v

so the commutativity of projections is based on the commutativity of (a a' b b')
--]]
function Matrix.projection(normal)
	local n = #normal
	normal = Matrix(normal):T()	-- now it's a column vector
	-- now technically (n n' / n' n) is the "vector projection", projecting the rhs mul vector onto 'normal'
	-- then subtracting I - this turns it into a "projection linear operator", which projects the rhs mul vector onto the subspace excluding 'normal'
	return (Matrix.identity(n) - normal * normal:T() / (normal:T() * normal)()[1][1] )()
end

--[[
create a reflection matrix which, when multiplied with a vector, will reflect the vector about the axis.
assumes axis is a table / row vector / Array

TODO call it "reflect"
--]]
function Matrix.reflection(axis)
	local n = #axis
	axis = Matrix(axis):T()	-- now it's a column
	return (Matrix.identity(n) - 2 * axis * axis:T() / (axis:T() * axis)()[1][1])()
end

return Matrix
