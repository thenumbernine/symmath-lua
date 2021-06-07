--[[

Should this be a Variable subclass?
Yes, because 
	- Variable is almost there.  it already has name, depends, and value.  This is 1-1 with a function's name, arguments, and definition.
	- other expressions can be defined / can be differentiated with respect to this (can they?)
	in fact, can they?  f(x) = x^2 sin(x) ... can be dif'd wrt x, wrt sin(x), but not wrt sin....
No, because we only ever operate on the evaluated expression after substituting parameters
	so instead subclass Function


should it be a subclass of Expression?  Function?  Variable?
Expression: last resort
Function: easy for substitution, differentiation, and output generation
Variable: easy for integration with variable dependencies.


xdef = x(t) = t^2
ydef = y(x,t) = x^2 + t^2

dx/dt = ∂x/∂t = 2 t

dy/dx = ∂y/∂x = 2 x

dy/dt = ∂y/∂x ∂x/∂t + ∂y/∂t = 2x 2t + 2t = 4 x t + 2 t


to do total derivatives, you must know the identities of all dependent vars
this is usually held in other CAS's as "function definitions"
that means, each time a function def is referenced, we need to keep track of it.

right now my function definitions are all handled as subclasses of symmath.Function, but require extra care for specifying derivatives
I could make a user-defined function def, symmath.UserFunction, shorthand 'func' or 'def' or something:

y(t,x):def(t^2 - x^2)

the call operator right now errors out if you call Variable(Variable), because it expects the internal to be a TensorIndex or something that can be parsed into a TensorIndex

using a variable in there might be too confusing ... esp if we want to interchange TensorIndexes and variables in the future?

that's my fav syntax though, but I will keep it on hold for now.

instead:

y:def({t,x}, t^2 - x^2)

but this still requires 'y' to be defined as a variable beforehand, and of course the variable def is going to need dependency on all the arguments of the function

so why not combine the variable and the function definition?

arguments are required for order when evaluating y .. y(t,x) vs y(x,t)

y = func('y', {t,x}, t^2 - x^2)

then there's always overriding 'func's returned object's call as well:
y = func'y'					-- no arguments ?  or all arguments?
y = func'y'(t,x)			-- arguments, but no explicit definition
y = func'y'(t,x)(t^2 - x^2)	-- arguments and definition.
but this is a bit too ambiguous with the __call operators

TODO once this is all done, rename 'Function' to 'BuiltinFunction' and rename 'UserFunction' to 'Function'

I really like the 'def' definition - more like maxima / gnuplot

but something tells me I should unify __call, TensorIndex, and Variable first before moving on to the :def() definition of UserFunction

--]]
local class = require 'ext.class'
local table = require 'ext.table'
local Expression = require 'symmath.Expression'
local Function = require 'symmath.Function'
local Variable = require 'symmath.Variable'

--[===[ UserFunction based on Variable :

local UserFunction = class(Variable)

--[[
static (weak) table of all user functions
use this for looking up function definitions when evaluating total derivatives
--]]
UserFunction.registeredFunctions = setmetatable({}, {__mode='v'})

--[[
f = func(name, [args, [def] ] )
--]]
function UserFunction:init(name, args, def, set)
	-- the 'nil' is for Variable.value
	-- and value could just as well be a function definition
	-- so Variable might as well be merged with this?
	Variable.init(self, name, args, nil, set)

	-- optional
	self.def = def
	if def then assert(Expression:isa(def), "def must be an Expression") end

	-- TODO warn if we override our definition?
	self.registeredFunctions[self.name] = self 
end

function UserFunction:defeq()
	return self:eq(self.def)
end

function UserFunction:printEqn()
	local TempFn = class(Function)
	TempFn.name = self.name
	TempFn.nameForExporterTable = table(self.nameForExporterTable)
	local args = self.dependentVars and self.dependentVars:mapi(function(var)
		return var.wrt
	end) or table()
	if self.def then
		return TempFn(args:unpack()):eq(self.def)
	end
	return TempFn(args:unpack())
end

-- UserFunction based on Variable ]===]
-- [===[ UserFunction based on Function:

local UserFunction = class(Function)

--[[
static (weak) table of all user functions
use this for looking up function definitions when evaluating total derivatives
--]]
UserFunction.registeredFunctions = setmetatable({}, {__mode='v'})

--[[
Static method to produce subclasses.
Call with Class:makeSubclass(name, args, def, set).
Another option is to make UserFunction() produce objects and for the objects to have their respective __call operators.
--]]
function UserFunction:makeSubclass(name, args, def, set)
	local f = class(self)
	f.name = assert(name)
	f.args = table(args)	-- optional
	f.set = set or require 'symmath.set.sets'.real

	for _,arg in ipairs(f.args) do
		assert(Variable:isa(arg), "args must be a table of Variables")
	end
	
	f.def = def	-- optional
	if def then assert(Expression:isa(def), "def must be an Expression or nil") end
	
	-- TODO warn if we override our definition?
	self.registeredFunctions[f.name] = f

	return f
end

--[[
same arguments as Variable

TODO should variable store 'src' and 'wrt' in case either is TensorRef's?

TODO variable has a single 'set', but function should have 'domain' and 'range'
and technically both should be inferred... domain from args[i].set, and range deduced from the expression
though in math the range and the image are separate ... the set of all outputs of the expression may be different than the specified set of outputs.

TODO ... the variables in a function's definition are internal, not external.
f(x) = x^2, the x in f(x) refers to the x^2, not to any other x's on the worksheet.
However defining a function as "f = func('f', {x})" would require an externally declared variable ...
... however however, you would still need an "x" with a locally shared scope of defining "f(x)" and "x^2", 
 	so techniaclly it would be "external", however it would just be just "local".
--]]

function UserFunction:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	local cl = self.class
	if not cl.cached_df then
		cl.cached_df = UserFunction:makeSubclass(
			cl.name.."'",
			cl.args,
			cl.def and self.def:diff(x)() or nil, 
			cl.set	-- will set be the same?
		)
	end
	local x = table.unpack(self):clone()
	return deriv(x, ...) * cl.cached_df(x)
end

function UserFunction:printEqn()
	local cl = self.class
	if cl.def then
		return cl(cl.args:unpack()):eq(cl.def)
	else
		return cl(cl.args:unpack())
	end
end

function UserFunction:defeq()
	local cl = self.class
	return cl(cl.args:unpack()):eq(cl.def)
end

-- with this, evals too much
-- without this, doesn't eval enough
-- though with this you have the option to just not assign .def
-- [[ 
UserFunction.rules = {
	Prune = {
		{apply = function(prune, expr)
			if expr.def then
				-- expr holds the user-class instance, with called expressions as children
				-- expr.args holds the function definition
				if #expr ~= #expr.args then return end	-- args don't match. error? or SFINAE?
				local def = expr.def
				for i,arg in ipairs(expr.args) do
					def = def:replace(arg, expr[i])
				end
				return def
			end
		end},
	},
}
--]]

-- UserFunction based on Function ]===]

return UserFunction 
