## Reference

### Namespace

`symmath.setup(args)`  
`symmath(args)`  
Use this if you want to copy the symmath namespace into the global namespace.  
`args` can include the following:  
	- `implicitVars` - Set this to `true` to create a variable from any reference to an uninitialized variable. Otherwise variables must be initialized manually.  
	- `env` - The destination to copy the symmath namespace into.  Default is `_G` / the global namespace. 
	- `MathJax` - Set this to `true to enable MathJax output, to print MathJax.header, and to set a global function `printbr` for performing a typical `print` followed by a `<br>`.
		Assign `MathJax` to a table to override specific values within the `symmath.export.MathJax` singleton variable.

Using `symmath` without `symmath.setup()`.  
```
local symmath = require 'symmath'
local a, r, theta, rho, M, Q, Delta = symmath.vars('a','r','\\theta','\\rho','M','Q','\\Delta')
print(Delta:eq(r^2 + a^2 + Q^2 - 2 * M * r))
print((Delta - (r^2 + a^2)) * a * symmath.sin(theta)^2 / rho^2)
```

Using `symmath` with `symmath.setup()` but without `implicitVars` removes the need to reference the `symmath` namespace, but still requires explicit creation of variables.  
```
require 'symmath'.setup()
local a, r, theta, rho, M, Q, Delta = vars('a','r','\\theta','\\rho','M','Q','\\Delta')
print(Delta:eq(r^2 + a^2 + Q^2 - 2 * M * r))
print((Delta - (r^2 + a^2)) * a * sin(theta)^2 / rho^2)
```

Using `symmath` with `symmath.setup{implicitVars=true}` removes the need for `symmath` namespace references and the need for explicit creation of variables.  
Notice that underscores and Greek letters are automatically converted to appropriate TeX/unicode symbols.
```
require 'symmath'.setup{implicitVars=true, fixVariableNames=true}
print(Delta:eq(r^2 + a^2 + Q^2 - 2 * M * r))
print((Delta - (r^2 + a^2)) * a * sin(theta)^2 / rho^2)
```

Alternatively, you can run Lua with `-lsymmath.setup`, which is equivalent to `require 'symmath'.setup{implicitVars=true, fixVariableNames=true}`.

### Numbers

For the most part Lua numbers will work, and will automatically be replaced by symmath Constants (found in symmath.Constant).
This is because Constant is a subclass of Expression, and I was too lazy to implement all the ridiculous number of edge cases required to handle Lua numbers, though I am thinking about doing this.
Constant can be constructed with numbers (`Constant(0), Constant(1)`, etc) or with complex values (`Constant{re=1, im=0}`, etc).

Complex values can be represented by `complex`, which uses builtin complex types when run within LuaJIT, or uses a pure-Lua alternative otherwise.

Some day I will properly represent sets (naturals, integers, rationals, reals, complex, etc), and maybe groups, rings, etc, but not for now.

Some day I will also add support for infinite precision or big integers, but not right now.  Check out my BigNumber Lua library at https://github.com/thenumbernine/lua-bignumber for more on this..

### Constants

There are a few common constants in the symmath namespace:

`symmath.i` represents an imaginary unit.
`symmath.e` represents Euler's number, the natural base _e_.
`symmath.pi` represents Archimedes' constant, the ratio of a circle diameter to radius.
`symmath.inf` represents infinity.

### Variables

`var = symmath.Variable(name[, dependencies])`  
`var = symmath.var(name[, dependencies])`  
`var1, var2, ... = symmath.vars(name1, name2, ...)`  
Create a variable with given name, and optionally a list of which variables it is dependent on for differentiation. By default variables of different names have a derivative of zero.

`var:setDependentVars(var1, var2, ...)`  
Specify the variables that var is dependent on for differentiation.
`var`, `var1`, `var2`, etc can be Variables (i.e. `x`) or Tensor.Ref's (i.e. `x'^i'`).
Calling this function will clear all previous dependent vars only for the respective indexes it is called with.

`expr:dependsOn(var)`
Returns 'true' if an expression depends on the specified Variable 'var'.
Determines so by searching the expression for either the Variable itself, or any variables that are specified o depend on the Variable.
Works if 'var' is a Variables  (i.e. `x`) or if 'var' is a Tensor.Ref of a Variable (i.e. `x'^i'`).

`expr:getDependentVars()`
Get list of variables used in the expression.

`symmath.fixVariableNames = true`
Set this flag to true to have the LaTex and console outputs replace variable names with their associated unicode characters.
For example, `var'theta'` will produce a variable with the name `θ`.

### Arithmetic

`symmath.op.unm(a)`  
`-a` when used with symmath expressions  
Creates an expression representing the negative of the parameter.

`symmath.op.add(a, b)`  
`a + b` when used with symmath expressions  
Creates an expression representing the sum of the parameters.

`symmath.op.mul(a, b)`  
`a * b` when used with symmath expressions  
Creates an expression representing the product of the parameters.

`symmath.op.sub(a, b)`  
`a - b` when used with symmath expressions  
Creates an expression representing the difference of the parameters.

`symmath.op.div(a, b)`  
`a / b` when used with symmath expressions  
Creates an expression representing a fraction of the parameters.

`symmath.op.pow(a, b)`  
`a ^ b` when used with symmath expressions  
Creates an expression representing the first parameter raised to the power of the second parameter.

`symmath.op.mod(a, b)`  
`a % b` when used with symmath expressions  
Creates an expression representing the first parameter modulo the second.

### Equations

`eqn = symmath.op.eq(lhs, rhs)`  
`eqn = lhs:eq(rhs)`  
Creates an equation representing the equality lhs = rhs.

`eqn = symmath.op.ne(lhs, rhs)`  
`eqn = lhs:ne(rhs)`  
Creates an equation representing the inequality lhs ≠ rhs.

`eqn = symmath.op.lt(lhs, rhs)`  
`eqn = lhs:lt(rhs)`  
Creates an equation representing the inequality lhs < rhs.

`eqn = symmath.op.le(lhs, rhs)`  
`eqn = lhs:le(rhs)`  
Creates an equation representing the inequality lhs ≤ rhs.

`eqn = symmath.op.gt(lhs, rhs)`  
`eqn = lhs:gt(rhs)`  
Creates an equation representing the inequality lhs > rhs.

`eqn = symmath.op.ge(lhs, rhs)`  
`eqn = lhs:ge(rhs)`  
Creates an equation representing the inequality lhs ≥ rhs.

`lhs = eqn:lhs()`  
Returns the left hand side of the equation.

`rhs = eqn:rhs()`  
Returns the right hand side of the equation.

`soln1, soln2, ... = symmath.solve(eqn, var)`  
`soln1, soln2, ... = eqn:solve(var)`  
Returns solutions to the equation. If eqn is not an Equation then returns solutions to eqn = 0.

`newexpr = expr:subst(eqn)`  
Shorthand for `expr:replace(eqn:lhs(), eqn:rhs())`.

### Expression

`symmath.simplify(expr)`  
`expr:simplify()`  
`expr()`  
Simplifies the expression.

`symmath.match(exprA, exprB)
`exprA:match(exprB)`
Match one expression to another, optionally using Wildcards to match to portions of the expression tree.
See 'Wildcard' for more information on how.

`symmath.clone(expr)`  
Clones an expression.  
This also replaces Lua numbers with symmath Constant objects.  

`symmath.replace(expr, find, repl, callback)`  
`expr:replace(find, repl, callback)`  
Replaces portions of an expression with another.  
expr = expression to change.  
find = sub-expression to find.  
repl = sub-expression to replace.  
callback(node) = callback per node, returns 'true' if we don't want to find/replace this tree.  

`symmath.map(expr, callback)`  
`expr:map(callback)`  
Maps sub-expressions in an expression to new sub-expressions.  
expr = expression.  
callback(node) = callback that returns nil if it leaves the tree untouched, returns a value if it wishes to change the tree.  

`symmath.eval(expr, {[var1]=value, var2name=value, ...})`  
`expr:eval{[var1]=value, var2name=value, ...}`  
Calculates the numeric value of the expression.  

`symmath.polyCoeffs(expr, var)`  
`expr:polyCoeffs(var)`  
Returns a table of coefficients with keys 0 through the degree of the polynomial, and 'extra' containing all non-polynomial terms.  

`symmath.polydiv(a, b[, x])`
`a:polydiv(b[, x])`
Performs polynomial division `a / b`, with `x` the polynomial variable.
`x` can be inferred if only one variable is used in the `a` and `b` expressions.

### Calculus

`symmath.Limit(expr, var, limit[, side])`
`symmath.lim(expr, var, limit[, side])` 
`expr:lim(var, limit[, side])`  
Calculates the limit of the expression with respect to the specified variable, limit, and optionally side.
Side is '+' or '-', or nil for both sides.
The derivative is evaluated upon calling `simplify()`, or by shorthand calling the object one more time: `(1/x):lim(x, 0, '+')()`.

`symmath.Derivative(expr, var1, var2, ...)`  
`symmath.diff(expr, var1, var2, ...)`  
`expr:diff(var1, var2, ...)`  
Specifies the derivative of the expression with respect to the given variable(s). 
The derivative is evaluated upon calling `simplify()`, or by shorthand calling the object one more time: `expr:diff(var1, var2, ...)()`.

`symmath.Integral(expr, x[, xL, xR])`
`expr:integra(x[, xL, xR])`
Specifies the integral of the expression with respect to a variable, optionally with left and right endpoints.
The integral is evaluated upon calling `simplify()`, or by shorthand calling the object one more time: `expr:integrate(x, xL, xR)()`.

### Linear Algebra

`A = symmath.Matrix({expr11, expr12 ...}, {expr21, expr22, ...}, ...)`  
Create a matrix of expressions.  

`A = symmath.Array(...)`  
Create an array of expressions. Same deal as Matrix but with any arbitrary nesting depth, and without Matrix-specific operations.  

`dim = A:dim()`
`dim = Array.dim(A)`
Returns a table of the dimensions of the Array.

`degree = A:degree()`
`degree = Array.degree(A)`
Returns the degree of the Array, which is equal to the number of dimensions.
Ex: An Array of expressions is degree-1, an Array of Arrays of expressions is degree-2, etc.

`AInv, I, message = A:inverse([b, callback, allowRectangular])`
`AInv, I, message = A:inv([b, callback, allowRectangular])`
returns  
AInv = the inverse of matrix A.  
I = what's left of the Gauss-Jordan solver (typically the identity matrix).  
message = any error that occured during solving.  
args:  
b = solution vector.  If specified, returns x such that A x = b.  
callback = function to be called after each Gauss-Jordan operation.  
allowRectangular = set to `true` to allow inverting rectangular matrices.  

`APlus, determinable = A:pseudoInverse()`  
Returns the pseudoinverse of A (stored in APlus) and whether the pseudoinverse is determinable.  

`d = A:determinant()`  
`d = A:det()`  
Returns the determinant of A.  

`At = A:transpose()`  
`At = A:T()`  
Returns the transpose of A

`I = Matrix.identity([m, n])`  
Returns 1 if no arguments are provided.  
Returns a m x m identity matrix if one argument is provided.  
Returns a m x n identity matrix if two arguments are provided.  

`D = Matrix.diagonal(d1, d2, d3, ...)`  
Returns a n x n matrix with diagonal elements set to d1 ... dn, for n the number of arguments provided.  

`tr = A:trace()`  
Returns the trace of A.  

`N = A:nullspace()`  
Returns the nullspace of A.

`ev = A:eigen()`
Returns information pertaining to the eigendecomposition of A.
ev contains the following information:
lambdas = A table with each element containing the fields `expr` of the eigenvalue expression and `mult` of the eigenvalue multiplicity.
defective = Set to `true` if the matrix A is defective, i.e. if an eigenvalue multiplicity was greater than its associated nullspace.
allLambdas = A table of eigenvalue expressions, each repeated based on its multiplicity.
Lambda = A diagonal matrix containing the values of `allLambdas`
R = The right eigenvector matrix, whose right-eigenvectors are column vectors enumerated to match with the eigenvalues of `allLambdas`.
L = The left eigenvector matrix, whose left-eigenvectors are row vectors enumerated to match with the eigenvalues of `allLambdas`.
	`L` will not exist if `R` is not invertible (especially if the matrix is defective).

`expA = A:exp()`
Returns the matrix-exponent of A.

`Rx, Ry, Rz = table.unpack(symmath.Matrix.eulerAngles)`
Returns functions to produce the 3x3 rotation matrices around the x-, y-, and z- axis.

`Rn = symmath.Matrix.rotation(theta, n)`
Returns the 3x3 rotation matrix about axis `n[1], n[2], n[3]` by angle `theta` using the Rodrigues rotation matrix formula.

`A.rowsplits = {...}`
`A.colsplits = {...}`
Specify row and column indexes within these tables for the LaTeX exporter to insert vertical or horizontal lines in the matrix.

### Dense Tensors

`manifold = Tensor.Manifold()`
Create a Manifold object.


`chart = Tensor.Chart{coords={t,x,y,z}}`  
`chart = Tensor.Chart{coords={t,x,y,z}, manifold=manifold}`
`chart = Tensor.Chart{coords={t,x,y,z}, tangentSpaceOperators={t1, t2, ...}}`
`chart = manifold:Chart{coords={t,x,y,z}}`  
Create a Chart object associated with the Manifold will be using coordinates t,x,y,z
If no manifold is provided then the last Manifold constructed or a default Manifold object is used.
`tangentSpaceOperators` can be optionally provided.  This is a list of functions which act as the tangent space operators of the chart, and coincide with the comma derivatives of Tensors on this chart.
The default values are the derivatives of the chart coordinates `coords`.

`chart = manifold:Chart{coords={t,x,y,z}, metric=function() return g end}`
Specifies that tensors will be using coordinates t,x,y,z with metric 'g' (a Matrix or 2D array).  The metric inverse will be automatically computed.
The metric is wrapped in a function so that the chart coordinates can be established first, so that Tensor indexes will correctly be associated with the dimension of the chart.

`chart = manifold:Chart{coords={t,x,y,z}, metric=function() return g end, metricInverse=function() return gU end}`
Specifies that tensors will be using coordinates t,x,y,z with metric 'g' (a Matrix or 2D array) and metric inverse 'gU'.

`chart = manifold:Chart{symbols='ijklmn', coords={x,y,z}}`  
Specifies that tensors will use indexes `ijklmn` only with variables x,y,z.  
Notice that the association between Tensor index symbols and Charts is currently held behind the scenes.
At the moment conversion between multipoint Tensor indexes is very ugly/incomplete.

`chart:setMetric(g, [gU])`  
Specifies to use metric 'g' for the chart, and with what index symbols are associated with this chart.

`t = Tensor'_abc'`  
Creates a degree-3 covariant tensor 't' with all values initialized to 0.

... tensor summation / multiplication ...  
` ( u'^a' * v'_b' * eps'_a^bc_d' )() ` produces a degree-2 tensor perpendicular to 'u' and 'v' (assuming eps is defined as the Levi-Civita tensor).

... comma derivatives (semicolon derivatives almost there, just need to store the connection coefficients) ...  

... assignment: `S = T'_ab' - T'_ba'`  
in this case the indexes of 'S' are picked on a first-come, first-serve basis.  If you want to be  certain of the assignment, use the following: 

`S = Tensor'_ab'`  
`S['_ab'] = (T'_ab' - T'_ba')()`  
(the final `()` is shorthand for `:simplify()`, which will evaluate the expression into the tensor structure).

... index gymnastics (so long as you defined a metric): `v = Tensor('_a', ...) print(v'^a'())` will show you the contents of `v^a = g^ab v_b`.

`t:permute'_ba'`
Rearranges the internal storage of `t`, also explicity setting the upper/lower valence of each index.

`t:print't'`  
Prints the tensor's contents.  

`t:printElem't'`  
Prints the individual nonzero values of the tensor, or '0' if they are all zero.  

### Tensor Index Expressions

Indexes can be added to any expression using Lua's call + strig operator in the same way they are added to dense tensors.

`t = var't' print(t'_ij')`
Create a Tensor.Ref object dereferencing variable 't' with indexes 'i', lowered; and 'j', lowered.

`expr:reindex{from = 'to'}` 
Reindex an expression.  If the first character is a space then the indexes are assumed to be space-separated, otherwise it is assumed that each character is its own index.

`expr:tidyIndexes()`
Attempt to automatically substitute and simplify indexes, automatically determining which sum and which fixed indexes are used.

`expr:splitOffDerivIndexes()`
Separate the comma-derivative indexes into a separate Tensor.Ref, used for replace() tree matching of expressions that do not use comma derivatives.
For example: `A'_i,j':replace(A'_i', B'_i')` will fail, but `A'_i,j':splitOffDerivIndexes():replace(A'_i', B'_i')` will be successful.

`expr:simplifyMetrics()`
Automatically raise/lower expression indexes based on multiplication of whatever variable is specified by `Tensor:metricSymbol()` and Kronecher deltas specified by `Tensor:deltaSymbol()`.

`Tensor:metricSymbol()`
Returns a variable representing the metric tensor, typically the variable `g`.
This is set by writing the `Tensor.metricVariable` field.

`Tensor:deltaSymbol()`
Returns a variable representing the Kronecher delta tensor, typically the variable `δ`.
This is set by writing the `Tensor.deltaVariable` field.

`expr:insertMetricsToSetVariance(t'_ij')`
Insert metric symbols to transform the indexed variable to the required form.
If the indexed variable occurs in a different valence, such as `t'^i_j'`, then metric symbols will be inserted, i.e. `g'^ik' * t'_kj'`.

`expr:favorTensorVariance(t'_ij')`
Same as `insertmetricsToSetVariance` and then simplifying the metrics.
So `(A'_ij' * t'^i' * t'^j'):favorTensorVariance(t'_i')` will produce `A'^ij' * t'_i' * t'_j'`.

`expr:insertTransformsToSetVariance(rules)`
Generalization of `expr:insertMetricsToSetVariance()`

`fixed, summed, extra = expr:getIndexesUsed()`
Get a table of all indexes used.
`summed` = a table of indexes which are repeated, and therefore used for implicit-sums.
`fixed` = a table of indexes which appear uniquely in multiple terms.
`extra` = any other indexes.

`expr:symmetrizeIndexes(var, indexes, override)`
Symmetrize (sort) indexes that appear in Tensor.Ref's of the specified variable.
This will ignore indexes that include comma-derivatives, unless `override` is true.
Ex: 

`(g'_ab' + g'_ba'):symmetrizeIndexes(g, {1,2})` will produce `g'_ab' + g'_ab'`.

`(g'_ab,c' + g'_ac,b'):symmetrizeIndexes(g, {2,3})` will produce an error.

`(g'_ab,c' + g'_ac,b'):symmetrizeIndexes(g, {2,3}, true)` will produce `g'_ab,c' + g'_ab,c'`.

`(f'_,ab' + f'_,ba'):symmetrizeIndexes(f, {1,2})` will produce `f'_,ab' + f'_,ab'`.  No error will be produced despite comma derivatives being included in the symmetrized indexes, because all symmetrized indexes are comma derivatives and partial derivatives are commutative.
TODO / NOTE TO MYSELF: comma derivatives denote tangent basis operators, which may not be commutative in spaces that have commutation coefficients.  In which case this operation should produce an error.

`f'_,a^b':symmetrizeIndexes(f, {1,2})` will produce an error due to the fact that a raised index is included. 


### Sets

Set classes so far:
* symmath.set.Universal = This is a set that contains everything.
* symmath.set.Null = This is a set that contains nothing.
* symmath.set.Complex
* symmath.set.RealInterval = This is a single interval on the (extended) Real number line, inclusive or exclusive of its endpoints.
* symmath.set.RealSubset = This is a union of multiple RealIntervals.
* symmath.set.Integer
* symmath.set.EvenInteger
* symmath.set.OddInteger

Set singleton objects so far:
* symmath.set.universal
* symmath.set.null
* symmath.set.complex
* symmath.set.real = The extended Real set interval, (-inf, inf).
* symmath.set.negativeReal = (-inf,0)
* symmath.set.positiveReal = (0,inf)
* symmath.set.nonNegativeReal = [0,inf)
* symmath.set.nonPositiveReal = (-inf,0]
* symmath.set.integer
* symmath.set.evenInteger
* symmath.set.oddInteger

`Set:var('x', ...)`
shorthand for creating a variable associated with this set.
Ex: `x = symmath.set.positiveReal:var'x'` creates a positive real variable.

`Set:contains(x)`
returns true/false if the set contains the element.
returns nil if the answer is indeterminate.

`expr:getRealDomain()` = Returns the RealSubset object for the domain of this expression, specifying what possible values it can contain.

`expr:getRealRange()` = Returns the RealSubset object for the range of this expression, specifying what possible values it can contain.


### Plotting

`symmath.GnuPlot:plot(args)`  
Produces SVG of a plot. Requires my `lua-gnuplot` library.  
Arguments are forwarded to the `gnuplot` lua module, with the expression provided in place of the plot command.  
See the file `tests/unit/plot.lua` for examples of how to use this.

`expr:plot(args)`
Shorthand for calling GnuPlot on a single expression.  The output (text vs svg) is inferred from whatever exporter `symmath.tostring` is currently assigned to.

### Exporting / Code Generation

Exporting works with one of the many exporters in the `export` folder.

You can set the default tostring to one of the methods:

`symmath.tostring = symmath.export.SingleLine`

The default tostring exporter is MultiLine.

Valid output exporters are: 
* LaTeX - LaTeX math expression.
* MathJax - This is a subclass of LaTeX, which additionally provides header and footer for html document generation.
* MultiLine - Multi-line console output.
* SingleLine - Single-line text / console ouptut.
* SymMath - Serialize back into Lua code for generating the expression.
* Verbose - Useful for debugging the contents of an expression tree.
Valid language exporters are:
* C - C code.
* GnuPlot - Gnuplot formula.
* JavaScript - JavaScript code.
* Lua - Lua code.
* Mathematica - Mathematica code.

Any of the above exporters can be used with `symmath.tostring` to change the default string conversion.

Any of them can also be manually invoked by calling the exporter with the expression.  For example:
`symmath.export.Lua(symmath.var'x'^3/3)` will produce the string `((x ^ 3.0) / 3.0)`. 
`symmath.export.LaTeX(symmath.var'x'^3/3)` will produce the string `${\frac{1}{3}}{({{x}^{3}})}$`.


Language exporters have a few extra functions for code generation:

`Exporter:toCode(args)`
`args` can include the following:
	- `input = {var1, var2, {name3=var3}, ...}` - contains a list of input variables, or maps from variables to variable names to use within the code. For function code generation, this is the list of generated function parameters.
	- `output = {expr1, expr2, {name3=expr3}, ...}` - contains a list of expression which we are producing the code for.
	- `notmp` - set this to `true` to disable generation of temporary variables used to reduce calculations of repeated portions of the expression.
	- `dontExpandIntegerPowers` - set this to `true` to disable the expanding of integer powers, and to instead use the language's builtin `pow` function.

`Exporter:toFuncCode(args)`
`args` is the same as `toCode`, with some additions:
	- `func` - the name of the function that is generated.

`expr:nameForExporter(exporter, name)` = sets the name of this variable / function to `name` but only for the specified exporter.
When determining a function name, a variable / function will respect an exporter's inheritence.

Some specific options per exporter:

`Lua:toFunc(args)`
`args` is the same as `toFuncCode`, with the exception that the name is ignored.
This is shorthand for Lua alone for generating the function code and compiling it into a Lua function object.

The Lua exporter's function generation can be accessed shorthand:

`func, code = symmath.compile(expr, {var1, var2, ...})`  
`func, code = expr:compile{var1, var2, ...}`  
Compiles an expression to a Lua function with the listed vars as parameters.  


`LaTeX.openSymbol = '$'`
`LaTeX.closeSymbol = '$'`
Change the characters wrapping LaTeX expressions.

LaTeX.matrixLeftSymbol = '\\left['
LaTeX.matrixRightSymbol = '\\right]'
LaTeX.matrixBeginSymbol = '\\begin{matrix}'
LaTeX.matrixEndSymbol = '\\end{matrix}'
Change the characters wrapping matrices in LaTeX.

`LaTeX.showDivConstAsMulFrac = true`
When this is true, fractions with expressions in the numerator and nothing but a constant in the denominator are rewritten as having a leading 1/constant multiplied by the expression.
Set this to false to always produce fractions as they are.

`LaTeX.showExpAsFunction = true`
By default symmath represents exp(x) as e^x, so when exporting expressions it will produce e^x instead of exp(x).  This flag lets you choose which output method to use.

LaTeX.parOpenSymbol = '\\left('
LaTeX.parCloseSymbol = '\\right)'
Change the opening and closing symbols for parenthesis.

`LaTeX.powWrapExpInParenthesis = false`
Whether to wrap an exponent's exponent in parenthesis if the precedence of operators says so.

Notice that subclasses are copied upon construction rather than referenced by dynamic lookup as in other languages.  This means that, while these options exist in subclasses, changing the parent class static members will not change the subclass static members.    You must change subclass static members.  For example, export.MathJax is a subclass of export.LaTeX.  If you are using the MathJax exporter and you want to change the openSymbol, closeSymbol, etc then you must modify MathJax.openSymbol and not LaTeX.openSymbol.



Examples of exporters:

```
> export.Lua:toCode{output={x^3/3}}
local out1 = ((x * (x * x)) / 3.0)

> export.Lua:toCode{output={{result=x^3/3}}}
local result = ((x * (x * x)) / 3.0)

> export.Lua:toCode{input={x}, output={x^3/3}}
local out1 = ((x * (x * x)) / 3.0)

> export.Lua:toCode{input={{y=x}}, output={x^3/3}}
local out1 = ((y * (y * y)) / 3.0)

> export.Lua:toFuncCode{input={x}, output={x^3/3}}
function f(x)
        local out1 = ((x * (x * x)) / 3.0)
        return out1
end

> export.Lua:toFuncCode{func='generated', input={{y=x}}, output={x^3/3}}
function generated(y)
        local out1 = ((y * (y * y)) / 3.0)
        return out1
end

> export.Lua:toFuncCode{input={{y=x}}, output={{result=x^3/3}}}
function f(y)
        local result = ((y * (y * y)) / 3.0)
        return result
end

> export.C:toCode{output={{result=x^3/3}}}
double result = (x * x * x) / 3.0;

> export.C:toFuncCode{input={x}, output={{result=x^3/3}}}
void f(double* out, double x) {
        double result = (x * x * x) / 3.0;
        out[0] = result;
}

> export.C:toCode{output={x^2/2 + sin(x^2)}}
double tmp1 = x * x;
double out1 = sin(tmp1) + tmp1 / 2.0;

> export.C:toCode{output={x^2/2 + sin(x^2)}, notmp=true}
double out1 = (x * x) / 2.0 + sin(x * x);
```

### Wildcard

`symmath.Wildcard(args)`
This constructs a Wildcard object for Expression matching.
`args` can be any of the following:
- A number, which specifies the Wildcard index.
- A table with the following:
- - index = The wildcard index.  Optionally the first argument of the table can also specify the index.
- - atLeast = The wildcard must match at least this many sub-expressions, if matching within variable-children expressions (such as + and * )
- - atMost = The wildcard can only match at most this many sub-expressions.
- - dependsOn = The wildcard must depend on the specified variable.  See 'Expression:dependsOn()' for more information.
- - cannotDependOn = The wildcard must not depend on the specified variable.  See 'Expression:dependsOn()' for more information.

Matching works something like this:
```
local i = (x + y):match(x + Wildcard(1))
assert(i == y)
```

The index of the wildcard specifies which return argument the matched expression will be returned in.
If two present wildcards have equal indexes then the test will only succeed if both wildcard matches are equal. 
i.e. `(x + y):match(Wildcard(1) + Wildcard(1))` will fail because x != y,
but `(x + x):match(Wildcard(1) + Wildcard(1))` will succeed and return `x`.

Wildcards are greedy-matching and will match zero-or-more expressions unless stated otherwise.
For example:
```
local i,j = (x + y):match(Wildcard(1) + Wildcard(2))
assert(i == x + y)
assert(j == zero)
```
The first wildcard will greedily match both sub-expressions, unless stated otherwise:
```
local i,j = (x + y):match(W{1, atMost=1} + W{2, atMost=1})
assert(i == x)
assert(j == y)
```
In this case we specified 'atMost=1' to ensure that no single wildcard  would match to both elements.

In the case of addition, unmatched wildcards will be assigned a value of 0.
In the case of multiplication, unmatched wildcards will be assigned a value of 1.


