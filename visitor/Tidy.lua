--[[
post-simplify change from canonical form to make the equation look more presentable
--]]
local class = require 'ext.class'
local Visitor = require 'symmath.visitor.Visitor'
local Tidy = class(Visitor)
Tidy.name = 'Tidy'
return Tidy
