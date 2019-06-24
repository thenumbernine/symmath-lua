local class = require 'ext.class'
local table = require 'ext.table'
local var = require 'symmath.Variable'
local Tensor = require 'symmath.Tensor'

--[[
helper class for computing common differential geometry values from a metric tensor
--]]
local Props = class()

Props.fields = table{
	{
		name = 'c',
		symbol = 'c',
		title = 'commutation coefficients',
		display = function(self) return var'c''_ab^c':eq(self.c'_ab^c'()) end,
	},
	{
		name = 'g',
		symbol = 'g',
		title = 'metric',
		calc = function(self) return Tensor.metric().metric end,
		display = function(self) return var'g''_ab':eq(self.g'_ab'()) end,
	},
	{
		name = 'gU',
		symbol = 'g',
		title = 'metric inverse',
		calc = function(self) return Tensor.metric().metricInverse end,
		display = function(self) return var'g''^ab':eq(self.gU'^ab'()) end,
	},
	{
		name = 'dg',
		symbol = '{\\partial g}',
		title = 'metric derivative',
		calc = function(self)
			local dg = Tensor'_abc'
			dg['_abc'] = self.g'_ab,c'()
			return dg
		end,
		display = function(self) return var'g''_ab,c':eq(self.dg'_abc'()) end,
	},
	{
		name = 'GammaL',
		symbol = '\\Gamma',
		title = '1st kind Christoffel',
		calc = function(self)
			local expr = ((self.dg'_abc' + self.dg'_acb' - self.dg'_bca') / 2)
			if self.c then 
				expr = expr + (self.c'_abc' + self.c'_acb' - self.c'_cba')/2 
			end
			local GammaL = Tensor'_abc'
			GammaL['_abc'] = expr()
			return GammaL		
		end,
		display = function(self) return var'\\Gamma''_abc':eq(self.GammaL'_abc'()) end,
	},
	{
		name = 'Gamma',
		symbol = '\\Gamma',
		title = 'connection coefficients / 2nd kind Christoffel',
		calc = function(self) return self.GammaL'^a_bc'() end,
		display = function(self) return var'\\Gamma''^a_bc':eq(self.Gamma'^a_bc'()) end,
	},
	{
		name = 'dGamma',
		symbol = '{\\partial \\Gamma}',
		title = 'connection coefficients derivative',
		calc = function(self)
			local dGamma = Tensor'^a_bcd'
			dGamma['^a_bcd'] = self.Gamma'^a_bc,d'()
			return dGamma
		end,
		display = function(self) return var'\\Gamma''^a_bc,d':eq(self.dGamma'^a_bcd'()) end,
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
		calc = function(self)
			local GammaSq = Tensor'^a_bcd'
			GammaSq['^a_bcd'] = (self.Gamma'^a_ce' * self.Gamma'^e_bd')()
			return GammaSq
		end,
		display = function(self) return (var'\\Gamma''^a_ec' * var'\\Gamma''^e_bd'):eq(self.GammaSq'^a_bcd'()) end,
	},
	{
		name = 'RiemannULLL',
		symbol = 'R',
		title = 'Riemann curvature, $\\sharp\\flat\\flat\\flat$',
		calc = function(self)
			local RiemannULLL = Tensor'^a_bcd'
			local expr = (self.dGamma'^a_dbc' - self.dGamma'^a_cbd' + self.GammaSq'^a_cdb' - self.GammaSq'^a_dcb')
			if self.c then 
				expr = expr - self.Gamma'^a_eb' * self.c'_cd^e' 
			end
			RiemannULLL['^a_bcd'] = expr()
			return RiemannULLL
		end,
		display = function(self) return var'R''^a_bcd':eq(self.RiemannULLL'^a_bcd'()) end,
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
		name = 'Einstein',
		symbol = 'G',
		title = 'Einstein $\\sharp\\flat$ / trace-reversed Ricci curvature',
		calc = function(self) return (self.Ricci'^a_b' - self.g'^a_b' * self.Gaussian)() end,
		display = function(self) return var'G''^a_b':eq(self.Einstein'^a_b'()) end,
	},
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
function Props:init(g, gU, c)
	local Tensor = require 'symmath'.Tensor

	Tensor.metric(g, gU)
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

	-- TODO Tensor.meric accepts non-symmath tables
	-- soo I would need to convert them before outputting
	-- either move this below Tensor.metric, or convert before this line.
end

return Props
