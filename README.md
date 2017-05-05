# Symbolic Math library for Lua

## Goals:

- Everything done in pure Lua / Lua syntax.  No/minimal parsing.
- Originally intended for computational physics.  Implement equations in Lua, perform symbolic manipulation, generate functions (via symmath.compile)

Online demo and API at http://christopheremoore.net/symbolic-lua  
Example used at http://christopheremoore.net/metric  
	and http://christopheremoore.net/gravitational-wave-simulation  

## Reference

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

```
symmath.simplify(expr)
expr:simplify()
expr()
```

Simplifies the expression.

```
symmath.replace(expr, find, repl, callback)
expr:replace(find, repl, callback)
```

Replaces portions of an expression with another
expr = expression to change
find = sub-expression to find
repl = sub-expression to replace
callback(node) = callback per node, returns 'true' if we don't want to find/replace this tree.

```
symmath.map(expr, callback)
expr:map(callback)
```

Maps sub-expressions in an expression to new sub-expressions.
expr = expression
callback(node) = callback that returns nil if it leaves the tree untouched, returns a value if it wishes to change the tree

```
symmath.eval(expr, {[var1]=value, var2name=value, ...})
expr:eval{[var1]=value, var2name=value, ...}
```

Calculates the numeric value of the expression.

```
symmath.polyCoeffs(expr, var)
expr:polyCoeffs(var)
```

Returns a table of coefficients with keys 0 through the degree of the polynomial, and 'extra' containing all non-polynomial terms.

### Calculus

```
symmath.diff(expr, var1, var2, ...)
expr:diff(var1, var2, ...)
```

Differentiates the expression with respect to the given variable.
Integrals and limits coming eventually.

### Linear Algebra

```
A = symmath.Matrix({expr11, expr12 ...}, {expr21, expr22, ...}, ...)
```

Create a matrix of expressions.

```
A = symmath.Array(...)
```

Create an array of expressions. Same deal as Matrix but with any arbitrary nesting depth, and without Matrix-specific operations.

```
AInv, I, message = A:inverse([b, callback, allowRectangular])
```

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

```
d = A:determinant()
```

Calculates the determinant of A

```
At = A:transpose()
```

Calculates the transpose of A

```
I = Matrix.identity()
```

Returns 1

```
I = Matrix.identity(n)
```

Returns a n x n identity matrix

```
I = Matrix.identity(m,n)
```

Returns a m x n matrix with diagonals set to 1 and all other values set to 0.

```
D = Matrix.diagonal(d1, d2, d3, ...)
```

Returns a n x n matrix with diagonal elements set to d1 ... dn, for n the number of arguments provided.

```
tr = A:trace()
```

Returns the trace of A.

### Tensors

```

Tensor.coords{
 {variables={t,x,y,z}}
}

```

Specifies that tensors will be using coordinates t,x,y,z

```
Tensor.coords{
 {variables={t,x,y,z}, meric=g}
}
```

Specifies that tensors will be using coordinates t,x,y,z with metric 'g' (a Matrix or 2D array).  The metric inverse will be automatically computed.

```
Tensor.coords{
 {variables={t,x,y,z}, meric=g, metricInverse=gU}
}
```

Specifies that tensors will be using coordinates t,x,y,z with metric 'g' (a Matrix or 2D array) and metric inverse 'gU'.

```
Tensor.coords{
 {variables={t,x,y,z}},
 {symbols='ijklmn', variables={x,y,z}},
}
```

Specifies that tensors will be using coordinates t,x,y,z, except for indexes ijklmn which will only use x,y,z.  At the moment conversion between maps is very ugly/incomplete.

```
Tensor.metric(g, [gU, symbol])
```

Specifies to use metric 'g' for the default coordinate system (assuming one has been defined with Tensor.coords).

```
t = Tensor'_abc'``

Creates a degree-3 covariant tensor 't' with all values initialized to 0.

... tensor summation / multiplication ...
` ( u'^a' * v'_b' * eps'_a^bc_d' )() ` produces a degree-2 tensor perpendicular to 'u' and 'v' (assuming eps is defined as the Levi-Civita tensor).

... comma derivatives (semicolon derivatives almost there, just need to store the connection coefficients) ...

... assignment: `S = T'_ab' - T'_ba'`
in this case the indexes of 'S' are picked on a first-come, first-serve basis.  If you want to be  certain of the assignment, use the following: 

```

S = Tensor'_ab'
S['_ab'] = (T'_ab' - T'_ba')()

```

(the final `()` is shorthand for `:simplify()`, which will evaluate the expression into the tensor structure)

... index gymnastics (so long as you defined a metric): `v = Tensor('_a', ...) print(v'^a'())` will show you the contents of v^a = g^ab v_b.

## TODO

- solving equalities
- integrals.  symbolic, numeric explicit, then eventually get to numeric implicit (this involves derivatives based on both the dependent and the state variable)

- functions that lua has that I don't: abs, ceil, floor, deg, rad, fmod, frexp, log10, min, max

- support for numbers rather than only Constant

- integrate with lua-parser to decompile lua code -> ast -> symmath, perform symbolic differentiation on it, then recompile it ...
	i.e. `f = [[function(x) return x^2 end]] g = symmath:luaDiff(f, 'x') <=> g = [[function(x) return 2*x end]]`  

- subindexes, so you can store a tensor of tensors: g_ab = Tensor('_ab', {-alpha^2+beta^2, beta_j}, {beta_i, gamma_ij})