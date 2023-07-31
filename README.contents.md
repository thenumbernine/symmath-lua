# Symbolic Math library for Lua

[![Donate via Stripe](https://img.shields.io/badge/Donate-Stripe-green.svg)](https://buy.stripe.com/00gbJZ0OdcNs9zi288)<br>
[![Donate via Bitcoin](https://img.shields.io/badge/Donate-Bitcoin-green.svg)](bitcoin:37fsp7qQKU8XoHZGRQvVzQVP8FrEJ73cSJ)<br>

## Live Demo

http://christopheremoore.net/symbolic-lua

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

Online demo and API at http://christopheremoore.net/symbolic-lua  
Example used at http://christopheremoore.net/metric  
	and http://christopheremoore.net/gravitational-wave-simulation  

<?=path'README.reference.md':read()?>

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

- error with this: `(Constant(1.1) / Constant(1.2) * x )()`

- I am thinking my constantly changing sqrts to fraction powers and back is slowing things down.  How about instead a better "isSqrt" or "getEquivPower" test that both sqrt(), cbrt(), and pow() all implement?

- browser interface: "continue" feature, to counter-balance the "stop" cells
- browser interface: "stop" cells should hide their input box.
- browser interface: "undo" and "redo" buttons
- browser interface: "find" function
- browser interface: line numbers, better line wrap detection, syntax highlighting

<?
require 'ext'
local url = require 'socket.url'

--local base = [[https://cdn.rawgit.com/thenumbernine/symmath-lua/master/]]
--local base = [[https://htmlpreview.github.io/?https://github.com/thenumbernine/symmath-lua/blob/master/]]
local base = [[https://thenumbernine.github.io/symmath/]]

local s = table{[[
Output CDN URLs:
]]}

os.rlistdir('.', function(f, isdir)
	return f ~= '.git' 
		and f:sub(1,6) ~= 'server'
		and (isdir or f:sub(-5) == '.html')
end):sort():mapi(function(f)
	local name = f:sub(1,-6)
	s:insert('['..name..']('..base..
		url.escape(f)
			:gsub('%%2f','/')
			:gsub('%%2e','.')
		..')\n')
end)
?>
<?=s:concat'\n'?>
