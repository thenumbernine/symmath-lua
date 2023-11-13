--[[
post-simplify change from canonical form to make the equation look more presentable
--]]
local Visitor = require 'symmath.visitor.Visitor'
local Tidy = Visitor:subclass()
Tidy.name = 'Tidy'
return Tidy
