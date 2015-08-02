--[[
Matrix is a Array with some added Matrix-specific stuff to the namespace
--]]
require 'ext'
local Array = require 'symmath.Array'
local Matrix = class(Array)

Matrix.inverse = require 'symmath.matrix.inverse'
Matrix.determinant = require 'symmath.matrix.determinant'
Matrix.identity = require 'symmath.matrix.identity'
Matrix.transpose = require 'symmath.matrix.transpose'

return Matrix

