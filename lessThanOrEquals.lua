require 'ext'
local EquationOp = require 'symmath.EquationOp'
local lessThanOrEquals = class(EquationOp)
lessThanOrEquals.name = '<='
return lessThanOrEquals
