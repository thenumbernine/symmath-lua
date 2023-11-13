local string = require 'ext.string'
local table = require 'ext.table'
local Export = require 'symmath.export.Export'

local Console = Export:subclass()

Console.name = 'Console'

Console.symbols = table(require 'symmath.tensor.symbols'.greekSymbolForNames)
for _,k in ipairs(Console.symbols:keys()) do
	Console.symbols[k] = string.trim(Console.symbols[k])
end

function Console:fixVariableName(name)
	local i=1
	while i < #name do
		for symname,symchar in pairs(Console.symbols) do
			if name:sub(i):match('^'..symname)
			and not name:sub(i+#symname):match('%a')	-- check 'not %w' rather than %W so that '' will hit the condition
			then
				name = name:sub(1,i-1) .. symchar .. name:sub(i+#symname)
				i = i + #symname - 1
			end
		end
		i=i+1
	end
	return name
end

return Console
