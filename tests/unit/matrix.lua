#!/usr/bin/env luajit
require 'symmath'.setup{implicitVars=true}
require 'symmath.tostring.MathJax'.setup{title='Matrix Tests'}

-- vectors
printbr(Array(1,2,3))

printbr(Array(1,2) + Array(3,4))
printbr((Array(1,2) + Array(3,4))())

-- numeric example

printbr(Matrix({1,2},{3,4}))
printbr(Matrix({1,2},{3,4}):inverse())

-- 2D variable example

printbr(Matrix({a,b},{c,d}))
printbr(Matrix({a,b},{c,d}):inverse())

-- 4D translation matrix

printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}))
printbr(Matrix({1,0,0,t_x},{0,1,0,t_y},{0,0,1,t_z},{0,0,0,1}):inverse())

-- 2D rotation matrix

m = Matrix({cos(theta), -sin(theta)}, {sin(theta), cos(theta)})
mInv = m:inverse()
mInv = mInv:replace(sin(theta)^2, 1-cos(theta)^2)()	-- almost there ... still have to trig simplify this ...

printbr(m + mInv)
printbr((m + mInv)())
printbr(m * mInv)
printbr((m * mInv)())
printbr(m*m)
printbr((m*m)())

m1 = Matrix({1,a},{0,1})
m2 = Matrix({1,0},{b,1})
printbr((m1))
printbr((m2))
printbr((m1*m2):eq((m1*m2)()))
printbr((m2*m1):eq((m2*m1)()))
printbr(m1:eq(m2))
printbr(m1==m2)
printbr((m1*m2):eq(m2*m1))
printbr(m1*m2==m2*m1)
printbr((m1*m2):eq(m1*m2))
printbr(m1*m2==m1*m2)
printbr((m1*m2):eq(m2*m1)())
printbr((m1*m2)()==(m2*m1)())

printbr((Matrix({a},{b}) + Matrix({c},{d})) / t)
printbr(((Matrix({a},{b}) + Matrix({c},{d})) / t)())

-- linear system solver

printbr(Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))
printbr((Matrix({1,2},{3,4})*Matrix({1,2},{3,4}):inverse(Matrix({5},{6})))())
