require 'ext'
local EquationOp = require 'symmath.EquationOp'
local lessThan = class(EquationOp)
lessThan.name = '<'
return lessThan
