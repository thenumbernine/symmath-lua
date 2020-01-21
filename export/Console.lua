local class = require 'ext.class'
local string = require 'ext.string'
local table = require 'ext.table'
local Export = require 'symmath.export.Export'

local Console = class(Export)

Console.symbols = table(require 'symmath.tensor.symbols'.greekSymbolForNames, {
	-- TODO rename to 'infinity'.  see symmath.lua and symmath/export/LaTeX.lua
	infty = '∞',
})
for _,k in ipairs(Console.symbols:keys()) do
	Console.symbols[k] = string.trim(Console.symbols[k])
end

function Console:fixVariableName(name)
local orig = name
	local i=1
	while i < #name do
		for symname,symchar in pairs(Console.symbols) do
			if name:sub(i):match('^'..symname)
			and not name:sub(i+#symname):match('%a')	-- check 'not %w' rather than %W so that '' will hit the condition 
			then
				name = name:sub(1,i-1) .. symchar .. name:sub(i+#symname)
			end
		end
		i=i+1
	end
	return name
end

return Console
