local table = require 'ext.table'
local class = require 'ext.class'
local Language = require 'symmath.export.Language'

local GnuPlot = class(Language)

GnuPlot.name = 'GnuPlot'

GnuPlot.constantPeriodRequired = true

GnuPlot.lookupTable = setmetatable(table(GnuPlot.lookupTable, {
	[require 'symmath.Function'] = function(self, expr)
		return expr:nameForExporter(self) .. '(' .. table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat', ' .. ')'
	end,
	[require 'symmath.op.pow'] = function(self, expr)
		if expr[1] == require 'symmath'.e then
			return '(exp('..self:apply(expr[2])..'))'
		else
			return '('..table.mapi(expr, function(x)
				return (self:apply(x))
			end):concat' ** '..')'
		end
	end,
	[require 'symmath.Heaviside'] = function(self, expr)
		return '('..self:apply(expr[1])..' >= 0.)'
	end,
}), nil)

-- TODO ... GnuPlot functions can't be multiple lines (I think)
GnuPlot.generateParams = {
	funcHeaderStart = function(self, name, inputs)
		return (name or '')..'('
	end,
	funcHeaderEnd = ') =',
}

--[[
create a plot of an expression
forwards args to require 'gnuplot'
except args:
	args[i] - if this is a symmath Expression then it is automatically converted to a GnuPlot expression
	outputType
		- set to 'MathJax' for outputting inline'd svg
		- set to 'Console' for outputting inline'd text
--]]
function GnuPlot:plot(args)
	local file = require 'ext.file'
	local gnuplot = require 'gnuplot'
	local var = require 'symmath.Variable'
	local Expression = require 'symmath.Expression'
	
	-- TODO accept *all* vars used, and define vars in gnuplot before producing the plot command
	for i,arg in ipairs(args) do
		local expr = arg[1]
		if Expression:isa(expr) then
			local x = arg.x or var'x' arg.x = nil
			args[i][1] = self:apply(expr:replace(x, var'x'))
		end
	end

	-- TODO determine this from the *true* exporter that called this exporter.
	--local outputType = 'MathJax'	-- LaTeX too? can LaTeX inline svg?  or I could insert it as an image link?
	--local outputType = 'Console'
	local outputType = args.outputType or 'MathJax'

	local capture = not args.persist and not args.terminal
	if capture then
		if outputType == 'MathJax' then
			args.terminal = 'svg size 800,600'
			args.output = 'tmp.svg'
		elseif outputType == 'Console' then
			args.terminal = 'dumb'
			args.output = 'tmp.txt'
		end
	end
	
	gnuplot(args)

	if outputType == 'MathJax' then
		local data = file['tmp.svg']
		file['tmp.svg'] = nil
		print(data, '<br>')
	elseif outputType == 'Console' then
		local data = file['tmp.txt']
		file['tmp.txt'] = nil
		print(data)
	end
end

return GnuPlot()	-- singleton
