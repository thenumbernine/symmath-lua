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

-- create a plot of an expression
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

	local capture = not args.persist and not args.terminal
	if capture then
		args.terminal = 'svg size 800,600'
		args.output = 'tmp.svg'
	end
	gnuplot(args)
	local svg = file['tmp.svg']
	file['tmp.svg'] = nil
	-- assumes html output ...
	print(svg,'<br>')
end

return GnuPlot()	-- singleton
