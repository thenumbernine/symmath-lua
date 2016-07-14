local class = require 'ext.class'
local table = require 'ext.table'

local Props = class()

function Props:init(g, gU)
	local Tensor = require 'symmath'.Tensor

	local basis = Tensor.metric(g, gU)
	g = basis.metric
	gU = basis.metricInverse

	local GammaL = Tensor'_abc'
	GammaL['_abc'] = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
	
	local Gamma = GammaL'^a_bc'()
	
	local Riemann = Tensor'^a_bcd'
	Riemann['^a_bcd'] = (Gamma'^a_bd,c' - Gamma'^a_bc,d' + Gamma'^a_ec' * Gamma'^e_bd' - Gamma'^a_ed' * Gamma'^e_bc')()
	Riemann = Riemann'^ab_cd'()
	
	local Ricci = Tensor'^a_b'
	Ricci['^a_b'] = Riemann'^ca_cb'()
	
	local Gaussian = Ricci'^a_a'()
	
	local Einstein = Tensor'^a_b'
	Einstein['^a_b'] = (Ricci'^a_b' - g'^a_b' * Gaussian)()

	self.g = g
	self.gU = gU
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

function Props:print(print_)
	print_ = print_ or print
	for _,key in ipairs(keys) do
		print_(self.eqns[key])
	end
end

return Props
