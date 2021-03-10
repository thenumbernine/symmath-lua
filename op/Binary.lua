local class = require 'ext.class'
local Expression = require 'symmath.Expression'

local Binary = class(Expression)
Binary.name = 'Binary'

function Binary:init(...)
	Binary.super.init(self, ...)
	if self[1] == nil or self[2] == nil then	
		local Verbose = require 'symmath.export.Verbose'
		error("tried to initialize a binary operation without two expressions: "..(self[1] and Verbose(self[1]) or tostring(self[1])).." and "..(self[2] and Verbose(self[2]) or tostring(self[2])))
	end
end

function Binary:getSepStr(export)
	local sep = self.name
	if self.implicitName then 
		sep = ' '
	elseif not self.omitSpace then 
		sep = ' ' .. sep .. ' ' 
	end
	return sep
end

return Binary
