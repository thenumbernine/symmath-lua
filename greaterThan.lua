require 'ext'
local EquationOp = require 'symmath.EquationOp'
local greaterThan = class(EquationOp)
greaterThan.name = '>'
return greaterThan
