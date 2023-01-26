--[[
I'm sure there's a better way to do this
for now - since prune() leaves things in a div -> add - > mul state,
I'll just have this around to convert things to an add -> div -> mul state
TODO make canonical form add -> sub -> mul -> div
--]]
local class = require 'ext.class'
local Visitor = require 'symmath.visitor.Visitor'
local DistributeDivision = class(Visitor)
DistributeDivision.name = 'DistributeDivision'

-- prune beforehand to undo tidy(), to undo subtractions and unary - signs
function DistributeDivision:apply(expr, ...)
	--[[
	if not expr.simplify then
		print(require 'symmath.export.Verbose'(expr))
		error("expr "..type(expr).." "..tostring(expr).." doesn't have simplify")
	end

	return DistributeDivision.super.apply(self, expr:simplify():prune(), ...)
	--]]
	-- [[
	local simplify = require 'symmath.simplify'
	local prune = require 'symmath.prune'
	return DistributeDivision.super.apply(self, prune(simplify(expr)), ...)
	--]]
end

return DistributeDivision
