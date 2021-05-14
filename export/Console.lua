local class = require 'ext.class'
local string = require 'ext.string'
local table = require 'ext.table'
local Export = require 'symmath.export.Export'

local hasutf8, utf8 = pcall(require, 'utf8')
if not hasutf8 then utf8 = nil end


local Console = class(Export)

-- Technically I could just paste the unicode symbol directly into the string and let the text editor and the console deal with it
-- however unless I have a proper utf8.len function then the # length operator of Lua will screw up all the spacing.
-- SO unless I have access to utf8.len() (which my luajit doesn't atm) then I won't use unicode characters.
function Console.getUnicodeSymbol(code, default)
	if not hasutf8 then return default end
	-- wrap the unicode in just one load() so Lua versions that don't support it will still compile
	return assert(load([[return '\u{]]..code..[[}']]))()
end

Console.symbols = table(require 'symmath.tensor.symbols'.greekSymbolForNames, {
	-- TODO rename to 'infinity'.  see symmath.lua and symmath/export/LaTeX.lua
	infty = Console.getUnicodeSymbol('221e', 'inf'),
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

-- these have to match the names of builtin vars in symmath
-- TODO move this all into the specific variable somehow - per-exporter serialization.
-- for modularity of both, I should have tables in both the var and the exporter
Console.builtinVariableNames = {
	-- these unicode chars don't work on the windows default terminal:
	-- _i = Console.getUnicodeSymbol('2148', '_i'),
	-- _e = Console.getUnicodeSymbol('2147', '_e'),
	-- pi is already handled by 'fixVariableNames'
	-- TODO just add a utf8 lib that < lua 5.3 can use
	infty = Console.getUnicodeSymbol('221e', 'inf'),
}

Console.builtinFunctionNames = {
	sqrt = Console.getUnicodeSymbol('221a', 'sqrt'),
	cbrt = Console.getUnicodeSymbol('221b', 'cbrt'),
}

function Console:fixFunctionName(name)
	return self.builtinFunctionNames[name] or name
end


return Console
