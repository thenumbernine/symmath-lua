# Symbolic Math library for Lua

[![Donate via Stripe](https://img.shields.io/badge/Donate-Stripe-green.svg)](https://buy.stripe.com/00gbJZ0OdcNs9zi288)<br>

## Live Demo

https://thenumbernine.github.io/symmath/

## TLDR

``` lua
<?=path'tests/console_spherical_metric.lua':read()?>
```

...makes this...

```
<?=path'tests/output/console_spherical_metric.txt':read()?>
```

## Goals

- Everything done in pure Lua / Lua syntax.  No/minimal parsing.
- Originally intended for computational physics.  Implement equations in Lua, perform symbolic manipulation, generate functions (via symmath.compile)

Online demo and API at https://thenumbernine.github.io/symmath/
Example used at https://thenumbernine.github.io/metric/
	and http://christopheremoore.net/gravitational-wave-simulation  

<?=path'README.reference.md':read()?>

## Dependencies

- https://github.com/thenumbernine/lua-ext
- https://github.com/thenumbernine/complex-lua
- https://github.com/thenumbernine/lua-bignumber
- https://github.com/thenumbernine/lua-gnuplot (optionally, for plotting graphs)
- 'utf8' if available.  Used by console-based output methods.
- 'ffi' if available.

Some of the tests depend on these:

- https://github.com/thenumbernine/lua-matrix
- https://github.com/thenumbernine/solver-lua
- https://github.com/thenumbernine/vec-lua

make\_README.lua uses (for building the README.md):

- LuaSocket, for its URL building functions.

The browser interface + server backend uses:

- https://github.com/thenumbernine/http-lua
- LuaSocket
- dkjson

## Environment / Lua Path

You will notice that, if you use the repository as-is, that the 'symmath.lua' file is out of place.
How to get around this:
1. Use the rockspec with luarocks to install this as a luarock.  This will put correct files in correct locations.  Problem solved.
2. Move symmath.lua into the parent directory.  This clutters things but also solves the problem.
3. Modify your LUA\_PATH / package.path to also include `"?/?.lua"`.

## SymMath Interpreter

If you want to run this as a command-line with the API in global namespace:

` symmath `:
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

If you would like to use the benefits of shorthand lambdas of the [Lua langfix](https://github.com/thenumbernine/langfix-lua) then install its shell script and simply replace the `lua -lext` in `symmath` with `rua`.

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
-	- This is mixed because you can already accomplish this by making a separate chart that just has the collection of coordinates you want to represent, assign it to those indexes, and use those in your dense Tensor construction.  I started on sub-tensors but I don't know that I'll finish them, and maybe someday I'll remove them.

- change canonical form from 'div add sub mul' to 'add sub mul div'.  also split apart div mul's into mul divs and then factor add mul's into mul add's for simplification of fractions

- finish Integer and Rational sets, maybe better support for Complex set.

- better polynomial factoring.

- I am thinking my constantly changing sqrts to fraction powers and back is slowing things down.  How about instead a better "isSqrt" or "getEquivPower" test that both sqrt(), cbrt(), and pow() all implement?

- browser interface:
- - "continue" feature, to counter-balance the "stop" cells
- - "stop" cells should hide their input box.
- - "undo" and "redo" buttons ... though the browser itself does do this for text edits.
- - "find" function ... once again, browser builtin has this.
- - line numbers, better line wrap detection, syntax highlighting

- favor() function or something that lets you pick between representations of sin/cos or tan, between re/im vs conj, sqrt vs pow, etc.

- flag for whether to show the outermost Tensor as col-vs-row depending on valence (instead of always as a col, which Matrix does)
- - oh and fix Matrix degree-3 LaTeX errors.

- rename dense-Tensor permute() to something more appropriate like permuteIndexes, reshapeIndexes, permuteStorage, etc...
- :outer() for Matrix / Array
- - :complexify() / :decomplexify()
- - basis elements / basis vectors and dual associated with tangentSpace of Charts of Manifolds
- :reshape() or :mergeIndex() or ravel/unravel(), I need this to 1) reshape n-degree matrixes/tensors to vectors (for factorLinearSystem) and 2) to take odd/even indexes of matrix-outer-complex-2x2-basis to (de)complexify.

<?
require 'ext'
local url = require 'socket.url'

local base = [[https://thenumbernine.github.io/lua/symmath/]]

local s = table{[[
Output Examples:
]]}

local fs = table()
for f in path:rdir(function(f, isdir)
	f = path(f)
	return f.path ~= '.git' 
		and f.path:sub(1,6) ~= 'server'
		and (isdir or f.path:sub(-5) == '.html')
end) do fs:insert(f) end
fs:sort(function(a,b) return a.path < b.path end)
for _,f in ipairs(fs) do
	local name = f.path:sub(1,-6)
	s:insert('['..name..']('..base..
		url.escape(f.path)
			:gsub('%%2f','/')
			:gsub('%%2e','.')
		..')\n')
end
?>
<?=s:concat'\n'?>
