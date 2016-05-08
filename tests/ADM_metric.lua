local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
local print_ = print
local function print(...) print_(...) print_'<br>' end
print_(MathJax.header)

require 'symmath.tostring.LaTeX'.usePartialLHSForDerivative = true

local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars

local coords = table{vars('t','x','y','z')}
local t, x, y, z = coords:unpack()
Tensor.coords{{variables=coords}}

local alpha = var'\alpha'

-- things get ugly with the expanded upper gamma ... this is where mixed notation simplifications would help a lot ...

print_(MathJax.footer)
