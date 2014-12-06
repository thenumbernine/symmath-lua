--[[
Matrix is a Tensor with some added Matrix-specific stuff to the namespace
--]]
require 'ext'
local Tensor = require 'symmath.Tensor'
local Matrix = class(Tensor)

Matrix.inverse = require 'symmath.matrix.inverse'
Matrix.determinant = require 'symmath.matrix.determinant'
Matrix.identity = require 'symmath.matrix.identity'
Matrix.transpose = require 'symmath.matrix.transpose'

return Matrix

