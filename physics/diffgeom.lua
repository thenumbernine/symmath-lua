local class = require 'ext.class'
local table = require 'ext.table'
local var = require 'symmath.Variable'
local Tensor = require 'symmath.Tensor'

--[[
helper class for computing common differential geometry values from a metric tensor

TODO
Bake this directly into the metric information of the Tensor.
Compute it as requested.
I am already doing so for the metric and its inverse.
Next logical thing would be to do it for connections when they are needed.
--]]
local Props = class()

Props.fields = table{
	{
		name = 'c',
		symbol = 'c',
		title = 'commutation coefficients',
		display = function(self)
			return var'c''_ab^c':eq(
				--self.c'_ab^c'()
				self.c:permute'^c_ab'	-- show the [ab] antisymmetry better
			)
		end,
	},
	{
		name = 'g',
		symbol = 'g',
		title = 'metric',
		calc = function(self) return self.chart.metric end,
		display = function(self) return var'g''_ab':eq(self.g'_ab'()) end,
	},
	{
		name = 'gU',
		symbol = 'g',
		title = 'metric inverse',
		calc = function(self) return self.chart.metricInverse end,
		display = function(self) return var'g''^ab':eq(self.gU'^ab'()) end,
	},
	{
		name = 'dg',
		symbol = '{\\partial g}',
		title = 'metric derivative',
		calc = function(self) return self.g'_ab,c'():permute'_abc' end,
		display = function(self)
			return var'g''_ab,c':eq(
				--self.dg'_abc'()
				self.dg:permute'_cab'	-- show the (ab) symmetry
			)
		end,
	},
	{
		name = 'GammaL',
		symbol = '\\Gamma',
		title = '1st kind Christoffel',
		calc = function(self)
			local expr = ((self.dg'_abc' + self.dg'_acb' - self.dg'_bca') / 2)
			if self.c then
				expr = expr + (self.c'_abc' + self.c'_acb' - self.c'_cba') / 2
			end
			return expr():permute'_abc'
		end,
		display = function(self)
			return var'\\Gamma''_abc':eq(
				-- if we are holonomic we want to see Gamma_a(bc)
				-- if we are anholonomic we want to see Gamma_[a|b|c]
				--self.GammaL'_abc'()
				self.GammaL:permute'_bac'	-- show Gamma_(a|b|c) or Gamma_[a|b|c]
			)
		end,
	},
	{
		name = 'Gamma',
		symbol = '\\Gamma',
		title = 'connection coefficients / 2nd kind Christoffel',
		calc = function(self) return self.GammaL'^a_bc'() end,
		display = function(self)
			return var'\\Gamma''^a_bc':eq(
				--self.Gamma'^a_bc'()
				self.Gamma:permute'_b^a_c'
			) 
		end,
	},
	{
		name = 'dGamma',
		symbol = '{\\partial \\Gamma}',
		title = 'connection coefficients derivative',
		calc = function(self) return self.Gamma'^a_bc,d'():permute'^a_bcd' end,
		display = function(self)
			return var'\\Gamma''^a_bc,d':eq(
				--self.dGamma'^a_bcd'()
				self.dGamma:permute'_bd^a_c'	-- put derivs together, put anti/sym together
			)
		end,
	},

-- this is too slow.  for dim=4, Gamma^a_bc is 4^3 = 64 elements
-- the multiply always does the outer before the inner
-- and the outer operation is 4^6 = 4096 elements
-- TODO analyze the mul(TensorRef,TensorRef)
-- and if it has multiple indexes, keep track of them, transform the elements individually, sum them, and only generate the resulting indexes
-- (in this case, 4^4 = 256, much smaller)
-- another TODO to help optimization: keep track of symmetric/antisymmetric terms
	{
		name = 'GammaSq',
		symbol = '(\\Gamma^2)',
		title = 'connection coefficients squared',
		calc = function(self) return (self.Gamma'^a_ce' * self.Gamma'^e_db')():permute'^a_bcd' end,
		display = function(self) 
			return (var'\\Gamma''^a_ec' * var'\\Gamma''^e_bd'):eq(
				--self.GammaSq'^a_bcd'()
				self.GammaSq:permute'_bd^a_c'
			) 
		end,
	},
	{
		name = 'RiemannULLL',
		symbol = 'R',
		title = 'Riemann curvature, $\\sharp\\flat\\flat\\flat$',
		calc = function(self)
			local expr = (self.dGamma'^a_dbc' - self.dGamma'^a_cbd' + self.GammaSq'^a_bcd' - self.GammaSq'^a_bdc')
			if self.c then
				expr = expr - self.Gamma'^a_eb' * self.c'_cd^e'
			end
			return expr():permute'^a_bcd'
		end,
		display = function(self) 
			return var'R''^a_bcd':eq(
				self.RiemannULLL'^a_bcd'()
				--self.RiemannULLL:permute'_bd^a_c'
			) 
		end,
	},
	{
		name = 'Riemann',
		symbol = 'R',
		title = 'Riemann curvature, $\\sharp\\sharp\\flat\\flat$',
		calc = function(self) return self.RiemannULLL'^ab_cd'() end,
		display = function(self) return var'R''^ab_cd':eq(self.Riemann'^ab_cd'()) end,
	},
	{
		name = 'Ricci',
		symbol = 'R',
		title = 'Ricci curvature, $\\sharp\\flat$',
		calc = function(self) return self.Riemann'^ca_cb'() end,
		display = function(self) return var'R''^a_b':eq(self.Ricci'^a_b'()) end,
	},
	{
		name = 'Gaussian',
		symbol = 'R',
		title = 'Gaussian curvature',
		calc = function(self) return self.Ricci'^a_a'() end,
		display = function(self) return var'R':eq(self.Gaussian) end,
	},
	{
		name = 'RicciTF',
		symbol = '(R^{TF})',
		title = 'trace-free Ricci, $\\sharp\\flat$',
		calc = function(self)
			local frac = require 'symmath.op.div'
			local delta = require 'symmath.tensor.KronecherDelta'(1)
			local n = #self.Ricci
			return (self.Ricci'^a_b' - frac(1, n) * self.Gaussian * delta'^a_b')()
		end,
		display = function(self) return var'(R^{TF})''^a_b':eq(self.RicciTF'^a_b'()) end,
	},
	{
		name = 'Einstein',
		symbol = 'G',
		title = 'Einstein / trace-reversed Ricci curvature, $\\sharp\\flat$',
		calc = function(self)
			local delta = require 'symmath.tensor.KronecherDelta'(1)
			local n = #self.Ricci
			local frac = require 'symmath.op.div'
			-- you could also do 2 * (RicciTF - Ricci) + Ricci
			return (self.Ricci'^a_b' - frac(2, n) * delta'^a_b' * self.Gaussian)()
		end,
		display = function(self) return var'G''^a_b':eq(self.Einstein'^a_b'()) end,
	},
	{
		name = 'Schouten',
		symbol = 'P',	-- or S
		title = 'Schouten, $\\sharp\\flat$',
		calc = function(self)
			local n = #self.Ricci
			if n < 3 then
				return Tensor'^a_b'
			end
			local frac = require 'symmath.op.div'
			local delta = require 'symmath.tensor.KronecherDelta'(1)
			return (frac(1, n-2) * (self.Ricci'^a_b' - frac(1, 2 * (n - 1)) * self.Gaussian * delta'^a_b'))()
		end,
		display = function(self) return var'P''^a_b':eq(self.Schouten) end,
	},
	{
		name = 'Weyl',
		symbol = 'C',
		title = 'Weyl, $\\sharp\\sharp\\flat\\flat$',
		calc = function(self)
			local delta = require 'symmath.tensor.KronecherDelta'(1)
			return (
				self.Riemann'^ab_cd'
				- self.Schouten'^a_c' * delta'^b_d'
				+ self.Schouten'^b_c' * delta'^a_d'
				- self.Schouten'^b_d' * delta'^a_c'
				+ self.Schouten'^a_d' * delta'^b_c'
			)():permute'^ab_cd'
		end,
		display = function(self) return var'C''^ab_cd':eq(self.Weyl) end,
	},
	{
		name = 'WeylLLLL',
		symbol = 'C',
		title = 'Weyl, $\\flat\\flat\\flat\\flat$',
		calc = function(self) return self.Weyl'_abcd'() end,
		display = function(self) return var'C''_abcd':eq(self.WeylLLLL) end,
	},
	{
		name = 'Plebanski',
		symbol = 'P',
		title = 'Plebanski, $\\sharp\\sharp\\flat\\flat$',
		calc = function(self)
			local frac = require 'symmath.op.div'
			local SUL = self.RicciTF
			local SLU = SUL'_a^b'()
			local delta = require 'symmath.tensor.KronecherDelta'(1)
			return (frac(1,4) * (
				SUL'^a_c' * SUL'^b_d'
				- SUL'^b_c' * SUL'^a_d'
				+ SUL'^b_d' * SUL'^a_c'
				- SUL'^a_d' * SUL'^b_c'
				+ delta'^a_c' * SUL'^b_e' * SLU'_d^e'
				- delta'^b_c' * SUL'^a_e' * SLU'_d^e'
				+ delta'^b_d' * SUL'^a_e' * SLU'_c^e'
				- delta'^a_d' * SUL'^b_e' * SLU'_c^e'
				- frac(1,6) * (
					delta'^a_c' * delta'^b_d'
					- delta'^b_c' * delta'^a_d'
					+ delta'^b_d' * delta'^a_c'
					- delta'^a_d' * delta'^b_c'
				) * (SUL'^e_f' * SLU'_e^f')
			))():permute'^ab_cd'
		end,
		display = function(self) return var'P''^ab_cd':eq(self.Plebanski()) end,
	},
--[[
	{
		name = 'Bel-Robinson',
		symbol = 'T',
		title = 'Bel-Robinson, $\\sharp\\sharp\\flat\\flat$',
		calc = function(self)
			local frac = require 'symmath.op.div'
			return (self.Weyl'^ae_cf' * self.Weyl'^bg_dh' * self.g'_eg' * self.gU'^fh'
				- frac(3,2) * (
					self.gU'^ab' * self.WeylLLLL'_jkcf'
					+ self.gU'^aj' * self.WeylLLLL'_kbcf'
					+ self.gU'^ak' * self.WeylLLLL'_bjcf'
					- self.gU'^ak' * self.WeylLLLL'_jbcf'
					- self.gU'^ab' * self.WeylLLLL'_kjcf'
					- self.gU'^aj' * self.WeylLLLL'_bkcf'
				) * self.Weyl'^jk_dg' * self.gU'^fg')():permute'^ab_cd'
		end,
		display = function(self) return var'T''^ab_cd':eq(self.BelRobinson) end,
	},
--]]
}

function Props:getEqnForField(fieldname)
	local _, field = self.fields:find(nil, function(field)
		return field.name == fieldname
	end)
	return field and field.display(self) or nil
end

function Props:doPrint(field)
	local pr = require 'symmath'.tostring.print or print
	pr(field.title..':')
	pr(field.display(self))
end

-- print all
function Props:print()
	for _,field in ipairs(self.fields) do
		if self[field.name] then
			self:doPrint(field)
		end
	end
end

-- print one
function Props:printField(fieldname)
	for _,field in ipairs(self.fields) do
		if field.name == fieldname then
			assert(self[field.name], "failed to find field "..field.name)
			self:doPrint(field)
		end
	end
end

-- TODO make it table-based arguments
-- overload self.verbose to output vars as you go
function Props:init(g, gU, c, chart)
	self.chart = chart or assert(Tensor:findChartForSymbol(), "couldn't find default chart")
	self.chart:setMetric(g, gU)
	if c then self.chart.commutation = c end
	self.c = c

	for _,field in ipairs(self.fields) do
		local name = field.name
		if field.calc then
			self[name] = field.calc(self)
		end
		if self[name] and self.verbose then
			self:printField(name)
		end
	end

	-- TODO setMetric accepts non-symmath tables
	-- soo I would need to convert them before outputting
	-- either move this below setMetric, or convert before this line.
end

return Props
