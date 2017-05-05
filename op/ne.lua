local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'
local ne = class(Equation)
ne.name = '!='	-- sorry Lua ...
return ne
