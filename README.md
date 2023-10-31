# Symbolic Math library for Lua

[![Donate via Stripe](https://img.shields.io/badge/Donate-Stripe-green.svg)](https://buy.stripe.com/00gbJZ0OdcNs9zi288)<br>
[![Donate via Bitcoin](https://img.shields.io/badge/Donate-Bitcoin-green.svg)](bitcoin:37fsp7qQKU8XoHZGRQvVzQVP8FrEJ73cSJ)<br>

## Live Demo

http://christopheremoore.net/symbolic-lua

## TLDR

``` lua
#!/usr/bin/env lua
require 'ext'
require 'symmath'.setup{implicitVars=true, fixVariableNames=true}
local chart = Tensor.Chart{coords={r,theta,phi}}
u = Tensor('^I', r*sin(theta)*cos(phi), r*sin(theta)*sin(phi), r*cos(theta))
print('u^I:\n'..u)
e = u'^I_,a'():permute'_a^I'
print('e_a^I:\n'..e)
delta = Tensor('_IJ', table.unpack(Matrix.identity(3)))
print('delta_IJ:\n'..delta)
g = (e'_a^I' * e'_b^J' * delta'_IJ')()
print('g_ab:\n'..g)
chart:setMetric(g)
dg = g'_ab,c'():permute'_cab'
print('g_ab,c:\n'..dg)
GammaL = ((g'_ab,c' + g'_ac,b' - g'_bc,a')/2)():permute'_abc'
print('Gamma_abc:\n'..GammaL)
Gamma = GammaL'^a_bc'()
print('Gamma^a_bc:\n'..Gamma)
dGamma = Gamma'^a_bc,d'():permute'_d^a_bc'
print('Gamma^a_bc,d:\n'..dGamma)
Riemann = (Gamma'^a_db,c' - Gamma'^a_cb,d' + Gamma'^a_ce' * Gamma'^e_db' - Gamma'^a_de' * Gamma'^e_cb')()():permute'^a_bcd'
print('Riemann^a_bcd:\n'..Riemann)

```

...makes this...

```
u^I:
         ^I↓         
┌                   ┐
│r * sin(θ) * cos(φ)│
│                   │
│r * sin(θ) * sin(φ)│
│                   │
│     r * cos(θ)    │
└                   ┘
e_a^I:
                           _a↓^I→                           
┌                                                          ┐
│    sin(θ) * cos(φ)       sin(θ) * sin(φ)        cos(θ)   │
│                                                          │
│  r * cos(θ) * cos(φ)   r * cos(θ) * sin(φ)   - r * sin(θ)│
│                                                          │
│ - r * sin(θ) * sin(φ)  r * sin(θ) * cos(φ)        0      │
└                                                          ┘
delta_IJ:
 _I↓_J→  
┌       ┐
│1  0  0│
│       │
│0  1  0│
│       │
│0  0  1│
└       ┘
g_ab:
                 _a↓_b→                  
┌                                       ┐
│1   0                  0               │
│                                       │
│    2                                  │
│0  r                   0               │
│                                       │
│        2                              │
│0   0  r  * (1 + cos(θ)) * (1 - cos(θ))│
└                                       ┘
g_ab,c:
           _c↓[_a↓_b→]            
┌                                ┐
│             _a↓_b→             │
│   ┌                         ┐  │
│   │0    0           0       │  │
│   │                         │  │
│   │0  2 * r         0       │  │
│   │                         │  │
│   │                        2│  │
│   │0    0    2 * r * sin(θ) │  │
│   └                         ┘  │
│                                │
│             _a↓_b→             │
│┌                              ┐│
││0  0              0           ││
││                              ││
││0  0              0           ││
││                              ││
││           2                  ││
││0  0  2 * r  * cos(θ) * sin(θ)││
│└                              ┘│
│                                │
│             _a↓_b→             │
│            ┌       ┐           │
│            │0  0  0│           │
│            │       │           │
│            │0  0  0│           │
│            │       │           │
│            │0  0  0│           │
│            └       ┘           │
└                                ┘
Gamma_abc:
                        _a↓[_b↓_c→]                        
┌                                                         ┐
│                         _b↓_c→                          │
│                 ┌                     ┐                 │
│                 │0   0         0      │                 │
│                 │                     │                 │
│                 │0  -r         0      │                 │
│                 │                     │                 │
│                 │                    2│                 │
│                 │0   0   - r * sin(θ) │                 │
│                 └                     ┘                 │
│                                                         │
│                         _b↓_c→                          │
│             ┌                             ┐             │
│             │0  r             0           │             │
│             │                             │             │
│             │r  0             0           │             │
│             │                             │             │
│             │          2                  │             │
│             │0  0   - r  * sin(θ) * cos(θ)│             │
│             └                             ┘             │
│                                                         │
│                         _b↓_c→                          │
│┌                                                       ┐│
││                                                  2    ││
││     0                 0                r * sin(θ)     ││
││                                                       ││
││                                    2                  ││
││     0                 0           r  * cos(θ) * sin(θ)││
││                                                       ││
││          2   2                                        ││
││r * sin(θ)   r  * cos(θ) * sin(θ)            0         ││
│└                                                       ┘│
└                                                         ┘
Gamma^a_bc:
          ^a↓[_b↓_c→]           
┌                              ┐
│    ┌                     ┐   │
│    │0   0         0      │   │
│    │                     │   │
│    │0  -r         0      │   │
│    │                     │   │
│    │                    2│   │
│    │0   0   - r * sin(θ) │   │
│    └                     ┘   │
│                              │
│┌                            ┐│
││      1                     ││
││ 0   ╶─╴           0        ││
││      r                     ││
││                            ││
││ 1                          ││
││╶─╴   0            0        ││
││ r                          ││
││                            ││
││ 0    0    - cos(θ) * sin(θ)││
│└                            ┘│
│                              │
│   ┌                       ┐  │
│   │                   1   │  │
│   │ 0       0        ╶─╴  │  │
│   │                   r   │  │
│   │                       │  │
│   │                cos(θ) │  │
│   │ 0       0     ╶──────╴│  │
│   │                sin(θ) │  │
│   │                       │  │
│   │ 1    cos(θ)           │  │
│   │╶─╴  ╶──────╴      0   │  │
│   │ r    sin(θ)           │  │
│   └                       ┘  │
└                              ┘
Gamma^a_bc,d:
                                        _d↓^a→[_b↓_c→]                                        
┌                                                                                            ┐
│                                            _b↓_c→                       _b↓_c→             │
│                                     ┌                   ┐        ┌                   ┐     │
│                                     │              1    │        │                 1 │     │
│              _b↓_c→                 │            ╶──╴   │        │               ╶──╴│     │
│        ┌                 ┐          │   0      -   2   0│        │   0     0   -   2 │     │
│        │0   0       0    │          │             r     │        │                r  │     │
│        │                 │          │                   │        │                   │     │
│        │0  -1       0    │          │     1             │        │   0     0     0   │     │
│        │                 │          │   ╶──╴            │        │                   │     │
│        │                2│          │ -   2      0     0│        │     1             │     │
│        │0   0   - sin(θ) │          │    r              │        │   ╶──╴            │     │
│        └                 ┘          │                   │        │ -   2   0     0   │     │
│                                     │   0        0     0│        │    r              │     │
│                                     └                   ┘        └                   ┘     │
│                                                                                            │
│                                                                         _b↓_c→             │
│                                                             ┌                             ┐│
│                                                             │0        0             0     ││
│              _b↓_c→                        _b↓_c→           │                             ││
│┌                                ┐  ┌                     ┐  │                        1    ││
││0  0               0            │  │0  0         0       │  │                    ╶───────╴││
││                                │  │                     │  │0        0        -        2 ││
││0  0               0            │  │0  0         0       │  │                     sin(θ)  ││
││                                │  │                     │  │                             ││
││0  0   - 2 * r * cos(θ) * sin(θ)│  │                    2│  │          1                  ││
│└                                ┘  │0  0  1 - 2 * cos(θ) │  │      ╶───────╴              ││
│                                    └                     ┘  │0   -        2         0     ││
│                                                             │       sin(θ)                ││
│                                                             └                             ┘│
│                                                                                            │
│              _b↓_c→                        _b↓_c→                       _b↓_c→             │
│             ┌       ┐                     ┌       ┐                    ┌       ┐           │
│             │0  0  0│                     │0  0  0│                    │0  0  0│           │
│             │       │                     │       │                    │       │           │
│             │0  0  0│                     │0  0  0│                    │0  0  0│           │
│             │       │                     │       │                    │       │           │
│             │0  0  0│                     │0  0  0│                    │0  0  0│           │
│             └       ┘                     └       ┘                    └       ┘           │
└                                                                                            ┘
Riemann^a_bcd:
         ^a↓_b→[_c↓_d→]          
┌                               ┐
│ _c↓_d→     _c↓_d→     _c↓_d→  │
│┌       ┐  ┌       ┐  ┌       ┐│
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
│└       ┘  └       ┘  └       ┘│
│                               │
│ _c↓_d→     _c↓_d→     _c↓_d→  │
│┌       ┐  ┌       ┐  ┌       ┐│
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
│└       ┘  └       ┘  └       ┘│
│                               │
│ _c↓_d→     _c↓_d→     _c↓_d→  │
│┌       ┐  ┌       ┐  ┌       ┐│
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
│└       ┘  └       ┘  └       ┘│
└                               ┘

```

## Goals

- Everything done in pure Lua / Lua syntax.  No/minimal parsing.
- Originally intended for computational physics.  Implement equations in Lua, perform symbolic manipulation, generate functions (via symmath.compile)

Online demo and API at http://christopheremoore.net/symbolic-lua  
Example used at http://christopheremoore.net/metric  
	and http://christopheremoore.net/gravitational-wave-simulation  

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
``` lua
local symmath = require 'symmath'
local a, r, theta, rho, M, Q, Delta = symmath.vars('a','r','\\theta','\\rho','M','Q','\\Delta')
print(Delta:eq(r^2 + a^2 + Q^2 - 2 * M * r))
print((Delta - (r^2 + a^2)) * a * symmath.sin(theta)^2 / rho^2)
```

Using `symmath` with `symmath.setup()` but without `implicitVars` removes the need to reference the `symmath` namespace, but still requires explicit creation of variables.  
``` lua
require 'symmath'.setup()
local a, r, theta, rho, M, Q, Delta = vars('a','r','\\theta','\\rho','M','Q','\\Delta')
print(Delta:eq(r^2 + a^2 + Q^2 - 2 * M * r))
print((Delta - (r^2 + a^2)) * a * sin(theta)^2 / rho^2)
```

Using `symmath` with `symmath.setup{implicitVars=true}` removes the need for `symmath` namespace references and the need for explicit creation of variables.  
Notice that underscores and Greek letters are automatically converted to appropriate TeX/unicode symbols.
``` lua
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

`var = symmath.Variable(name[, dependencies[, value[, set]]])`  
`var = symmath.var(name[, dependencies])`  
`var1, var2, ... = symmath.vars(name1, name2, ...)`  
Create a variable.
- name = The variable's given name.
- dependencies = A list of which variables it is dependent on for differentiation.  By default variables of different names have a derivative of zero.
- value = You can also specify a value to be inserted during code generation.
- set = Which set the variable belongs to.  By default this is `symmath.set.default`, which is assigned to `symmath.set.real`.  An easier way to create variables from sets is using the `symmath.set.X:var(...)` function.

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

`Ah = A:hermitian()`  
`Ah = A:H()`  
Returns the Hermitian of A

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

`symmath.set.default` = The default set that Variables are associated with.  This is initialized to `symmath.set.real`.


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

``` lua
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
``` lua
local i = (x + y):match(x + Wildcard(1))
assert(i == y)
```

The index of the wildcard specifies which return argument the matched expression will be returned in.
If two present wildcards have equal indexes then the test will only succeed if both wildcard matches are equal. 
i.e. `(x + y):match(Wildcard(1) + Wildcard(1))` will fail because x != y,
but `(x + x):match(Wildcard(1) + Wildcard(1))` will succeed and return `x`.

Wildcards are greedy-matching and will match zero-or-more expressions unless stated otherwise.
For example:
``` lua
local i,j = (x + y):match(Wildcard(1) + Wildcard(2))
assert(i == x + y)
assert(j == zero)
```
The first wildcard will greedily match both sub-expressions, unless stated otherwise:
``` lua
local i,j = (x + y):match(W{1, atMost=1} + W{2, atMost=1})
assert(i == x)
assert(j == y)
```
In this case we specified 'atMost=1' to ensure that no single wildcard  would match to both elements.

In the case of addition, unmatched wildcards will be assigned a value of 0.
In the case of multiplication, unmatched wildcards will be assigned a value of 1.




## Dependencies

- https://github.com/thenumbernine/lua-ext
- https://github.com/thenumbernine/complex-lua
- https://github.com/thenumbernine/lua-gnuplot (optionally, for plotting graphs)
- 'utf8' if available.  Used by console-based output methods.
- 'ffi' if available.

Some of the tests depend on these:

- https://github.com/thenumbernine/lua-matrix
- https://github.com/thenumbernine/solver-lua
- https://github.com/thenumbernine/vec-lua

make\_README.lua uses (for building the README.md):

- LuaSocket, for its URL building functions.

## Environment / Lua Path

You will notice that, if you use the repository as-is, that the 'symmath.lua' file is out of place.
How to get around this:
1. Use the rockspec with luarocks to install this as a luarock.  This will put correct files in correct locations.  Problem solved.
2. Move symmath.lua into the parent directory.  This clutters things but also solves the problem.
3. Modify your LUA\_PATH / package.path to also include `"?/?.lua"`.
4. ... profit?

## SymMath Interpreter

If you want to run this as a command-line with the API in global namespace:

` symmath.sh `:
``` bash
#!/usr/bin/env sh
if [ $# = 0 ]
then
	lua -lext -lsymmath.setup
else
	lua -lext -lsymmath.setup -e "$@"
fi
```

` symmath.bat `:
``` batch
@echo off
if not [%1]==[] goto interactive
lua -lext -lsymmath.setup
echo this line is unreachable
:interactive
lua -lext -lsymmath.setup -e %*
```

Then run with

``` sh
symmath " print ( Matrix { { u ^ 2 + 1, u * v } , { u * v , v ^ 2 + 1 } } : inverse ( ) ) "
```

## SymMath Local Browser Interface

This is a WIP.

Setting the `SYMMATH_PATH` to the base directory of Symmath is required.

Then cd to the dir of the worksheet you want to work on, and run `$SYMMATH_PATH/server/standalone.lua`

This requires my lua-http project in order to run.

## TODO

- better conditions for solving equalities.  multiple sets of equations.

- more integrals that will evaluate.

- functions that lua has that I don't: ceil, floor, deg, rad, fmod, frexp, log10, min, max

- infinite precision or big integers.  https://github.com/thenumbernine/lua-bignumber .

- combine symmath with the lua-parser to decompile lua code -> ast -> symmath, perform symbolic differentiation on it, then recompile it ...
	i.e. `f = [[function(x) return x^2 end]] g = symmath:luaDiff(f, 'x') <=> g = [[function(x) return 2*x end]]`

- subindexes, so you can store a tensor of tensors: `g_ab = Tensor('_ab', {-alpha^2+beta^2, beta_j}, {beta_i, gamma_ij})`

- change canonical form from 'div add sub mul' to 'add sub mul div'.  also split apart div mul's into mul divs and then factor add mul's into mul add's for simplification of fractions

- finish Integer and Rational sets, maybe better support for Complex set.

- better polynomial factoring.

- I am thinking my constantly changing sqrts to fraction powers and back is slowing things down.  How about instead a better "isSqrt" or "getEquivPower" test that both sqrt(), cbrt(), and pow() all implement?

- browser interface: "continue" feature, to counter-balance the "stop" cells
- browser interface: "stop" cells should hide their input box.
- browser interface: "undo" and "redo" buttons
- browser interface: "find" function
- browser interface: line numbers, better line wrap detection, syntax highlighting


Output Examples:

[tests/output/ADM Levi-Civita](https://thenumbernine.github.io/symmath/tests/output/ADM%20Levi%2dCivita.html)

[tests/output/ADM formalism](https://thenumbernine.github.io/symmath/tests/output/ADM%20formalism.html)

[tests/output/ADM gravity using expressions](https://thenumbernine.github.io/symmath/tests/output/ADM%20gravity%20using%20expressions.html)

[tests/output/ADM metric - mixed](https://thenumbernine.github.io/symmath/tests/output/ADM%20metric%20%2d%20mixed.html)

[tests/output/ADM metric](https://thenumbernine.github.io/symmath/tests/output/ADM%20metric.html)

[tests/output/Alcubierre](https://thenumbernine.github.io/symmath/tests/output/Alcubierre.html)

[tests/output/BSSN - generate - cartesian](https://thenumbernine.github.io/symmath/tests/output/BSSN%20%2d%20generate%20%2d%20cartesian.html)

[tests/output/BSSN - generate - spherical - LambdaBar 2](https://thenumbernine.github.io/symmath/tests/output/BSSN%20%2d%20generate%20%2d%20spherical%20%2d%20LambdaBar%202.html)

[tests/output/BSSN - generate - spherical - LambdaBar 3](https://thenumbernine.github.io/symmath/tests/output/BSSN%20%2d%20generate%20%2d%20spherical%20%2d%20LambdaBar%203.html)

[tests/output/BSSN - generate - spherical - LambdaBar](https://thenumbernine.github.io/symmath/tests/output/BSSN%20%2d%20generate%20%2d%20spherical%20%2d%20LambdaBar.html)

[tests/output/BSSN - generate - spherical](https://thenumbernine.github.io/symmath/tests/output/BSSN%20%2d%20generate%20%2d%20spherical.html)

[tests/output/BSSN - generate](https://thenumbernine.github.io/symmath/tests/output/BSSN%20%2d%20generate.html)

[tests/output/BSSN - index - cache](https://thenumbernine.github.io/symmath/tests/output/BSSN%20%2d%20index%20%2d%20cache.html)

[tests/output/BSSN - index](https://thenumbernine.github.io/symmath/tests/output/BSSN%20%2d%20index.html)

[tests/output/Building Curvature by ADM](https://thenumbernine.github.io/symmath/tests/output/Building%20Curvature%20by%20ADM.html)

[tests/output/Divergence Theorem in curvilinear coordinates](https://thenumbernine.github.io/symmath/tests/output/Divergence%20Theorem%20in%20curvilinear%20coordinates.html)

[tests/output/EFE discrete solution - 1-var](https://thenumbernine.github.io/symmath/tests/output/EFE%20discrete%20solution%20%2d%201%2dvar.html)

[tests/output/EFE discrete solution - 2-var](https://thenumbernine.github.io/symmath/tests/output/EFE%20discrete%20solution%20%2d%202%2dvar.html)

[tests/output/Einstein field equations - expression](https://thenumbernine.github.io/symmath/tests/output/Einstein%20field%20equations%20%2d%20expression.html)

[tests/output/Ernst](https://thenumbernine.github.io/symmath/tests/output/Ernst.html)

[tests/output/Euler Angles in Higher Dimensions](https://thenumbernine.github.io/symmath/tests/output/Euler%20Angles%20in%20Higher%20Dimensions.html)

[tests/output/Euler fluid equations - flux eigenvectors](https://thenumbernine.github.io/symmath/tests/output/Euler%20fluid%20equations%20%2d%20flux%20eigenvectors.html)

[tests/output/Euler fluid equations - primitive form](https://thenumbernine.github.io/symmath/tests/output/Euler%20fluid%20equations%20%2d%20primitive%20form.html)

[tests/output/FLRW](https://thenumbernine.github.io/symmath/tests/output/FLRW.html)

[tests/output/Faraday tensor in general relativity](https://thenumbernine.github.io/symmath/tests/output/Faraday%20tensor%20in%20general%20relativity.html)

[tests/output/Faraday tensor in special relativity](https://thenumbernine.github.io/symmath/tests/output/Faraday%20tensor%20in%20special%20relativity.html)

[tests/output/FiniteVolume](https://thenumbernine.github.io/symmath/tests/output/FiniteVolume.html)

[tests/output/GLM-Maxwell equations - flux eigenvectors](https://thenumbernine.github.io/symmath/tests/output/GLM%2dMaxwell%20equations%20%2d%20flux%20eigenvectors.html)

[tests/output/Gravitation 16.1 - dense](https://thenumbernine.github.io/symmath/tests/output/Gravitation%2016.1%20%2d%20dense.html)

[tests/output/Gravitation 16.1 - expression](https://thenumbernine.github.io/symmath/tests/output/Gravitation%2016.1%20%2d%20expression.html)

[tests/output/Gravitation 16.1 - mixed](https://thenumbernine.github.io/symmath/tests/output/Gravitation%2016.1%20%2d%20mixed.html)

[tests/output/KOE](https://thenumbernine.github.io/symmath/tests/output/KOE.html)

[tests/output/Kaluza-Klein - dense](https://thenumbernine.github.io/symmath/tests/output/Kaluza%2dKlein%20%2d%20dense.html)

[tests/output/Kaluza-Klein - index](https://thenumbernine.github.io/symmath/tests/output/Kaluza%2dKlein%20%2d%20index.html)

[tests/output/Kaluza-Klein - real world values](https://thenumbernine.github.io/symmath/tests/output/Kaluza%2dKlein%20%2d%20real%20world%20values.html)

[tests/output/Kaluza-Klein - varying scalar field - index](https://thenumbernine.github.io/symmath/tests/output/Kaluza%2dKlein%20%2d%20varying%20scalar%20field%20%2d%20index.html)

[tests/output/Kerr metric of Earth](https://thenumbernine.github.io/symmath/tests/output/Kerr%20metric%20of%20Earth.html)

[tests/output/Kerr-Schild - dense](https://thenumbernine.github.io/symmath/tests/output/Kerr%2dSchild%20%2d%20dense.html)

[tests/output/Kerr-Schild - expression](https://thenumbernine.github.io/symmath/tests/output/Kerr%2dSchild%20%2d%20expression.html)

[tests/output/Kerr-Schild degenerate case](https://thenumbernine.github.io/symmath/tests/output/Kerr%2dSchild%20degenerate%20case.html)

[tests/output/Lorentz group](https://thenumbernine.github.io/symmath/tests/output/Lorentz%20group.html)

[tests/output/MHD - flux eigenvectors](https://thenumbernine.github.io/symmath/tests/output/MHD%20%2d%20flux%20eigenvectors.html)

[tests/output/MHD inverse](https://thenumbernine.github.io/symmath/tests/output/MHD%20inverse.html)

[tests/output/MHD symmetrization](https://thenumbernine.github.io/symmath/tests/output/MHD%20symmetrization.html)

[tests/output/MakeTrigLookupTables](https://thenumbernine.github.io/symmath/tests/output/MakeTrigLookupTables.html)

[tests/output/Maxwell equations - flux eigenvectors](https://thenumbernine.github.io/symmath/tests/output/Maxwell%20equations%20%2d%20flux%20eigenvectors.html)

[tests/output/Navier-Stokes-Wilcox - flux eigenvectors](https://thenumbernine.github.io/symmath/tests/output/Navier%2dStokes%2dWilcox%20%2d%20flux%20eigenvectors.html)

[tests/output/Newton method](https://thenumbernine.github.io/symmath/tests/output/Newton%20method.html)

[tests/output/Platonic Solids](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids.html)

[tests/output/Platonic Solids/120-cell](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/120%2dcell.html)

[tests/output/Platonic Solids/16-cell](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/16%2dcell.html)

[tests/output/Platonic Solids/24-cell](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/24%2dcell.html)

[tests/output/Platonic Solids/5-cell](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/5%2dcell.html)

[tests/output/Platonic Solids/600-cell transforms 1](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%201.html)

[tests/output/Platonic Solids/600-cell transforms 10](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2010.html)

[tests/output/Platonic Solids/600-cell transforms 11](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2011.html)

[tests/output/Platonic Solids/600-cell transforms 12](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2012.html)

[tests/output/Platonic Solids/600-cell transforms 13](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2013.html)

[tests/output/Platonic Solids/600-cell transforms 14](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2014.html)

[tests/output/Platonic Solids/600-cell transforms 15](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2015.html)

[tests/output/Platonic Solids/600-cell transforms 16](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2016.html)

[tests/output/Platonic Solids/600-cell transforms 17](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2017.html)

[tests/output/Platonic Solids/600-cell transforms 18](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2018.html)

[tests/output/Platonic Solids/600-cell transforms 19](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2019.html)

[tests/output/Platonic Solids/600-cell transforms 2](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%202.html)

[tests/output/Platonic Solids/600-cell transforms 20](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%2020.html)

[tests/output/Platonic Solids/600-cell transforms 3](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%203.html)

[tests/output/Platonic Solids/600-cell transforms 4](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%204.html)

[tests/output/Platonic Solids/600-cell transforms 5](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%205.html)

[tests/output/Platonic Solids/600-cell transforms 6](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%206.html)

[tests/output/Platonic Solids/600-cell transforms 7](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%207.html)

[tests/output/Platonic Solids/600-cell transforms 8](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%208.html)

[tests/output/Platonic Solids/600-cell transforms 9](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20transforms%209.html)

[tests/output/Platonic Solids/600-cell vertex inner products](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20vertex%20inner%20products.html)

[tests/output/Platonic Solids/600-cell vertex multiplication table](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20vertex%20multiplication%20table.html)

[tests/output/Platonic Solids/600-cell vertexes](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell%20vertexes.html)

[tests/output/Platonic Solids/600-cell](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/600%2dcell.html)

[tests/output/Platonic Solids/8-cell](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/8%2dcell.html)

[tests/output/Platonic Solids/Cube](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/Cube.html)

[tests/output/Platonic Solids/Dodecahedron](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/Dodecahedron.html)

[tests/output/Platonic Solids/Icosahedron](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/Icosahedron.html)

[tests/output/Platonic Solids/Octahedron](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/Octahedron.html)

[tests/output/Platonic Solids/Tetrahedron](https://thenumbernine.github.io/symmath/tests/output/Platonic%20Solids/Tetrahedron.html)

[tests/output/SRHD](https://thenumbernine.github.io/symmath/tests/output/SRHD.html)

[tests/output/SRHD_1D](https://thenumbernine.github.io/symmath/tests/output/SRHD_1D.html)

[tests/output/Schwarzschild - isotropic](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20isotropic.html)

[tests/output/Schwarzschild - spherical - derivation - varying time 2](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20spherical%20%2d%20derivation%20%2d%20varying%20time%202.html)

[tests/output/Schwarzschild - spherical - derivation - varying time](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20spherical%20%2d%20derivation%20%2d%20varying%20time.html)

[tests/output/Schwarzschild - spherical - derivation](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20spherical%20%2d%20derivation.html)

[tests/output/Schwarzschild - spherical - mass varying with time](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20spherical%20%2d%20mass%20varying%20with%20time.html)

[tests/output/Schwarzschild - spherical](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20spherical.html)

[tests/output/Shallow Water equations - flux eigenvectors](https://thenumbernine.github.io/symmath/tests/output/Shallow%20Water%20equations%20%2d%20flux%20eigenvectors.html)

[tests/output/TOV](https://thenumbernine.github.io/symmath/tests/output/TOV.html)

[tests/output/Z4 - flux PDE noSource usingOnlyUs](https://thenumbernine.github.io/symmath/tests/output/Z4%20%2d%20flux%20PDE%20noSource%20usingOnlyUs.html)

[tests/output/Z4](https://thenumbernine.github.io/symmath/tests/output/Z4.html)

[tests/output/black hole brain](https://thenumbernine.github.io/symmath/tests/output/black%20hole%20brain.html)

[tests/output/console_spherical_metric](https://thenumbernine.github.io/symmath/tests/output/console_spherical_metric.html)

[tests/output/electrovacuum/black hole electron](https://thenumbernine.github.io/symmath/tests/output/electrovacuum/black%20hole%20electron.html)

[tests/output/electrovacuum/general case](https://thenumbernine.github.io/symmath/tests/output/electrovacuum/general%20case.html)

[tests/output/electrovacuum/infinite wire no charge](https://thenumbernine.github.io/symmath/tests/output/electrovacuum/infinite%20wire%20no%20charge.html)

[tests/output/electrovacuum/infinite wire](https://thenumbernine.github.io/symmath/tests/output/electrovacuum/infinite%20wire.html)

[tests/output/electrovacuum/uniform field - Cartesian](https://thenumbernine.github.io/symmath/tests/output/electrovacuum/uniform%20field%20%2d%20Cartesian.html)

[tests/output/electrovacuum/uniform field - cylindrical](https://thenumbernine.github.io/symmath/tests/output/electrovacuum/uniform%20field%20%2d%20cylindrical.html)

[tests/output/electrovacuum/uniform field - spherical](https://thenumbernine.github.io/symmath/tests/output/electrovacuum/uniform%20field%20%2d%20spherical.html)

[tests/output/electrovacuum/verify cylindrical transform](https://thenumbernine.github.io/symmath/tests/output/electrovacuum/verify%20cylindrical%20transform.html)

[tests/output/exp_metric](https://thenumbernine.github.io/symmath/tests/output/exp_metric.html)

[tests/output/hydrodynamics](https://thenumbernine.github.io/symmath/tests/output/hydrodynamics.html)

[tests/output/hyperbolic gamma driver in ADM terms](https://thenumbernine.github.io/symmath/tests/output/hyperbolic%20gamma%20driver%20in%20ADM%20terms.html)

[tests/output/imperial units](https://thenumbernine.github.io/symmath/tests/output/imperial%20units.html)

[tests/output/metric catalog](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog.html)

[tests/output/metric catalog/Cartesian, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/Cartesian%2c%20coordinate.html)

[tests/output/metric catalog/Schwarzschild](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/Schwarzschild.html)

[tests/output/metric catalog/cylindrical and time, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/cylindrical%20and%20time%2c%20coordinate.html)

[tests/output/metric catalog/cylindrical surface, anholonomic, conformal](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/cylindrical%20surface%2c%20anholonomic%2c%20conformal.html)

[tests/output/metric catalog/cylindrical surface, anholonomic, orthonormal](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/cylindrical%20surface%2c%20anholonomic%2c%20orthonormal.html)

[tests/output/metric catalog/cylindrical surface, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/cylindrical%20surface%2c%20coordinate.html)

[tests/output/metric catalog/cylindrical, anholonomic, conformal](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/cylindrical%2c%20anholonomic%2c%20conformal.html)

[tests/output/metric catalog/cylindrical, anholonomic, orthonormal](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/cylindrical%2c%20anholonomic%2c%20orthonormal.html)

[tests/output/metric catalog/cylindrical, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/cylindrical%2c%20coordinate.html)

[tests/output/metric catalog/paraboliod, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/paraboliod%2c%20coordinate.html)

[tests/output/metric catalog/polar and time, constant rotation, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/polar%20and%20time%2c%20constant%20rotation%2c%20coordinate.html)

[tests/output/metric catalog/polar and time, lapse varying in radial, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/polar%20and%20time%2c%20lapse%20varying%20in%20radial%2c%20coordinate.html)

[tests/output/metric catalog/polar and time, lapse varying in radial, rotation varying in time and radial, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/polar%20and%20time%2c%20lapse%20varying%20in%20radial%2c%20rotation%20varying%20in%20time%20and%20radial%2c%20coordinate.html)

[tests/output/metric catalog/polar, anholonomic, conformal](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/polar%2c%20anholonomic%2c%20conformal.html)

[tests/output/metric catalog/polar, anholonomic, orthonormal](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/polar%2c%20anholonomic%2c%20orthonormal.html)

[tests/output/metric catalog/polar, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/polar%2c%20coordinate.html)

[tests/output/metric catalog/sphere surface, anholonomic, orthonormal](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/sphere%20surface%2c%20anholonomic%2c%20orthonormal.html)

[tests/output/metric catalog/sphere surface, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/sphere%20surface%2c%20coordinate.html)

[tests/output/metric catalog/spherical and time, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/spherical%20and%20time%2c%20coordinate.html)

[tests/output/metric catalog/spherical and time, lapse varying in radial](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/spherical%20and%20time%2c%20lapse%20varying%20in%20radial.html)

[tests/output/metric catalog/spherical, anholonomic, orthonormal](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/spherical%2c%20anholonomic%2c%20orthonormal.html)

[tests/output/metric catalog/spherical, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/spherical%2c%20coordinate.html)

[tests/output/metric catalog/spherical, log-radial, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/spherical%2c%20log%2dradial%2c%20coordinate.html)

[tests/output/metric catalog/spherical, sinh-radial, anholonomic, orthonormal](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/spherical%2c%20sinh%2dradial%2c%20anholonomic%2c%20orthonormal.html)

[tests/output/metric catalog/spherical, sinh-radial, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/spherical%2c%20sinh%2dradial%2c%20coordinate.html)

[tests/output/metric catalog/spiral, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/spiral%2c%20coordinate.html)

[tests/output/metric catalog/torus surface, coordinate](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog/torus%20surface%2c%20coordinate.html)

[tests/output/natural units](https://thenumbernine.github.io/symmath/tests/output/natural%20units.html)

[tests/output/numeric integration](https://thenumbernine.github.io/symmath/tests/output/numeric%20integration.html)

[tests/output/remove beta from adm metric](https://thenumbernine.github.io/symmath/tests/output/remove%20beta%20from%20adm%20metric.html)

[tests/output/rotation group](https://thenumbernine.github.io/symmath/tests/output/rotation%20group.html)

[tests/output/run all tests](https://thenumbernine.github.io/symmath/tests/output/run%20all%20tests.html)

[tests/output/scalar metric](https://thenumbernine.github.io/symmath/tests/output/scalar%20metric.html)

[tests/output/simple_ag](https://thenumbernine.github.io/symmath/tests/output/simple_ag.html)

[tests/output/spacetime embedding radius](https://thenumbernine.github.io/symmath/tests/output/spacetime%20embedding%20radius.html)

[tests/output/spinors](https://thenumbernine.github.io/symmath/tests/output/spinors.html)

[tests/output/spring force](https://thenumbernine.github.io/symmath/tests/output/spring%20force.html)

[tests/output/sum of two metrics](https://thenumbernine.github.io/symmath/tests/output/sum%20of%20two%20metrics.html)

[tests/output/symbols](https://thenumbernine.github.io/symmath/tests/output/symbols.html)

[tests/output/tensor coordinate invariance](https://thenumbernine.github.io/symmath/tests/output/tensor%20coordinate%20invariance.html)

[tests/output/toy-1+1 spacetime](https://thenumbernine.github.io/symmath/tests/output/toy%2d1%2b1%20spacetime.html)

[tests/output/unit/Matrix eigen](https://thenumbernine.github.io/symmath/tests/output/unit/Matrix%20eigen.html)

[tests/output/unit/Variable dependsOn](https://thenumbernine.github.io/symmath/tests/output/unit/Variable%20dependsOn.html)

[tests/output/unit/compile](https://thenumbernine.github.io/symmath/tests/output/unit/compile.html)

[tests/output/unit/determinant_performance](https://thenumbernine.github.io/symmath/tests/output/unit/determinant_performance.html)

[tests/output/unit/export](https://thenumbernine.github.io/symmath/tests/output/unit/export.html)

[tests/output/unit/func](https://thenumbernine.github.io/symmath/tests/output/unit/func.html)

[tests/output/unit/getIndexesUsed](https://thenumbernine.github.io/symmath/tests/output/unit/getIndexesUsed.html)

[tests/output/unit/index](https://thenumbernine.github.io/symmath/tests/output/unit/index.html)

[tests/output/unit/index_construction](https://thenumbernine.github.io/symmath/tests/output/unit/index_construction.html)

[tests/output/unit/integral](https://thenumbernine.github.io/symmath/tests/output/unit/integral.html)

[tests/output/unit/limit](https://thenumbernine.github.io/symmath/tests/output/unit/limit.html)

[tests/output/unit/linear solver](https://thenumbernine.github.io/symmath/tests/output/unit/linear%20solver.html)

[tests/output/unit/match](https://thenumbernine.github.io/symmath/tests/output/unit/match.html)

[tests/output/unit/matrix](https://thenumbernine.github.io/symmath/tests/output/unit/matrix.html)

[tests/output/unit/notfinite](https://thenumbernine.github.io/symmath/tests/output/unit/notfinite.html)

[tests/output/unit/plot](https://thenumbernine.github.io/symmath/tests/output/unit/plot.html)

[tests/output/unit/polyCoeffs](https://thenumbernine.github.io/symmath/tests/output/unit/polyCoeffs.html)

[tests/output/unit/polydiv](https://thenumbernine.github.io/symmath/tests/output/unit/polydiv.html)

[tests/output/unit/replace](https://thenumbernine.github.io/symmath/tests/output/unit/replace.html)

[tests/output/unit/replaceIndex](https://thenumbernine.github.io/symmath/tests/output/unit/replaceIndex.html)

[tests/output/unit/sets](https://thenumbernine.github.io/symmath/tests/output/unit/sets.html)

[tests/output/unit/simplifyMetrics](https://thenumbernine.github.io/symmath/tests/output/unit/simplifyMetrics.html)

[tests/output/unit/solve](https://thenumbernine.github.io/symmath/tests/output/unit/solve.html)

[tests/output/unit/sqrt](https://thenumbernine.github.io/symmath/tests/output/unit/sqrt.html)

[tests/output/unit/symmetrizeIndexes](https://thenumbernine.github.io/symmath/tests/output/unit/symmetrizeIndexes.html)

[tests/output/unit/tensor sub-assignment](https://thenumbernine.github.io/symmath/tests/output/unit/tensor%20sub%2dassignment.html)

[tests/output/unit/tensor sub-index](https://thenumbernine.github.io/symmath/tests/output/unit/tensor%20sub%2dindex.html)

[tests/output/unit/tensor use case](https://thenumbernine.github.io/symmath/tests/output/unit/tensor%20use%20case.html)

[tests/output/unit/test](https://thenumbernine.github.io/symmath/tests/output/unit/test.html)

[tests/output/unit/tidyIndexes](https://thenumbernine.github.io/symmath/tests/output/unit/tidyIndexes.html)

[tests/output/wave equation in spacetime - flux eigenvectors](https://thenumbernine.github.io/symmath/tests/output/wave%20equation%20in%20spacetime%20%2d%20flux%20eigenvectors.html)

[tests/output/wave equation in spacetime](https://thenumbernine.github.io/symmath/tests/output/wave%20equation%20in%20spacetime.html)

