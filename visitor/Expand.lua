local class = require 'ext.class'
local Visitor = require 'symmath.visitor.Visitor'
local Expand = class(Visitor)
Expand.name = 'Expand'
return Expand
