--[[
meh, this might be for latex rendering more than anything
it's a subclass of op.eq so you should be able to solve(),
so a ~ 2*b => b ~ a/2
--]]
local class = require 'ext.class'
local eq = require 'symmath.op.eq'
local approx = class(eq)

-- name is ~ for ascii output
approx.name = '~'

-- name is '\approx' for latex output
function approx:getSepStr(export)
	if require 'symmath.export.LaTeX'.class:isa(export) then
		return '\\approx'
	end
	return approx.super.getSepStr(self, export)
end

-- TODO to unify both, turn 'name' into a function?
-- or a getter 'getName(export)' ?
-- then there'd be no need to override 'getSepStr'

return approx
