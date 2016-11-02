local class = require 'ext.class'
local Visitor = require 'symmath.visitor.Visitor'
local Factor = class(Visitor)
Factor.name = 'Factor'
return Factor
