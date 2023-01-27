local class = require 'ext.class'
local table = require 'ext.table'
local Binary = require 'symmath.op.Binary'

local mod = class(Binary)

mod.precedence = 3

mod.name = '%'
mod.nameForExporterTable = {}
mod.nameForExporterTable.LaTeX = '\\mod'

--[[
d/dx[a%b] is da/dx, except when a = b * k for some integer k
--]]
function mod:evaluateDerivative(deriv, ...)
	local a, b = table.unpack(self)
	a = a:clone()
	return deriv(a, ...)
end

return mod
