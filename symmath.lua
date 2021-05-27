local table = require 'ext.table'

local symmath = {}

-- hack for require'ing symmath within the construction of symmath's namespace without causing a require() infinite loop
-- so instead of require 'symmath', preferrable is require 'symmath.namespace'()
require 'symmath.namespace'(symmath)

symmath.verbose = false
symmath.simplifyConstantPowers = false	-- whether 1/3 stays or becomes .33333...
symmath.debugSimplifyLoops = false		-- whether to debug simplification loops

symmath.clone = require 'symmath.clone'	-- also casts numbers to Constant
symmath.replace = require 'symmath.replace'
symmath.solve = require 'symmath.solve'
symmath.map = require 'symmath.map'

symmath.prune = require 'symmath.prune'
symmath.distributeDivision = require 'symmath.distributeDivision'
symmath.factorDivision = require 'symmath.factorDivision'
symmath.expand = require 'symmath.expand'
symmath.factor = require 'symmath.factor'
symmath.factorLinearSystem = require 'symmath.factorLinearSystem'
symmath.tidy = require 'symmath.tidy'
symmath.simplify = require 'symmath.simplify'
symmath.polyCoeffs = require 'symmath.polyCoeffs'
symmath.taylor = require 'symmath.taylor'

-- TODO finishme
symmath.dual = require 'symmath.tensor.dual'

symmath.multiplicity = require 'symmath.multiplicity'

-- replace variables with names as keys in evalmap with constants of the associated values
symmath.eval = require 'symmath.eval'

function symmath.match(a,b)
	if not symmath.Expression:isa(a) then
		a = symmath.clone(a)
	end
	return a:match(b)
end

-- whether to replace variable names with unicode Greek symbols
symmath.fixVariableNames = false

symmath.Variable = require 'symmath.Variable'
symmath.var = symmath.Variable					--shorthand
function symmath.vars(...)						--create variables for each string parameter 
	return table{...}:mapi(function(x) return symmath.var(x) end):unpack()
end

-- TODO call Function BuiltinFunction and call UserFunction Function?
symmath.UserFunction = require 'symmath.UserFunction'
symmath.func = symmath.UserFunction

symmath.set = require 'symmath.set.sets'

-- export expressions to various languages
symmath.export = {
	C = require 'symmath.export.C',
	GnuPlot = require 'symmath.export.GnuPlot',
	JavaScript = require 'symmath.export.JavaScript',
	LaTeX = require 'symmath.export.LaTeX',
	Lua = require 'symmath.export.Lua',
	MathJax = require 'symmath.export.MathJax',
	Mathematica = require 'symmath.export.Mathematica',
	MultiLine = require 'symmath.export.MultiLine',
	SingleLine = require 'symmath.export.SingleLine',
	SymMath = require 'symmath.export.SymMath',
	Verbose = require 'symmath.export.Verbose',
	-- abstract class, not a singleton:
	Console = require 'symmath.export.Console',
	Language = require 'symmath.export.Language',
}

--[[
builds a function out of the expression
exprs - specifies the table of expressions that will be associated with function input parameters
	- can either be a list of expressions -- in which case the text of the expression will be used (i.e. the name of the Variable) 
	- or can be a table with a key/value pair, mapping the expression (the key) to the string to be used in the function (the value)
	- ex: 
		x=symmath.var'x' 
		(x^2):compile{x} 
		... produces function(x) return x^2 end
		
		x=symmath.var'x' 
		(x^2):copmile{x='y'} 
		... produces function(y) return y^2 end
		
		x,t=symmath.vars('x','t') 
		x:setDependentVars(t) 
		symmath.exp(-x^2):diff(t):simplify():compile{x,{dx_dt=x:diff(t)}})
		... produces "function(x, dx_dt) return -2 * x * dx_dt * math.exp(-x^2) end"

if there are any Derivatives or variables (other those listed) then compiling will produce an error
so if you have any derivs you want as function parameters, use map() or replace() to replace them for new variables
	and then put them in the vars list

This function is used for Lua function generation.
If you want code generation, look at symmath.export.Language's 'toCode' function
--]]
function symmath.compile(expr, vars, language, args)
	assert(language == nil or language == 'Lua', "dropped support for compiling to non-Lua.  use toCode or toFunc instead.")
	return symmath.export.Lua:toFunc(table({
		output = {expr},
		input = vars,
	}, args))
end

--[[ potential new system based on breadth-first search ... not finished yet

local rules = {
	function(expr)
		
	end,
}


function applyRuleAtNode(expr, node, rule)
	expr = expr:clone()
	
	-- find 'node' in 'expr'
	-- replace it with 'prune(node)'
	if node == expr then
		return rule:apply(expr)
	end

	local parent, index = expr:findChild(node)
	parent[index] = rule(parent[index])
	return expr
end

function applyRulesAtNode(expr, node)
	for _,rule in ipairs(rules) do
		applyRuleAtNode(expr, node, rule)
	end
end

function simplify(firstExpr)
	local allExprs = table{firstExpr:clone()}
	local currentExprs = table{firstExpr:clone()}
	local tries = 0
	while #currentExprs > 0 do
		local expr = currentExprs:remove(1)
		local nodes = expr:getAllNodes()
		for i=1,#nodes do
			local newExprs = applyRulesAtNode(expr, nodes[i])
			for _,newExpr in ipairs(newExprs) do
				if not allExprs:find(newExpr) then
					allExprs:insert(newExpr)
					currentExprs:insert(newExpr)
				end
			end
		end
		tries = tries + 1
		if tries > 10 then break end
	end
	local smallestNodes
	local smallestExpr
	for _,expr in ipairs(currentExpr) do
		local numNodes = #expr:getAllNodes()
		if not smallestNodes or numNodes < smallestNodes then
			smallestNodes = numNodes
			smallestExpr = expr
		end
	end
	return smallestExpr
end

--]]

symmath.tableCommutativeEqual = require 'symmath.tableCommutativeEqual'

symmath.Expression = require 'symmath.Expression'
symmath.Constant = require 'symmath.Constant'
symmath.complex = require 'symmath.complex'

-- TODO singleton?  constant?
symmath.Invalid = require 'symmath.Invalid'
symmath.invalid = symmath.Invalid()

symmath.Function = require 'symmath.Function'
symmath.Wildcard = require 'symmath.Wildcard'

symmath.asin = require 'symmath.asin'
symmath.asinh = require 'symmath.asinh'
symmath.acos = require 'symmath.acos'
symmath.acosh = require 'symmath.acosh'
symmath.atan = require 'symmath.atan'
symmath.atanh = require 'symmath.atanh'
symmath.atan2 = require 'symmath.atan2'
symmath.abs = require 'symmath.abs'
symmath.cbrt = require 'symmath.cbrt'
symmath.cos = require 'symmath.cos'
symmath.cosh = require 'symmath.cosh'
symmath.exp = require 'symmath.exp'
symmath.log = require 'symmath.log'
symmath.sin = require 'symmath.sin'
symmath.sinh = require 'symmath.sinh'
symmath.sqrt = require 'symmath.sqrt'
symmath.tan = require 'symmath.tan'
symmath.tanh = require 'symmath.tanh'
symmath.Heaviside = require 'symmath.Heaviside'

symmath.op = {
	Binary = require 'symmath.op.Binary',
	unm = require 'symmath.op.unm',
	add = require 'symmath.op.add',
	sub = require 'symmath.op.sub',
	mul = require 'symmath.op.mul',
	div = require 'symmath.op.div',
	pow = require 'symmath.op.pow',
	mod = require 'symmath.op.mod',

	Equation = require 'symmath.op.Equation',
	eq = require 'symmath.op.eq',
	ne = require 'symmath.op.ne',
	lt = require 'symmath.op.lt',
	le = require 'symmath.op.le',
	gt = require 'symmath.op.gt',
	ge = require 'symmath.op.ge',
	approx = require 'symmath.op.approx',
}
-- shorthand
symmath.frac = symmath.op.div

symmath.Limit = require 'symmath.Limit'
symmath.lim = symmath.Limit	-- shorthand ... TODO shorthand for Expression.lim

symmath.Derivative = require 'symmath.Derivative'
symmath.diff = symmath.Derivative	-- shorthand ... TODO shorthand for Expression.diff?

symmath.PartialDerivative = require 'symmath.PartialDerivative'
symmath.pdiff = symmath.PartialDerivative

-- thinking of lowercasing all of these ...
symmath.Sum = require 'symmath.Sum'
-- symmath.Product
symmath.Integral = require 'symmath.Integral'

-- specific to Matrix
symmath.Vector = require 'symmath.Vector'
symmath.Matrix = require 'symmath.Matrix'
symmath.Array = require 'symmath.Array'
symmath.Tensor = require 'symmath.Tensor'
-- hmm, not sure about namespace and subdirs ... this doesn't fit with Matrix
symmath.TensorIndex = require 'symmath.tensor.TensorIndex'
symmath.TensorRef = require 'symmath.tensor.TensorRef'

-- change the default as you see fit
symmath.tostring = symmath.export.MultiLine
symmath.Verbose = symmath.export.Verbose
symmath.GnuPlot = symmath.export.GnuPlot

-- constants 
--[[ hmm, should these be constants or variables?
symmath.i = symmath.Constant(symmath.complex(0,1), 'i')
symmath.e = symmath.Constant(math.exp(1), 'e')
symmath.pi = symmath.Constant(math.pi, 'pi')
symmath.inf = symmath.Constant(math.huge, 'infty')	-- TODO use 'infinite' or 'infinity' and fix the LaTex gsub fixVariableName code to handle renaming instead of just padding with symbols
--]]
-- [[
-- right now I'm comparing variables by name ... don't do that.  Or else complex's "i" will match an iterator's "i".
-- a temporary fix in the mean time ... I'll use '_i' for the name and swap it out with a unicode char, just like Mathematica does.  
-- This way users who use 'i' as an arbitrary variable won't have it collide with symmath.i
-- (why not use unicode all around?  don't use unicode escape codes, since lua 5.2 can't handle it with string length, but just use unicode strings here.)
symmath.i = symmath.Variable('_i', nil, symmath.complex(0,1), nil, symmath)	-- ⅈ (doesn't show up in Windows Consolas)
symmath.e = symmath.Variable('_e', nil, math.exp(1), nil, symmath)			-- ⅇ (doesn't show up in Windows Consolas)
symmath.pi = symmath.Variable('π', nil, math.pi, nil, symmath)				-- π
symmath.inf = symmath.Variable('inf', nil, math.huge, nil, symmath)		-- ∞
-- TODO symmath.nan = symmath.Variable('nan', nil, math.nan, nil, symmath)	-- ¿
--]]
	
do
	-- C ... i ... should we use gnu or microsoft?
	symmath.e:nameForExporter('C', 'M_E')
	symmath.pi:nameForExporter('C', 'M_PI')
	symmath.inf:nameForExporter('C', 'INFINITY')

	symmath.i:nameForExporter('GnuPlot', '{0,1}')
	symmath.e:nameForExporter('GnuPlot', 'exp(1.)')
	symmath.pi:nameForExporter('GnuPlot', 'pi')
	-- does inf have a representation in gnuplot?

	-- i doesn't have a representation in JavaScript
	symmath.e:nameForExporter('JavaScript', 'Math.exp(1)')
	symmath.pi:nameForExporter('JavaScript', 'Math.PI')
	symmath.inf:nameForExporter('JavaScript', 'Infinity')
	
	local Console = require 'symmath.export.Console'
	-- hmm, MultiLine goes to SingleLine for its variable name encoding
	-- so nameForExporter will use SingleLine, even for MultiLine encoding
	-- how about making MultiLine a subclass of SingleLine?
	--symmath.inf:nameForExporter('SingleLine', '∞')
	symmath.inf:nameForExporter(Console, '∞')

	symmath.i:nameForExporter('Lua', 'ffi.new("complex", 0, 1)')
	symmath.e:nameForExporter('Lua', 'math.exp(1)')
	symmath.pi:nameForExporter('Lua', 'math.pi')
	symmath.inf:nameForExporter('Lua', 'math.huge')
	
	symmath.i:nameForExporter('Mathematica', 'ii')
	symmath.e:nameForExporter('Mathematica', 'e')

	symmath.i:nameForExporter('LaTeX', 'i')
	symmath.e:nameForExporter('LaTeX', 'e')
	-- with this, with tostring=MultiLine, with fixVariableNames, when printing export.LaTeX(pi), it shows up as $\π$
	-- but ... what a strange combination of flags
	symmath.pi:nameForExporter('LaTeX', '\\pi')
	symmath.inf:nameForExporter('LaTeX', '\\infty')

	-- add LaTeX escaped names for builtin functions
	symmath.export.LaTeX:addFunctionNames(symmath)
end



-- hack implicit variable names to look good in TeX

--[[
args:
	env = environment to copy namespace into.  default is _G.
--]]
symmath.setup = function(args)
	args = args or {}
	local env = args.env or _G	
	
	--[[ just copy
	for k,v in pairs(symmath) do
		if k ~= 'tostring' then
			env[k] = v
		end
	end
	--]]
	-- [[ override environment
	for k,v in pairs(args) do
		-- hmm, some args are for symmath, some are for setup ...
		if k ~= 'env' 
		and k ~= 'MathJax'
		then
			symmath[k] = v
		end
	end
	local mt = getmetatable(env)
	if mt then
		-- the user should already know if there is a metatable
		--io.stderr:write"Looks like this environment already has a metatable.  Overriding...\n"
		--io.stderr:flush()
		local nmt = {}	-- create a soft-copy
		for k,v in pairs(mt) do nmt[k] = v end
		mt = nmt
	else
		mt = {}
	end
	env.symmath = symmath
	
	local oldIndex = mt.__index

	function mt.__index(t,k)
		-- first check symmath (except tostring, for circular reference reasons)
		local x
		if k ~= 'tostring' then
			x = symmath[k]
			if x ~= nil then return x end
		end
		x = rawget(env,k)
		if x ~= nil then return x end

		-- last fall back on the old metatable __index (if it did previously exist)
		if oldIndex then
			if type(oldIndex) == 'table' then	
				x = oldIndex[k]
			elseif type(oldIndex) == 'function' then
				x = oldIndex(t,k)
			else
				error("I don't know how to handle this __index")
			end
			if x ~= nil then return x end
		end
		
		-- if we are using implicitVars then create vars when we can't find anything else
		if symmath.implicitVars then
			return symmath.var(k)
		end

		return nil

	end
	
	setmetatable(env, mt)
	--]]

	if args.MathJax then
		local MathJaxArgs = type(args.MathJax) == 'table' and args.MathJax or {}
		symmath.export.MathJax.setup(MathJaxArgs)
	end
end

symmath.Visitor = require 'symmath.visitor.Visitor'

function symmath.makefunc(name)
	local Function = symmath.Function
	return class(Function, {name=name})
end

-- make require'symmath'() shorthand for require'symmath'.setup()
setmetatable(symmath, {
	__call = function(t, ...)
		return t.setup(...)
	end,
})

return symmath
