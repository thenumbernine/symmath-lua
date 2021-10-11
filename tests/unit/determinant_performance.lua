#!/usr/bin/env luajit

-- not really a unit test

require 'symmath'.setup{env=env, MathJax={title='tests/unit/determinant_performance', pathToTryToFindMathJax='..'}}
require 'ext'

local x = var'x'

local n = 7

local startTime = os.clock()

local m = Matrix:lambda({n,n}, function(i,j)
	return x^(i+j)
end)
local d = m:determinant{callback=function(...)
	return printbr(...)
end}

printbr('m = \n'..m)
printbr('d = \n'..d)

local endTime = os.clock()
local dt = endTime - startTime
printbr('time taken = '..dt)
