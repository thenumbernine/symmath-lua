local class = require 'ext.class'
local table = require 'ext.table'

local function eprint(...)
	local s = {}
	for i=1,select('#',...) do
		table.insert(s, tostring(select(i, ...)))
	end
	io.stderr:write(table.concat(s, '\t'), '\n')
	io.stderr:flush()
end

local Props = class()

function Props:init(g, gU, c)
	local Tensor = require 'symmath'.Tensor

	local basis = Tensor.metric(g, gU)
	g = basis.metric
	gU = basis.metricInverse

	local dg = Tensor'_abc'
	dg['_abc'] = g'_ab,c'()
if verbose then eprint'g_ab,c' end
if verbose then eprint'Gamma_abc' end
	local expr = ((dg'_abc' + dg'_acb' - dg'_bca') / 2)
	if c then expr = expr + (c'_abc' + c'_acb' - c'_bca')/2 end
	local GammaL = Tensor'_abc'
	GammaL['_abc'] = expr()

if verbose then eprint'Gamma^a_bc' end
	local Gamma = GammaL'^a_bc'()

if verbose then eprint'Gamma^a_bc,d' end
	local dGamma = Tensor'^a_bcd'
	dGamma['^a_bcd'] = Gamma'^a_bc,d'()

-- this is too slow.  for dim=4, Gamma^a_bc is 4^3 = 64 elements
-- the multiply always does the outer before the inner
-- and the outer operation is 4^6 = 4096 elements
-- TODO analyze the mulOp(TensorRef,TensorRef)
-- and if it has multiple indexes, keep track of them, transform the elements individually, sum them, and only generate the resulting indexes
-- (in this case, 4^4 = 256, much smaller)
-- another TODO to help optimization: keep track of symmetric/antisymmetric terms
if verbose then eprint'Gamma^a_ec Gamma^e_bd' end
	local GammaSq = Tensor'^a_bcd'
	GammaSq['^a_bcd'] = (Gamma'^a_ec' * Gamma'^e_bd')()

if verbose then eprint'Riemann^a_bcd' end
	local expr = (dGamma'^a_bdc' - dGamma'^a_bcd' + GammaSq'^a_bcd' - GammaSq'^a_bdc')
	if c then expr = expr + Gamma'^a_be' * c'_cd^e' end
	local Riemann = Tensor'^a_bcd'
	Riemann['^a_bcd'] = expr()

if verbose then eprint'Riemann^ab_cd' end
	Riemann = Riemann'^ab_cd'()
	
if verbose then eprint'Ricci^a_b' end
	local Ricci = Tensor'^a_b'
	Ricci['^a_b'] = Riemann'^ca_cb'()
	
if verbose then eprint'Gaussian' end
	local Gaussian = Ricci'^a_a'()
	
if verbose then eprint'Einstein^a_b' end
	local Einstein = Tensor'^a_b'
	Einstein['^a_b'] = (Ricci'^a_b' - g'^a_b' * Gaussian)()

	self.g = g
	self.gU = gU
	self.c = c
	self.Gamma = Gamma
	self.GammaL = GammaL
	self.Riemann = Riemann
	self.Ricci = Ricci
	self.Gaussian = Gaussian
	self.Einstein = Einstein

	self:calcEqns()
end

function Props:calcEqns()
	local var = require 'symmath'.var
	self.eqns = {
		g = var'g''_uv':eq(self.g'_uv'()),
		c = self.c and var'c''_ab^c':eq(self.c'_ab^c'()) or nil,
		gU = var'g''^uv':eq(self.gU'^uv'()),
		GammaL = var'\\Gamma''_abc':eq(self.GammaL'_abc'()),
		Gamma = var'\\Gamma''^a_bc':eq(self.Gamma'^a_bc'()),
		Riemann = var'R''^ab_cd':eq(self.Riemann'^ab_cd'()),
		Ricci = var'R''^a_b':eq(self.Ricci'^a_b'()),
		Gaussian = var'R':eq(self.Gaussian),
		Einstein = var'G''^a_b':eq(self.Einstein'^a_b'()),
	}
end

local keys = {
	{g = 'metric'},
	{gU = 'metric inverse'},
	{c = 'commutation coefficients'},
	{GammaL = '1st kind Christoffel'},
	{Gamma = 'connection coefficients / 2nd kind Christoffel'},
	{Riemann = 'Riemann curvature'},
	{Ricci = 'Ricci curvature'},
	{Gaussian = 'Gaussian curvature'},
	{Einstein = 'trace-reversed Ricci curvature'},
}
function Props:print(print_)
	print_ = print_ or print
	for _,key in ipairs(keys) do
		local k,title = next(key)
		local eqn = self.eqns[k]
		if eqn then
			print_(title..':')
			print_(eqn)
		end
	end
end

return Props
