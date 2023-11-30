--[[
How Derivative, and diff, works:

First, user calls y:diff(x) or y:totalDiff(x) or etc for other subclasses.
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
		- for comma derivative, Tensor.Chart.tangentSpaceOperator[i]() is called


alright, comma derivative represents the partial derivative
but chain rule is especially defined in terms of the total derivative
so what is the chain rule of a partial derivative in a multivariate formula?
hmm
https://math.stackexchange.com/questions/2354875/partial-derivatives-vs-total-derivatives-for-chain-rule
https://math.stackexchange.com/questions/174270/what-exactly-is-the-difference-between-a-derivative-and-a-total-derivative

what does (Expression expr):evaluateDerivative(Variable x) do?


what kind of notation should I use:

d/dx( f(g(x)) ) = df/dg (g(x)) * dg/dx (x)


internal structure:
	self[1] is the expression
	all subsequent children are variables
--]]

local table = require 'ext.table'
local Expression = require 'symmath.Expression'

local symmath


local Derivative = Expression:subclass()
Derivative.precedence = 6

-- default is for Verbose and SymMath output
Derivative.name = 'Derivative'
Derivative.nameForExporterTable = table(Derivative.nameForExporterTable)
Derivative.nameForExporterTable.Console = '∂'
Derivative.nameForExporterTable.LaTeX = '\\partial'
Derivative.nameForExporterTable.Language = 'd'	-- used for variable name prefix

-- base class is the partial derivative
Derivative.isTotal = false

function Derivative:init(...)
	symmath = symmath or require 'symmath'
	local vars = table{...}
	local expr = assert(vars:remove(1), "can't differentiate nil")
	assert(#vars > 0, "can't differentiate against nil")
	vars:sort(function(a,b) return a.name and b.name and a.name < b.name end)
	Derivative.super.init(self, expr, table.unpack(vars))
end

Derivative.rules = {
	Prune = {

		-- same as in conj, Re, Im
		-- f({y_i}) = {f(y_i)}
		{arrays = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Array = symmath.Array
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
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			if Constant:isa(expr[1]) then
				return Constant(0)
			end
		end},

		-- d/dx d/dy = d/dxy
		{combine = function(prune, expr)
			symmath = symmath or require 'symmath'
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
			symmath = symmath or require 'symmath'
			local Variable = symmath.Variable
			local Constant = symmath.Constant
			local TensorRef = symmath.Tensor.Ref
			local Tensor = symmath.Tensor
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
				-- very ugly fix to try to make sure to insert the - sign so that d/dg_ab (g^pq) = -g^pa g^qb
				local numLowersMatch = 0
				
				--local tvar = expr[1]	-- tensor-ref of the variable
				local var = expr[1][1]	-- the variable itself
				-- dx^I/dx^J = delta^I_J
				if #expr == 2 then
					if TensorRef:isa(expr[2])
					and var == expr[2][1]
					and #expr[1] == #expr[2]	-- only matching # of symbols
					then
						-- if upper/lower differ then use delta
						-- if they match then use metric
						local deltaSymbol = Tensor:deltaSymbol()
						local metricSymbol = Tensor:metricSymbol()
						-- next, use products of the symbol per index
						local prod = table()
						for k=2,#expr[1] do
							-- dx^i/dx^j = delta^i_j, so swap the raise/lower on all the wrt indexes
							local lowersMatch = (not not expr[1][k].lower) == (not not expr[2][k].lower) 
							local symbol
							if lowersMatch then
								symbol = deltaSymbol
							else
								if var.isMetric then
									symbol = var		-- hack to allow T_ac T^cb = delta_a^b for symbols other than the :metricSymbol()
								else
									symbol = metricSymbol
								end
							end
							local index1 = expr[1][k]:clone()
							local index2 = expr[2][k]:clone()
							index2.lower = not index2.lower
							if lowersMatch then
								prod:insert(TensorRef(symbol, index1, index2))
							else
								-- [[ TODO
								-- hack for d/dg_ab (g^pq) = -g^pa g^qb
								-- for any other tensor this would just insert the metric itself, no sign change ...
								-- TODO think about this for degree other than 2 ...
								if (
									var == metricSymbol
									or var.isMetric			-- hmm cheap hack for the time being ... how to allow other tensors who have the property T_ac T^cb = delta_a^b to differentiate correctly
								)
								and #expr[1] == 3	-- only metrics, so only 2 indexes + var = 3 elements in the table
								then
									numLowersMatch = numLowersMatch + 1
								end
								--]]
								prod:insert(TensorRef(symbol, index1, index2))
							end
						end

						-- if we had a metric tensor ...
						if numLowersMatch > 0 then
							if numLowersMatch == 1 then	-- only one raised index?  means it's g_a^b = delta_a^b whose derivatives are zero
							-- TODO this is assuming i'm differentiating wrt g_ab (or maybe g^ab) ... TODO also consider what if we are differentiating wrt g_a^b = delta_a^b in which case .... .... is everything zero?
								return Constant(0)
							elseif numLowersMatch == 2 then
								prod:insert(1, Constant(-1))
							end
						end
						
						return symmath.tableToMul(prod)
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
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local Variable = symmath.Variable
			local TensorRef = symmath.Tensor.Ref
			-- apply differentiation
			-- don't do so if it's a diff of a variable that requests not to
			if Variable:isa(expr[1])
			or (
				TensorRef:isa(expr[1])
				and Variable:isa(expr[1][1])
			) then
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
honestly they should be shorthand for Tensor('_i', function(x) return x:diff(chart.coords[i]) end)
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

		-- Derivative(Integral(f, x, xL, xR), x) = f:replace(x,xR) - f:replace(x,xL)
		-- Derivative(Integral(f, x), x) = f + const
		{integrals = function(prune, expr)
			symmath = symmath or require 'symmath'
			-- Derivative(g, ...)
			local Integral = symmath.Integral
			-- if the differentiated expression is an integral ...
			local g = expr[1]
			if Integral:isa(g) then
				-- Derivative(Integral(f, x, xL, xR), ...)
				local f, x, xL, xR = table.unpack(g)
				local dxs = table.sub(expr, 2)
				-- if any of our differentiated variables are the integraed variable ...
				local i = dxs:find(x)
				if i then
					dxs:remove(i)
					local result = f
					if #dxs > 0 then
						result = Derivative(result, dxs:unpack())
					end
					if #g == 4 then
						result = result:replace(x, xR) - result:replace(x, xL)
					-- otherwise #expr == 2 I hope
					--else
						-- TODO plus some variable not present in the expression:
						--result = result + symmath.Variable'C'
					end
					return result
				end
			end
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
