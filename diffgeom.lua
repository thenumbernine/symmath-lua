local class = require 'ext.class'
local table = require 'ext.table'

local Props = class()

function Props:init(g, gU, c)
	local Tensor = require 'symmath'.Tensor

	local basis = Tensor.metric(g, gU)
	g = basis.metric
	gU = basis.metricInverse

	local expr = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)
	if c then expr = expr + (c'_abc' + c'_acb' - c'_bca')/2 end
	local GammaL = Tensor'_abc'
	GammaL['_abc'] = expr()

	local Gamma = GammaL'^a_bc'()
	
	local expr = (Gamma'^a_bd,c' - Gamma'^a_bc,d' + Gamma'^a_ec' * Gamma'^e_bd' - Gamma'^a_ed' * Gamma'^e_bc')
	if c then expr = expr + Gamma'^a_be' * c'_cd^e' end
	local Riemann = Tensor'^a_bcd'
	Riemann['^a_bcd'] = expr()
	Riemann = Riemann'^ab_cd'()
	
	local Ricci = Tensor'^a_b'
	Ricci['^a_b'] = Riemann'^ca_cb'()
	
	local Gaussian = Ricci'^a_a'()
	
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
		gU = var'g''^uv':eq(self.g'^uv'()),
		GammaL = var'\\Gamma''_abc':eq(self.GammaL'_abc'()),
		Gamma = var'\\Gamma''^a_bc':eq(self.Gamma'^a_bc'()),
		Riemann = var'R''^ab_cd':eq(self.Riemann'^ab_cd'()),
		Ricci = var'R''^a_b':eq(self.Ricci'^a_b'()),
		Gaussian = var'R':eq(self.Gaussian),
		Einstein = var'G''^a_b':eq(self.Einstein'^a_b'()),
	}
end

local keys = table{'g', 'gU', 'GammaL', 'Gamma', 'Riemann', 'Ricci', 'Gaussian', 'Einstein'}
local title = {
	g = 'metric',
	gU = 'metric inverse',
	c = 'commutation coefficients',
	GammaL = '1st kind Christoffel',
	Gamma = 'connection coefficients / 2nd kind Christoffel',
	Riemann = 'Riemann curvature',
	Ricci = 'Ricci curvature',
	Gaussian = 'Gaussian curvature',
	Einstein = 'trace-reversed Ricci curvature',
}
function Props:print(print_)
	print_ = print_ or print
	for _,key in ipairs(keys) do
		print_(title[key]..':')
		print_(self.eqns[key])
	end
end

return Props
