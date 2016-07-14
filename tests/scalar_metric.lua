#! /usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
MathJax.usePartialLHSForDerivative = true
print(MathJax.header)
do
	local print = MathJax.print 
	local Tensor = symmath.Tensor
	local var = symmath.var

	local allCoords = table{symmath.vars('t', 'x', 'y', 'z')}
	local t,x,y,z = allCoords:unpack() 

	for dim=1,1 do
		print('<h2>'..dim..' dimensions</h2>')
		
		local coords = allCoords:sub(1,dim+1)
		Tensor.coords{
			{variables=coords}
		}

		local a = var('a', coords)
		local b = var('b', coords)

		local g = Tensor('_uv', function(i,j)
			if i ~= j then return 0 end
			return var('\\rho_'..i, coords)
		end)
		
		local props = require 'symmath.diffgeom'(g)

		props:print(print)

		if dim == 1 then
			local RDef = props.Gaussian
			for _,k in ipairs{'Riemann', 'Ricci', 'Einstein'} do
				props[k] = (props[k] / RDef * var'R')()
				print(props.eqns[k]:lhs():eq(props[k]))
			end
		end
	end
end
print(MathJax.footer)
