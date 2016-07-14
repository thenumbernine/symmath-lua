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

	local t,x,y,z = symmath.vars('t', 'x', 'y', 'z')
	local coords = {t,x,y,z}
	local spatialCoords = {x,y,z}

	Tensor.coords{
		{variables=coords},
		{symbols='ijklmn', variables=spatialCoords},
	}

	local E = Tensor('^i', function(i) return var('E^'..spatialCoords[i].name, coords) end)
	local B = Tensor('^i', function(i) return var('B^'..spatialCoords[i].name, coords) end)

	local ESq = var('E^2', coords)
	local BSq = var('B^2', coords)

	local g = Tensor('_uv', function(i,j)
		if i ~= j then return 0 end
		return ESq + BSq
	end)
	
	local props = require 'symmath.diffgeom'(g)

	for k,eqn in ipairs(props.eqns) do
		for i,x in ipairs(spatialCoords) do
			props[k] = props[k]:replace(ESq:diff(x), 2*E[i])()
			props[k] = props[k]:replace(BSq:diff(x), 2*B[i])()
		end
	end
	props:calcEqns()

	props:print(print)
end
print(MathJax.footer)
