#!/usr/bin/env luajit

-- not really a unit test

require 'symmath'.setup()
require 'ext'

local x = var'x'

local n = 7

local startTime = os.clock()

local m = Matrix:lambda({n,n}, function(i,j)
	return x^(i+j)
end)
local d = m:determinant(function(...)
	return print(...)
end)

print('m = \n'..m)
print('d = \n'..d)

local endTime = os.clock()
local dt = endTime - startTime
print('time taken = '..dt)
