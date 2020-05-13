local class = require 'ext.class'
local Expression = require 'symmath.Expression'

local Wildcard = class(Expression)

function Wildcard:init(index)
	self.index = assert(index, "Wildcard expects an integer for the match index")
end

return Wildcard
