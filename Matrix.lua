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

return Matrix
