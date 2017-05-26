local table = require 'ext.table'
local class = require 'ext.class'
local Language = require 'symmath.tostring.Language'

local GnuPlot = class(Language)

GnuPlot.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr, vars)
		local s = tostring(expr.value)
		if not s:find'.' and not s:find'[eE]' then s = s .. '.' end
		return s
	end,
	[require 'symmath.Invalid'] = function(self, expr, vars)
		return '(0/0)'
	end,
	[require 'symmath.Function'] = function(self, expr, vars)
		return expr.name .. '(' .. table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x, vars)
		end):concat(',') .. ')'
	end,
	[require 'symmath.op.unm'] = function(self, expr, vars)
		return '(-'..self:apply(expr[1], vars)..')'
	end,
	[require 'symmath.op.Binary'] = function(self, expr, vars)
		return '('..table.map(expr, function(x,k)
			if type(k) ~= 'number' then return end
			return self:apply(x, vars)
		end):concat(' '..expr.name..' ')..')'
	end,
	[require 'symmath.op.pow'] = function(self, expr, vars)
		if expr[1] == require 'symmath'.e then
			return '(exp('..self:apply(expr[2], vars)..'))'
		else
			return '('..table.map(expr, function(x,k)
				if type(k) ~= 'number' then return end
				return self:apply(x, vars)
			end):concat(' ** ')..')'
		end
	end,
	[require 'symmath.Variable'] = function(self, expr, vars)
		if table.find(vars, nil, function(var) return expr.name == var.name end) then
			return expr.name
		end
		error("tried to compile variable "..expr.name.." that wasn't in your function argument variable list")
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!")
	end,
	[require 'symmath.Heaviside'] = function(self, expr, vars)
		return '('..self:apply(expr[1], vars)..' >= 0.)'
	end,
}

-- create a plot of an expression
local gnuplot = require 'gnuplot'
local io = require 'ext.io'
local file = require 'ext.file'
function GnuPlot:plot(args)
	local var = require 'symmath.Variable'
	-- TODO accept *all* vars used, and define vars in gnuplot before producing the plot command
	for i,arg in ipairs(args) do
		local x = arg.x or var'x' arg.x = nil
		local expr = assert(arg[1])
		args[i][1] = self:apply(expr:replace(x, var'x'), {var'x'})
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
