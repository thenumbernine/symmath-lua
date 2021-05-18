--[[
How Derivative, and diff, works:

First, user calls y:diff(x) or y:pdiff(x) or etc for other subclasses.  
Right now the base class is a total derivative.
That sits as-is, and does not evaluate immediately, in case you want to print it.

Upon prune() (done by simplify(), implicitly ())
- for variables dependent on the variable differentiating, but without definition we just leave it as is
- (TODO merge UserFunction with Variable)
- (TODO unit test to make sure dependsOn traversese graph , so y=y(x), x=x(t) means y:dependsOn(t) is true, and same with preserving derivatives of dy/dt)
-  (TODO make sure that graph traversal handles circular graphs somehow, without getting stuck in a loop)

	- in prune(),
		- - for Array's, applies the Derivative obj's class + params to all the Array elements
		- - for Constant's return 0
		- - for Derivative's, consolidates variables (i.e. x:diff(y):diff(z) => x:diff(y,z)) 
		- - for self, i.e. x:diff(x), return 1
				- for x^I:diff(x^J), return delta^I_J
				- in both cases, if we have more vars after, then short-circuit (0 or 1):diff(x) to just return 0
		- - for dy/dx:
			- - for partial, return 0
			- - for total, just don't evalulate? TODO insert the def here and evaluate. 

		- for all else, for d/dx expr: call expr:evaluateDerivative() wrt each var of the derivative

		- expr:evaluateDerivative(deriv, vars...) does ...
			- this contains the builtin derivative evaluation for each builtin function:

	- in prune() for TensorRef (i.e. var'x''^I') in the rule 'evalDeriv',
		- for comma derivative, Variable:applyDiff() is called
		- NOTICE this is the ONLY place applyDiff is called
			so TODO maybe call it something like "applyComma" ?
			or rewrite the :diff() and :pdiff() operators to use the applyDiff() variable
			or redo comma derivatives to use operators instead of derivative,
				and just introduce operators (basically functions, amirite?)
			also TODO make sure comma derivative is calling :pdiff()


what does (Expression expr):evaluateDerivative(Variable x) do?


internal structure:
	self[1] is the expression
	all subsequent children are variables
--]]

local class = require 'ext.class'
local table = require 'ext.table'
local Expression = require 'symmath.Expression'

local Derivative = class(Expression)
Derivative.precedence = 6

-- default is for Verbose and SymMath output
Derivative.name = 'Derivative'
Derivative.nameForExporterTable = table(Derivative.nameForExporterTable)
Derivative.nameForExporterTable.Console = 'd'
Derivative.nameForExporterTable.LaTeX = 'd'

-- base class is the total derivative
Derivative.isPartial = false

function Derivative:init(...)
	local Variable = require 'symmath.Variable'
	local vars = table{...}
	local expr = assert(vars:remove(1), "can't differentiate nil")
	assert(#vars > 0, "can't differentiate against nil")
	vars:sort(function(a,b) return a.name and b.name and a.name < b.name end)
	Derivative.super.init(self, expr, table.unpack(vars))
end

Derivative.rules = {
	Prune = {

		-- d/dx{y_i} = {dy_i/dx}
		{arrays = function(prune, expr)
			local Array = require 'symmath.Array'
			if Array:isa(expr[1]) then
				local res = expr[1]:clone()
				for i=1,#res do
					res[i] = prune:apply(getmetatable(expr)(res[i], table.unpack(expr, 2)))
				end
				return res
			end
		end},
	
		-- d/dx c = 0
		{constants = function(prune, expr)
			local Constant = require 'symmath.Constant'
			if Constant:isa(expr[1]) then
				return Constant(0)
			end
		end},

		-- d/dx d/dy = d/dxy
		{combine = function(prune, expr)
			if Derivative:isa(expr[1]) then
				return prune:apply(
					getmetatable(expr)(
						expr[1][1], 
						table.unpack(
							table.append({table.unpack(expr, 2)}, {table.unpack(expr[1], 2)})
						)
					)
				)
			end
		end},

-- [[ This is the same as Variable:evaluateDerivative
-- however enabling Variable.evaluateDerivative and commenting this returns (x^2):diff(x)() == 0
		-- dx/dx = 1
		{self = function(prune, expr)
			local Variable = require 'symmath.Variable'
			local Constant = require 'symmath.Constant'
			local TensorRef = require 'symmath.tensor.TensorRef'
			if Variable:isa(expr[1]) then
				local var = expr[1]
				-- dx/dx = 1
				if #expr == 2 then
					if var == expr[2] then
						return Constant(1)
					end
				-- d/dy dx/dx = 0
				elseif #expr > 2 then
					for i=2,#expr do
						if expr[i] == var then 
							return Constant(0) 
						end
					end
				end
			elseif TensorRef:isa(expr[1])
			and Variable:isa(expr[1][1])
			then
				local tvar = expr[1]	-- tensor-ref of the variable
				local var = expr[1][1]	-- the variable itself
				-- dx^I/dx^J = delta^I_J
				if #expr == 2 then
					if TensorRef:isa(expr[2])
					and var == expr[2][1] 
					and #expr[1] == #expr[2]	-- only matching # of symbols
					then
						local deltaSymbol = require 'symmath.Tensor':deltaSymbol()
						return TensorRef(
							deltaSymbol,
							table():append(
								range(2,#expr[1]):mapi(function(k)
									return expr[1][k]:clone()
								end),
								-- dx^i/dx^j = delta^i_j, so swap the raise/lower on all the wrt indexes
								range(2,#expr[2]):mapi(function(k)
									local index = expr[2][k]:clone()
									index.lower = not index.lower
									return index
								end)
							):unpack()
						)
					end
				-- d/dy dx^I/dx^J = 0
				elseif #expr > 2 then
					for i=2,#expr do
						if TensorRef:isa(expr[i])
						and var == expr[i][1]
						and #expr[1] == #expr[i]
						then
							return Constant(0)
						end
					end
				end
			end
		end},
--]]

		--dx/dy = 0 (unless x is a function of y and we are not a partial derivative)
		{other = function(prune, expr)
			local Constant = require 'symmath.Constant'
			local Variable = require 'symmath.Variable'
			local TensorRef = require 'symmath.tensor.TensorRef'
			-- apply differentiation
			-- don't do so if it's a diff of a variable that requests not to
			if Variable:isa(expr[1]) 
			or (
				TensorRef:isa(expr[1])
				and Variable:isa(expr[1][1])
			) then
				if expr.isPartial then
					return Constant(0)
				end
				local var = expr[1]
				for i=2,#expr do
					local wrt = expr[i]
					-- dx/dy
					-- dx^I/dy = 0 if x^I doesn't depend on y
					-- dx^I/dy^J = 0 if x^I doesn't depend on y^J
					-- and what about 2nd derivatives too?
					if not var:dependsOn(wrt) then
						return Constant(0)
					end
				end
			end
			
--[[
same with tensor references
how should this work?
should you need to specify the TensorRef that it is dependent upon (and do a pattern-compare on the indexes?)
or should you just specify the letter, and get rid of anything based on that letter?

also, how should comma derivatives work into this?  
honestly they should be shorthand for Tensor('_i', function(x) return x:diff(Tensor.coords.variables[i]) end)
that's a dense expression
in terms of index expressions though, you would have to reserve a letter for what you want to index to determine your variables
like reserving 'x' to mean your input dim of 'x1', 'x2', 'x3' (can't use x,y,z because the x's overlap ... you could use bold{x} or you could use X)
or reserving 'x' to mean 'r', 'theta', 'phi'
and then have the comma derivative just replace to a shorthand: v'^i_,j' :expandCommasOrSomething() == v'^i':diff(x'^j')
and then all vars you wnat to use as tensor indexes, you would have to specify as 'setDependentVars{x}' for input coordinate 'x'
this could be made easier by having a manifold object, and have it produce variables via :var(name), and have those automatically depend on 'x' the manifold / Tensor global input coordinate variable ...

notice that the latter has implications on the former

so here's some example code...

M = Manifold{
		inputSymbol = 'x',
}

a,b,c = M:vars('a', 'b', 'c')
	... or, for everything to go that way ...
M:makeGlobal()
a,b,c = vars('a', 'b', 'c')
	... within which it is established that a:setDependentVars{x} or a:setDependentVars{x'^i'}
	-- DEPENDING ON HOW THIS FUNCTION OPERATES

and now a'^i_,j' can be interchangeable with a'^i':diff(x'^j')
...which can be expanded to a dense tensor (along specific indexes?)
	{a'^i':diff(x), a'^i':diff(y), a'^i':diff(z)}				-- via expr:toDenseTensor{indexes='i'}
		... vs ... 
	{a'^1':diff(x'^j'), a'^2':diff(x'^j'), a'^3':diff(x'^j')}	-- via expr:toDenseTensor{indexes='j'}
		... vs ...	
	{
		{a'^1':diff(x), a'^1':diff(y), a'^1':diff(z)},			-- via expr:toDenseTensor{indexes='ij'}
		{a'^2':diff(x), a'^2':diff(y), a'^2':diff(z)},			-- or just default: expr:toDenseTensor()
		{a'^3':diff(x), a'^3':diff(y), a'^3':diff(z)},
	}

This is another big TODO -- how to represent specific elements / basis expansion of a tensor?
I was originally writing it so numbers 1,2,3 would represent specific elements,
but I like the freedom of choosing a number for a name, i.e. in my 'Kaluza-Klein - index' worksheet.

One option could be to simply have no automatic system in place, but to specify a basis per-variable:

x:expandsToTensorBasis(x, y, z)
x:expandsToTensorBasis(r, theta, phi)
a:expandsToTensorBasis(ax, ay, az)

... in each case, the lhs specifies the variable that we are expecting to be used in an indexed tensor representation
... and on the rhs the variables we expect it to expand to wrt some basis of some chart of the manifold.
... maybe we could just use variables:

a:expandsToTensorBasis(a'^1', a'^2', a'^3')

... this will still require some ironing out...



but back to all of this ...
... we can do specific indexes for now:
a'^i':setDependentVars(a'^j')
that means putting :setDependentVars() in TensorRef to forward to Variable
and it means in Variable we keep track of the indexes of the 'numerator' and 'denominator' symbols
and we only preserve the derivative if we match to these 
otherwise we return zero
... and if the variable symbols are equal then we now need an official Kronecher delta symbol.

--]]
		end},

		{eval = function(prune, expr)
			if expr[1].evaluateDerivative then
				local result = expr[1]:clone()
				for i=2,#expr do
					result = prune:apply(result:evaluateDerivative(getmetatable(expr), expr[i]))
					-- failed -- bail out early
					if not result then return end
				end
				return result
			end
		end},
	},
}

return Derivative
