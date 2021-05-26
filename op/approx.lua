--[[
meh, this might be for latex rendering more than anything
it's a subclass of op.eq so you should be able to solve(),
so a ~ 2*b => b ~ a/2
a:approx(2*b):solve(b) => b:approx(a/2)
--]]
local class = require 'ext.class'
local table = require 'ext.table'
local eq = require 'symmath.op.eq'
local approx = class(eq)

approx.name = '≈'
approx.nameForExporterTable = setmetatable(table(approx.nameForExporterTable), nil)
approx.nameForExporterTable.LaTeX = '\\approx'
approx.nameForExporterTable.SymMath = 'approx'

return approx
