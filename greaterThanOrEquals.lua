require 'ext'
local EquationOp = require 'symmath.EquationOp'
local greaterThanOrEquals = class(EquationOp)
greaterThanOrEquals.name = '>='
return greaterThanOrEquals
