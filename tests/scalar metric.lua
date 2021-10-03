#! /usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, implicitVars=true, MathJax={title='scalar metric', usePartialLHSForDerivative=true}}

local allCoords = table{symmath.vars('t', 'x', 'y', 'z')}
local t,x,y,z = allCoords:unpack() 

for dim=1,1 do
	print('<h2>'..dim..' dimensions</h2>')
	
	local coords = allCoords:sub(1,dim+1)
	local manifold = Tensor.Manifold()
	local chart = manifold:Chart{coords=coords}

	local a = var('a', coords)
	local b = var('b', coords)

	local g = Tensor('_uv', function(i,j)
		if i ~= j then return 0 end
		return var('\\rho_'..i, coords)
	end)
	
	local props = require 'symmath.physics.diffgeom'(g)
	props:print(print)

	if dim == 1 then
		local RDef = props.Gaussian
		for _,k in ipairs{'Riemann', 'Ricci', 'Einstein'} do
			props[k] = (props[k] / RDef * var'R')()
			props:printField(k, print)
		end
	end
end
