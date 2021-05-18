--[[

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
local Expression = require 'symmath.Expression'
local Function = require 'symmath.Function'
local Variable = require 'symmath.Variable'

--[[
subclass of Expression?  Function?  Variable?
Expression: last resort
Function: easy for output generation
Variable: easy for integration with variable dependencies.
--]]
--local UserFunction = class(Expression)
--local UserFunction = class(Function)
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

return UserFunction 
