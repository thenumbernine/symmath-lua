# Symbolic Math library for Lua

## TLDR

```
require 'symmath'.setup{implicitVars=true}
Tensor.coords{{variables={r,theta,phi}}}
u = Tensor('^I', r*sin(theta)*cos(phi), r*sin(theta)*sin(phi), r*cos(theta))
print('u^I:\n'..u)
e = Tensor'_i^I'
e['_a^I'] = u'^I_,a'()
print('e_a^I:\n'..e)
delta = Tensor('_IJ', table.unpack(Matrix.identity(3)))
print('delta_IJ:\n'..delta)
g = (e'_a^I' * e'_b^J' * delta'_IJ')()
print('g_ab:\n'..g)
Tensor.metric(g)
dg = Tensor'_abc'
dg['_abc'] = g'_ab,c'()
print('g_ab,c:\n'..dg)
GammaL = ((dg'_abc' + dg'_acb' - dg'_bca')/2)()
print('Gamma_abc:\n'..GammaL)
Gamma = GammaL'^a_bc'()
print('Gamma^a_bc:\n'..Gamma)
dGamma = Tensor'^a_bcd'
dGamma['^a_bcd'] = Gamma'^a_bc,d'()
print('Gamma^a_bc,d:\n'..dGamma)
GammaSq = Tensor'^a_bcd'
GammaSq['^a_bcd'] = (Gamma'^a_ce' * Gamma'^e_db')()
Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = (dGamma'^a_dbc' - dGamma'^a_cbd' + GammaSq'^a_bcd' - GammaSq'^a_bdc')()
print('Riemann^a_bcd:\n'..Riemann)
```

...makes this...

```
u^I:
       I↓        
┌r sin(θ) cos(φ)┐
│               │
│r sin(θ) sin(φ)│
│               │
└   r cos(θ)    ┘
e_a^I:
                       i↓I→                       
┌                                                ┐
│   sin(θ) cos(φ)     sin(θ) sin(φ)      cos(θ)  │
│                                                │
│  r cos(θ) cos(φ)   r cos(θ) sin(φ)   - r sin(θ)│
│                                                │
│ - r sin(θ) sin(φ)  r sin(θ) cos(φ)       0     │
└                                                ┘
delta_IJ:
  I↓J→   
┌       ┐
│1  0  0│
│       │
│0  1  0│
│       │
│0  0  1│
└       ┘
g_ab:
       a↓b→        
┌                 ┐
│1   0       0    │
│                 │
│    2            │
│0  r        0    │
│                 │
│        2       2│
│0   0  r  sin(θ) │
└                 ┘
g_ab,c:
                 a↓[b↓c→]                 
┌                 b↓c→                   ┐
│               ┌       ┐                │
│               │0  0  0│                │
│               │       │                │
│               │0  0  0│                │
│               │       │                │
│               │0  0  0│                │
│               └       ┘                │
│                                        │
│                 b↓c→                   │
│             ┌           ┐              │
│             │  0    0  0│              │
│             │           │              │
│             │2.0 r  0  0│              │
│             │           │              │
│             │  0    0  0│              │
│             └           ┘              │
│                                        │
│                  b↓c→                  │
│┌                                      ┐│
││      0                  0           0││
││                                      ││
││      0                  0           0││
││                                      ││
││            2       2                 ││
││2.0 r sin(θ)   2.0 r  sin(θ) cos(θ)  0││
└└                                      ┘┘
Gamma_abc:
                    a↓[b↓c→]                     
┌             ┌                   ┐             ┐
│             │0   0        0     │             │
│             │                   │             │
│             │0  -r        0     │             │
│             │                   │             │
│             │                  2│             │
│             │0   0   - r sin(θ) │             │
│             └                   ┘             │
│                                               │
│          ┌                         ┐          │
│          │0  r           0         │          │
│          │                         │          │
│          │r  0           0         │          │
│          │                         │          │
│          │          2              │          │
│          │0  0   - r  sin(θ) cos(θ)│          │
│          └                         ┘          │
│                                               │
│┌                                             ┐│
││                                         2   ││
││    0              0             r sin(θ)    ││
││                                             ││
││                              2              ││
││    0              0         r  sin(θ) cos(θ)││
││                                             ││
││        2   2                                ││
││r sin(θ)   r  sin(θ) cos(θ)          0       ││
└└                                             ┘┘
Gamma^a_bc:
           a↓[b↓c→]           
┌   ┌                   ┐    ┐
│   │0   0        0     │    │
│   │                   │    │
│   │0  -r        0     │    │
│   │                   │    │
│   │                  2│    │
│   │0   0   - r sin(θ) │    │
│   └                   ┘    │
│                            │
│┌                          ┐│
││      1                   ││
││ 0   ╶─╴          0       ││
││      r                   ││
││                          ││
││ 1                        ││
││╶─╴   0           0       ││
││ r                        ││
││                          ││
││ 0    0    - sin(θ) cos(θ)││
│└                          ┘│
│                            │
│ ┌                       ┐  │
│ │                   1   │  │
│ │ 0       0        ╶─╴  │  │
│ │                   r   │  │
│ │                       │  │
│ │                cos(θ) │  │
│ │ 0       0     ╶──────╴│  │
│ │                sin(θ) │  │
│ │                       │  │
│ │ 1    cos(θ)           │  │
│ │╶─╴  ╶──────╴      0   │  │
│ │ r    sin(θ)           │  │
└ └                       ┘  ┘
Gamma^a_bc,d:
                                   a↓b→[c↓d→]                                   
┌                                                                              ┐
│                                                        c↓d→                  │
│     c↓d→                c↓d→          ┌                                     ┐│
│   ┌       ┐          ┌        ┐       │     0                 0            0││
│   │0  0  0│          │ 0  0  0│       │                                     ││
│   │       │          │        │       │     0                 0            0││
│   │0  0  0│          │-1  0  0│       │                                     ││
│   │       │          │        │       │         2                           ││
│   │0  0  0│          │ 0  0  0│       │ - sin(θ)    - 2.0 r sin(θ) cos(θ)  0││
│   └       ┘          └        ┘       └                                     ┘│
│                                                                              │
│     c↓d→                c↓d→                                                 │
│┌             ┐     ┌             ┐                      c↓d→                 │
││   0     0  0│     │     1       │         ┌                            ┐    │
││             │     │   ╶──╴      │         │0             0            0│    │
││     1       │     │ -   2   0  0│         │                            │    │
││   ╶──╴      │     │    r        │         │0             0            0│    │
││ -   2   0  0│     │             │         │                            │    │
││    r        │     │   0     0  0│         │      ╭                2╮   │    │
││             │     │             │         │0   - ╰1.0 - 2.0 sin(θ) ╯  0│    │
││   0     0  0│     │   0     0  0│         └                            ┘    │
│└             ┘     └             ┘                                           │
│                                                                              │
│                                                         c↓d→                 │
│                                              ┌                        ┐      │
│     c↓d→                c↓d→                 │     1                  │      │
│┌             ┐  ┌                  ┐         │   ╶──╴                 │      │
││   0     0  0│  │0        0       0│         │ -   2         0       0│      │
││             │  │                  │         │    r                   │      │
││   0     0  0│  │0        0       0│         │                        │      │
││             │  │                  │         │                1       │      │
││     1       │  │          1       │         │            ╶───────╴   │      │
││   ╶──╴      │  │      ╶───────╴   │         │   0      -        2   0│      │
││ -   2   0  0│  │0   -        2   0│         │             sin(θ)     │      │
││    r        │  │       sin(θ)     │         │                        │      │
│└             ┘  └                  ┘         │   0           0       0│      │
│                                              └                        ┘      │
└                                                                              ┘
Riemann^a_bcd:
           a↓b→[c↓d→]            
┌                               ┐
│  c↓d→       c↓d→       c↓d→   │
│┌       ┐  ┌       ┐  ┌       ┐│
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
│└       ┘  └       ┘  └       ┘│
│                               │
│  c↓d→       c↓d→       c↓d→   │
│┌       ┐  ┌       ┐  ┌       ┐│
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
│└       ┘  └       ┘  └       ┘│
│                               │
│  c↓d→       c↓d→       c↓d→   │
│┌       ┐  ┌       ┐  ┌       ┐│
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
││       │  │       │  │       ││
││0  0  0│  │0  0  0│  │0  0  0││
│└       ┘  └       ┘  └       ┘│
└                               ┘
```

## Goals:

- Everything done in pure Lua / Lua syntax.  No/minimal parsing.
- Originally intended for computational physics.  Implement equations in Lua, perform symbolic manipulation, generate functions (via symmath.compile)

Online demo and API at http://christopheremoore.net/symbolic-lua  
Example used at http://christopheremoore.net/metric  
	and http://christopheremoore.net/gravitational-wave-simulation  

### Overall

`symmath.setup(args)`  
Use this if you want to copy the symmath namespace into the global namespace.  
`args` can include the following:  
`implicitVars` - set this to `true` to create a variable from any reference to an uninitialized variable. Otherwise variables must be initialized manually.  

Using `symmath` without `symmath.setup()`.  
```
local symmath = require 'symmath'
local a, r, theta, rho, M, Q = symmath.vars('a','r','\\theta','\\rho','M','Q')
print(Delta:eq(r^2 + a^2 + Q^2 - 2 * M * r))
print((Delta - (r^2 + a^2)) * a * symmath.sin(theta)^2 / rho^2)
```

Using `symmath` with `symmath.setup()` but without `implicitVars` removes the need to reference the `symmath` namespace, but still requires explicit creation of variables.  
```
require 'symmath'.setup()
local a, r, theta, rho, M, Q = vars('a','r','\\theta','\\rho','M','Q')
print(Delta:eq(r^2 + a^2 + Q^2 - 2 * M * r))
print((Delta - (r^2 + a^2)) * a * sin(theta)^2 / rho^2)
```

Using `symmath` with `symmath.setup{implicitVars=true}` removes the need for `symmath` namespace references and the need for explicit creation of variables.  
Notice that underscores and Greek letters are automatically converted to appropriate TeX symbols.
```
require 'symmath'.setup{implicitVars=true}
print(Delta:eq(r^2 + a^2 + Q^2 - 2 * M * r))
print((Delta - (r^2 + a^2)) * a * sin(theta)^2 / rho^2)
```

Alternatively, you can run Lua with `-lsymmath.setup`, which is equivalent to `require 'symmath.setup`, which calls `require 'symmath'.setup()`.

### Numbers

For the most part Lua numbers will work, and will automatically be replaced by symmath Constants (found in symmath.Constant).
This is because Constant is a subclass of Expression, and I was too lazy to implement all the ridiculous number of edge cases required to handle Lua numbers, though I am thinking about doing this.
Constant can be constructed with numbers (`Constant(0), Constant(1)`, etc) or with complex values (`Constant{re=1, im=0}`, etc).

Complex values can be represented by symmath.complex, which uses builtin complex types when run within LuaJIT, or uses a pure-Lua alternative otherwise.

Some day I will properly represent sets (naturals, integers, rationals, reals, complex, etc), and maybe groups, rings, etc, but not for now.

Some day I will also add support for infinite precision or big integers, but not right now.

### Variables

`var = symmath.Variable(name[, dependencies])`  
`var = symmath.var(name[, dependencies])`  
`var1, var2, ... = symmath.vars(name1, name2, ...)`  
Create a variable with given name, and optionally a list of which variables it is dependent on for differentiation. By default variables of different names have a derivative of zero.

`var:depends(var1, var2, ...)`  
Specify the variables that var is dependent on for differentiation.

`func, code = symmath.compile(expr, {var1, var2, ...}, language)`  
`func, code = expr:compile{var1, var2, ...}`  
Compiles an expression to a Lua function with the listed vars as parameters.  
`language` can be one of the following:  
* Lua
* JavaScript
* C
* LaTeX
* MathJax
* GnuPlot

`symmath.GnuPlot:plot(args)`  
Produces SVG of a plot. Requires my `lua-gnuplot` library.  
Arguments are forwarded to the `gnuplot` lua module, with the expression provided in place of the plot command.  

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

### Expressions

`symmath.simplify(expr)`  
`expr:simplify()`  
`expr()`  
Simplifies the expression.

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

### Calculus

`symmath.diff(expr, var1, var2, ...)`  
`expr:diff(var1, var2, ...)`  
Differentiates the expression with respect to the given variable.  

### Linear Algebra

`A = symmath.Matrix({expr11, expr12 ...}, {expr21, expr22, ...}, ...)`  
Create a matrix of expressions.  

`A = symmath.Array(...)`  
Create an array of expressions. Same deal as Matrix but with any arbitrary nesting depth, and without Matrix-specific operations.  

`AInv, I, message = A:inverse([b, callback, allowRectangular])`  
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
Returns the determinant of A.  

`At = A:transpose()`  
Returns the transpose of A

`I = Matrix.identity([m, n])`  
Returns 1 if no arguments are provided.  
Returns a m x m identity matrix if one argument is provided.  
Returns a m x n identity matrix if two arguments are provided.  

`D = Matrix.diagonal(d1, d2, d3, ...)`  
Returns a n x n matrix with diagonal elements set to d1 ... dn, for n the number of arguments provided.  

`tr = A:trace()`  
Returns the trace of A.  

### Tensors

`Tensor.coords{ {variables={t,x,y,z}} }`  
Specifies that tensors will be using coordinates t,x,y,z

`Tensor.coords{ {variables={t,x,y,z}, meric=g} }`  
Specifies that tensors will be using coordinates t,x,y,z with metric 'g' (a Matrix or 2D array).  The metric inverse will be automatically computed.

`Tensor.coords{ {variables={t,x,y,z}, meric=g, metricInverse=gU} }`  
Specifies that tensors will be using coordinates t,x,y,z with metric 'g' (a Matrix or 2D array) and metric inverse 'gU'.

`Tensor.coords{ {variables={t,x,y,z}}, {symbols='ijklmn', variables={x,y,z}} }`  
Specifies that tensors will be using coordinates t,x,y,z, except for indexes ijklmn which will only use x,y,z.  
At the moment conversion between maps is very ugly/incomplete.

`Tensor.metric(g, [gU, symbol])`  
Specifies to use metric 'g' for the default coordinate system (assuming one has been defined with Tensor.coords).  

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
Rearranges the internal storage of `t`

`t:print't'`  
Prints the tensor's contents.  

`t:printElem't'`  
Prints the individual nonzero values of the tensor, or '0' if they are all zero.  

## Dependencies:

- https://github.com/thenumbernine/lua-ext
- https://github.com/thenumbernine/lua-gnuplot (optionally, for plotting graphs)
- 'ffi' if available.  Used by console-based output methods.
- 'utf8' if available.

Some tests use:

- https://github.com/thenumbernine/lua-matrix
- https://github.com/thenumbernine/solver-lua
- https://github.com/thenumbernine/vec-lua

make_README.lua uses (for building the README.md):

- LuaSocket, for its URL building functions.

## TODO

- solving equalities

- integrals.  symbolic, numeric explicit, then eventually get to numeric implicit (this involves derivatives based on both the dependent and the state variable)

- functions that lua has that I don't: ceil, floor, deg, rad, fmod, frexp, log10, min, max

- support for numbers rather than only Constant

- combine symmath with the lua-parser to decompile lua code -> ast -> symmath, perform symbolic differentiation on it, then recompile it ...
	i.e. `f = [[function(x) return x^2 end]] g = symmath:luaDiff(f, 'x') <=> g = [[function(x) return 2*x end]]`

- subindexes, so you can store a tensor of tensors: g_ab = Tensor('_ab', {-alpha^2+beta^2, beta_j}, {beta_i, gamma_ij})
	(Though this is a lot of work for a rarely used feature...)

- change canonical form from 'div add sub mul' to 'add sub mul div'.  also split apart div mul's into mul divs and then factor add mul's into mul add's for simplification of fractions

- sets associated with variables.  easy ones for starters:
	*) naturals
	*) integers
	*) rings
	*) rationals
	*) irrationals
	*) algebraic
	*) transcendental
	*) reals (extended reals by default? or a separate set for extended reals?)
	*) complex
	*) quaternions
	*) octonions

	... and associated properties ...
	
	Natural + Natural => Natural
	Natural - Natural => Integer
	Natural * Natural => Natural
	Natural / Natural => Rational

	Natural + Integer => Integer
	Natural - Integer => Integer
	Natural * Integer => Integer
	Natural / Integer => Rational
	
	Integer + Natural => Integer
	Integer - Natural => Integer
	Integer * Natural => Integer
	Integer / Natural => Rational
	
	Integer + Integer => Integer
	Integer - Integer => Integer
	Integer * Integer => Integer
	Integer / Integer => Rational
	
	Natural (+-*/) Rational => Rational
	Integer (+-*/) Rational => Rational

	etc...

- ranges/sets/conditions associated with expressions
	so x in Reals, 1/x, simplified, gives 1/x (x~=0)
	and x in Reals, sqrt(x), simplified, gives sqrt(x) (x>=0)
	and x in Reals, sqrt(f(x)), simplified, gives sqrt(f(x)) (f(x)>=0)
	and x in Reals, sqrt(x+1), simplified, gives sqrt(x+1) (x>=-1)

- better rules for processing everything.  something where you provide patterns and it searches through and replaces accordingly.
	patterns like...
	unm:
		-(-a) => a
		[-c] => -[c] ... for c > 0
	add:
		a + 0 => a
		0 + a => a
		a + (b + c) => (a + b) + c ... only if a,b,c are associative under +
		[c1] + [c2] => [c1+c2]
		a + b => b + a ... only if a and b are commutative under +, and if our precedence of variables states precedence(b) < precedence(a)
	sub:
		a - 0 => a
		0 - a => -a
		a - (-b) => a + b
		a - (b - c) => (a - b) + c
		a - (b + c) => (a - b) - c
		a + (b - c) => (a + b) - c
		[c1] - [c2] => [c1-c2]
	mul:
		1 * 1 => 1
		1 * -1 => -1
		a * 0 => 0
		0 * a => 0
		a * 1 => a
		1 * a => a
		a * -1 => -a
		-1 * a => -a
		[-c1] * a => -([c1] * a) ... for c1 > 0
		(-a) * b => -(a * b)
		a * (-b) => -(a * b)
		(-a) * (-b) => a * b
		a * (b * c) => (a * b) * c ... only if a,b,c are associative under *
		a * (b + c) => a * b + a * c
		(a + b) * c => a * c + b * c
		[c1] * [c2] => [c1*c2]
		[c1] * a + [c2] * a => [c1+c2] * a
		[c1] * a - [c2] * a => [c1-c2] * a
		a * b => b * a ... only if a and b are commutative under *, and if our precedence of variables states precedence(b) < precedence(a)
	div:
		[c1] / [c2] => [factors(c1)\gcd(c1,c2)] / [factors(c2)\gcd(c1,c2)] for integers c1,c2
		[c1] / 0 => undefined
		a / 0 => undefined
		0 / a => 0 (for a ~= 0)
		a / 1 => a
		a / -1 => -a
		1 / -a => -1 / a (for a ~= 0)
		a / a => 1
		1 / (1 / a) => a (for a ~= 0)
		(-a) / b => -(a / b)
		a / (-b) => -(a / b)
		(-a) / (-b) => a / b
		(a * b) / a => b (for a ~= 0)
		(b * a) / a => b (for a ~= 0)
		(a + b) / c => a / c + b / c
		(a - b) / c => a / c - b / c
		a * (b / c) => (a * b) / c
		a / (b / c) => (a * c) / b
		(a / b) / c => a / (b * c)
	pow:
		a ^ 0 => 1
		0 ^ 0 => 1
		0 ^ a => { a=0: 1, a~=0: 0}
		a ^ 1 => a
		1 ^ a => 1
		a ^ -1 => 1 / a
		a ^ -b => 1 / (a ^ b)
		a * a => a ^ 2
		a * a ^ b => a ^ (1 + b)
		a ^ b * a => a ^ (b + 1)
		a ^ b * a ^ c => a ^ (b + c)
		(a ^ b) ^ c => a ^ (b * c)

distinct functions for all languages:
- __call = produces a single expression of code, without checking variables
- generate = produces the function body.  multiple expressions.
	doing tree searches and moving common variables out front would be good.
- compile = produces the Lua function.  only for Lua.  maybe for C if you are using LuaJIT and have access to a compiler 

Output CDN URLs:

[tests/output/ADM Levi-Civita](https://thenumbernine.github.io/symmath/tests/output/ADM%20Levi%2dCivita.html)

[tests/output/ADM gravity using expressions](https://thenumbernine.github.io/symmath/tests/output/ADM%20gravity%20using%20expressions.html)

[tests/output/ADM metric - mixed](https://thenumbernine.github.io/symmath/tests/output/ADM%20metric%20%2d%20mixed.html)

[tests/output/ADM metric](https://thenumbernine.github.io/symmath/tests/output/ADM%20metric.html)

[tests/output/Alcubierre](https://thenumbernine.github.io/symmath/tests/output/Alcubierre.html)

[tests/output/BSSN](https://thenumbernine.github.io/symmath/tests/output/BSSN.html)

[tests/output/Building Curvature by ADM](https://thenumbernine.github.io/symmath/tests/output/Building%20Curvature%20by%20ADM.html)

[tests/output/EFE discrete solution - 1-var](https://thenumbernine.github.io/symmath/tests/output/EFE%20discrete%20solution%20%2d%201%2dvar.html)

[tests/output/EFE discrete solution - 2-var](https://thenumbernine.github.io/symmath/tests/output/EFE%20discrete%20solution%20%2d%202%2dvar.html)

[tests/output/Einstein field equations - expression](https://thenumbernine.github.io/symmath/tests/output/Einstein%20field%20equations%20%2d%20expression.html)

[tests/output/Ernst](https://thenumbernine.github.io/symmath/tests/output/Ernst.html)

[tests/output/FLRW](https://thenumbernine.github.io/symmath/tests/output/FLRW.html)

[tests/output/Faraday tensor in general relativity](https://thenumbernine.github.io/symmath/tests/output/Faraday%20tensor%20in%20general%20relativity.html)

[tests/output/Faraday tensor in special relativity](https://thenumbernine.github.io/symmath/tests/output/Faraday%20tensor%20in%20special%20relativity.html)

[tests/output/FiniteVolume](https://thenumbernine.github.io/symmath/tests/output/FiniteVolume.html)

[tests/output/GLM-Maxwell](https://thenumbernine.github.io/symmath/tests/output/GLM%2dMaxwell.html)

[tests/output/Gravitation 16.1 - dense](https://thenumbernine.github.io/symmath/tests/output/Gravitation%2016.1%20%2d%20dense.html)

[tests/output/Gravitation 16.1 - expression](https://thenumbernine.github.io/symmath/tests/output/Gravitation%2016.1%20%2d%20expression.html)

[tests/output/Gravitation 16.1 - mixed](https://thenumbernine.github.io/symmath/tests/output/Gravitation%2016.1%20%2d%20mixed.html)

[tests/output/Kaluza-Klein - index](https://thenumbernine.github.io/symmath/tests/output/Kaluza%2dKlein%20%2d%20index.html)

[tests/output/Kaluza-Klein - varying scalar field - index](https://thenumbernine.github.io/symmath/tests/output/Kaluza%2dKlein%20%2d%20varying%20scalar%20field%20%2d%20index.html)

[tests/output/Kaluza-Klein](https://thenumbernine.github.io/symmath/tests/output/Kaluza%2dKlein.html)

[tests/output/Kerr-Schild - dense](https://thenumbernine.github.io/symmath/tests/output/Kerr%2dSchild%20%2d%20dense.html)

[tests/output/Kerr-Schild - expression](https://thenumbernine.github.io/symmath/tests/output/Kerr%2dSchild%20%2d%20expression.html)

[tests/output/Kerr-Schild degenerate case](https://thenumbernine.github.io/symmath/tests/output/Kerr%2dSchild%20degenerate%20case.html)

[tests/output/MHD inverse](https://thenumbernine.github.io/symmath/tests/output/MHD%20inverse.html)

[tests/output/MHD symmetrization](https://thenumbernine.github.io/symmath/tests/output/MHD%20symmetrization.html)

[tests/output/Maxwell equations in hyperbolic conservation form](https://thenumbernine.github.io/symmath/tests/output/Maxwell%20equations%20in%20hyperbolic%20conservation%20form.html)

[tests/output/Newton method](https://thenumbernine.github.io/symmath/tests/output/Newton%20method.html)

[tests/output/SRHD](https://thenumbernine.github.io/symmath/tests/output/SRHD.html)

[tests/output/Schwarzschild - isotropic](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20isotropic.html)

[tests/output/Schwarzschild - spherical - derivation - varying time 2](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20spherical%20%2d%20derivation%20%2d%20varying%20time%202.html)

[tests/output/Schwarzschild - spherical - derivation - varying time](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20spherical%20%2d%20derivation%20%2d%20varying%20time.html)

[tests/output/Schwarzschild - spherical - derivation](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20spherical%20%2d%20derivation.html)

[tests/output/Schwarzschild - spherical - mass varying with time](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20spherical%20%2d%20mass%20varying%20with%20time.html)

[tests/output/Schwarzschild - spherical](https://thenumbernine.github.io/symmath/tests/output/Schwarzschild%20%2d%20spherical.html)

[tests/output/TOV](https://thenumbernine.github.io/symmath/tests/output/TOV.html)

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

[tests/output/linearized Euler fluid equations](https://thenumbernine.github.io/symmath/tests/output/linearized%20Euler%20fluid%20equations.html)

[tests/output/metric catalog](https://thenumbernine.github.io/symmath/tests/output/metric%20catalog.html)

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

[tests/output/symbols](https://thenumbernine.github.io/symmath/tests/output/symbols.html)

[tests/output/tensor coordinate invariance](https://thenumbernine.github.io/symmath/tests/output/tensor%20coordinate%20invariance.html)

[tests/output/toy-1+1 spacetime](https://thenumbernine.github.io/symmath/tests/output/toy%2d1%2b1%20spacetime.html)

[tests/output/unit/linear solver](https://thenumbernine.github.io/symmath/tests/output/unit/linear%20solver.html)

[tests/output/unit/matrix](https://thenumbernine.github.io/symmath/tests/output/unit/matrix.html)

[tests/output/unit/partial replace](https://thenumbernine.github.io/symmath/tests/output/unit/partial%20replace.html)

[tests/output/unit/sub-tensor assignment](https://thenumbernine.github.io/symmath/tests/output/unit/sub%2dtensor%20assignment.html)

[tests/output/unit/tensor use case](https://thenumbernine.github.io/symmath/tests/output/unit/tensor%20use%20case.html)

[tests/output/unit/test](https://thenumbernine.github.io/symmath/tests/output/unit/test.html)

[tests/output/unit/tidyIndexes](https://thenumbernine.github.io/symmath/tests/output/unit/tidyIndexes.html)

[tests/output/wave equation with metric of space and time - based on bssnok-scalar](https://thenumbernine.github.io/symmath/tests/output/wave%20equation%20with%20metric%20of%20space%20and%20time%20%2d%20based%20on%20bssnok%2dscalar.html)
