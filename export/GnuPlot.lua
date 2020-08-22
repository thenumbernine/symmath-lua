local table = require 'ext.table'
local class = require 'ext.class'
local Language = require 'symmath.export.Language'

local GnuPlot = class(Language)

GnuPlot.name = 'GnuPlot'

GnuPlot.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr)
		local s = tostring(expr.value)
		if not s:find'%.' and not s:find'[eE]' then s = s .. '.' end
		return s
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return '(0/0)'
	end,
	[require 'symmath.Function'] = function(self, expr)
		return expr.name .. '(' .. table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat', ' .. ')'
	end,
	[require 'symmath.op.unm'] = function(self, expr)
		return '(-'..self:apply(expr[1])..')'
	end,
	[require 'symmath.op.Binary'] = function(self, expr)
		return '('..table.mapi(expr, function(x)
			return (self:apply(x))
		end):concat(' '..expr.name..' ')..')'
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
	[require 'symmath.Variable'] = function(self, expr)
		return expr.name
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!")
	end,
	[require 'symmath.Heaviside'] = function(self, expr)
		return '('..self:apply(expr[1])..' >= 0.)'
	end,
}

-- TODO ... GnuPlot functions can't be multiple lines (I think)
GnuPlot.generateParams = {
	funcHeaderStart = function(name, inputs)
		return name..'('
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
		if Expression.is(expr) then
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
