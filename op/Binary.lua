local Expression = require 'symmath.Expression'

local Binary = Expression:subclass()
Binary.name = 'Binary'

function Binary:init(...)
	Binary.super.init(self, ...)
	if self[1] == nil or self[2] == nil then
		local Verbose = require 'symmath.export.Verbose'
		error("tried to initialize a binary operation without two expressions: "..(self[1] and Verbose(self[1]) or tostring(self[1])).." and "..(self[2] and Verbose(self[2]) or tostring(self[2])))
	end
end

function Binary:getSepStr(export)
	local sep = self:nameForExporter(export)
	if not self.omitSpace then 	-- op.pow uses this.  Maybe esp for Console output?
		if sep == '' then
			sep = ' '		-- if the name was an empty string then just use a single space
		else
			sep = ' ' .. sep .. ' ' 	-- otherwise use two spaces
		end
	end
	return sep
end

return Binary
