local class = require 'ext.class'
local table = require 'ext.table'
local Derivative = require 'symmath.Derivative'

local TotalDerivative = class(Derivative)

TotalDerivative.name = 'TotalDerivative'
TotalDerivative.nameForExporterTable = table(TotalDerivative.nameForExporterTable)
TotalDerivative.nameForExporterTable.Console = 'd'
TotalDerivative.nameForExporterTable.LaTeX = 'd'
TotalDerivative.nameForExporterTable.Language = 'D'	-- used as variable name prefixes
TotalDerivative.isTotal = true

return TotalDerivative
