--[[
Matrix is a Array with some added Matrix-specific stuff to the namespace
--]]
local class = require 'ext.class'
local Array = require 'symmath.Array'
local Matrix = class(Array)

-- class() assigns __index to self ... so set it back
Matrix.__index = Matrix.super.__index

Matrix.name = 'Matrix'

Matrix.inverse = require 'symmath.matrix.inverse'
Matrix.determinant = require 'symmath.matrix.determinant'
Matrix.identity = require 'symmath.matrix.identity'
Matrix.transpose = require 'symmath.matrix.transpose'
Matrix.diagonal = require 'symmath.matrix.diagonal'
Matrix.trace = require 'symmath.matrix.trace'
Matrix.pseudoInverse = require 'symmath.matrix.pseudoInverse'
Matrix.nullspace = require 'symmath.matrix.nullspace'
Matrix.rotation = require 'symmath.matrix.Rotation'
Matrix.eulerAngles = require 'symmath.matrix.EulerAngles'
Matrix.eigen = require 'symmath.matrix.eigen'
Matrix.exp = require 'symmath.matrix.exp'

-- shorthand
Matrix.inv = Matrix.inverse	
Matrix.T = Matrix.transpose
Matrix.det = Matrix.determinant

function Matrix:charpoly(lambdaVar)
	if not lambdaVar then
		local Variable = require 'symmath.Variable'
		lambdaVar = Variable'lambda'
	end
	local charPolyMat = (self - Matrix.identity(#self) * lambdaVar)()
	local charPolyEqn = charPolyMat:determinant(--[[{dontSimplify=true}--]]):eq(0)
	return charPolyEqn
end

return Matrix
