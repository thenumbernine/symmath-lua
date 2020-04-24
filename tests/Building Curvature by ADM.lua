#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{MathJax={title='Building Curvature by ADM', useCommaDerivative=true}}
op = symmath.op	-- override ext.op

local x,y = vars('x','y')
local coords = table{x,y}

Tensor.coords{
	{variables=coords},
}

io.stderr:write'g_ab...\n'
local g = Tensor('_uv', function(u,v)
	if u > v then u,v = v,u end
	return var('g_{'..coords[u].name..coords[v].name..'}', coords)
end)
g:print'g' printbr()

io.stderr:write'det g...\n'
local det_g = var('g', coords)
local det_g_def = det_g:eq(Matrix.determinant(g))
printbr(det_g_def)

io.stderr:write'g^ab...\n'
local gU = Tensor('^uv', table.unpack((Matrix.inverse(g))))
gU = gU:subst(det_g_def:switch())
gU:print'g' printbr()

Tensor.metric(g, gU)

io.stderr:write'Conn_abc...\n'
local ConnL = Tensor'_abc'
ConnL['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
ConnL:print'\\Gamma' printbr()

io.stderr:write'Conn^a_bc...\n'
local Conn = Tensor'^a_bc'
Conn['^a_bc'] = ConnL'^a_bc'()
Conn:print'\\Gamma' printbr()

io.stderr:write'Conn^a_bc,d...\n'
local dConn = Tensor'^a_bcd'
dConn['^a_bcd'] = Conn'^a_bc,d'()
dConn = dConn:map(function(x)	-- replace derivatives
	if Derivative.is(x) and x[1] == det_g then
		return x:subst(det_g_def)()
	end
end)()
-- don't substitute g's on the denominator
dConn = dConn:map(function(x)
	if op.div.is(x) then
		return (x[1]:subst(det_g_def) / x[2])()
	end
end)
printbr(var'\\Gamma''^a_bc,d':eq(dConn))

io.stderr:write'Conn^a_ec * Conn^e_bd...\n'
local ConnSq = Tensor'^a_bcd'
ConnSq['^a_bcd'] = (Conn'^a_ec' * Conn'^e_bd')()
-- don't substitute g's on the denominator
ConnSq = ConnSq:map(function(x)
	if op.div.is(x) then
		return (x[1]:subst(det_g_def) / x[2])()
	end
end)
printbr((var'\\Gamma''^a_ec' * var'\\Gamma''^e_bd'):eq(ConnSq'^a_bcd'()))

io.stderr:write'Riemann^a_bcd...\n'
local RiemannULLL = Tensor'^a_bcd'
RiemannULLL['^a_bcd'] = (dConn'^a_bdc' - dConn'^a_bcd' + ConnSq'^a_bcd' - ConnSq'^a_bdc')()
RiemannULLL:printElem'R' printbr()

io.stderr:write'Riemann^ab_cd...\n'
local RiemannUULL = Tensor'^ab_cd'
RiemannUULL['^ab_cd'] = RiemannULLL'^ab_cd'()
RiemannUULL:printElem'R' printbr()

-- there is supposed to be only one unique R_abcd for 2 dimensions ...
-- R_abcd = K(g_ac g_bd - g_ad g_bc)
-- R_ab = K g_ab
-- K = R / 2
-- R = 
os.exit()


local Props = class(require 'symmath.physics.diffgeom')
Props.verbose = true	-- print as you go
Props.fields = table(Props.fields)
-- replace Gamma^a_bc calculation to 
Props.fields:append{
	{
		name = 'RiemannLLLL',
		symbol = 'R',
		title = 'Riemann, $\\flat\\flat\\flat\\flat$',
		calc = function(self) return self.RiemannULLL'_abcd'() end,
		display = function(self) return var'R''_abcd':eq(self.RiemannLLLL'_abcd'()) end,
	},
	{
		name = 'EinsteinLL',
		symbol = 'G',
		title = 'Einstein, $\\flat\\flat$',
		calc = function(self) return self.Einstein'_ab'() end,
		display = function(self) return var'G''_ab':eq(self.EinsteinLL'_ab'()) end,
	},
	{
		name = 'RicciLL',
		symbol = 'R',
		title = 'Ricci, $\\flat\\flat$',
		calc = function(self) return self.Ricci'_ab'() end,
		display = function(self) return var'R''_ab':eq(self.RicciLL'_ab'()) end,
	},
}
local props = Props(g, gU)
