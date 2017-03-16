local class = require 'ext.class'
local table = require 'ext.table'

local Props = class()

local function var() return require 'symmath'.var end

Props.fields = table{
	{
		name = 'c',
		title = 'commutation coefficients',
		eqn = function(self) return var()'c''_ab^c':eq(self.c'_ab^c'()) end,
	},
	{
		name = 'g',
		title = 'metric',
		eqn = function(self) return var()'g''_ab':eq(self.g'_ab'()) end,
	},
	{
		name = 'gU',
		title = 'metric inverse',
		eqn = function(self) return var()'g''^ab':eq(self.gU'^ab'()) end,
	},
	{
		name = 'dg',
		title = 'metric derivative',
		eqn = function(self) return var()'g''_ab,c':eq(self.dg'_abc'()) end,
	},
	{
		name = 'GammaL',
		title = '1st kind Christoffel',
		eqn = function(self) return var()'\\Gamma''_abc':eq(self.GammaL'_abc'()) end,
	},
	{
		name = 'Gamma',
		title = 'connection coefficients / 2nd kind Christoffel',
		eqn = function(self) return var()'\\Gamma''^a_bc':eq(self.Gamma'^a_bc'()) end,
	},
	{
		name = 'dGamma',
		title = 'connection coefficients derivative',
		eqn = function(self) return var()'\\Gamma''^a_bc,d':eq(self.dGamma'^a_bcd'()) end,
	},
	{
		name = 'GammaSq',
		title = 'connection coefficients squared',
		eqn = function(self) return (var()'\\Gamma''^a_ec' * var()'\\Gamma''^e_bd'):eq(self.GammaSq'^a_bcd'()) end,
	},
	{
		name = 'RiemannU',
		title = 'Riemann curvature, sharp',
		eqn = function(self) return var()'R''^a_bcd':eq(self.RiemannU'^a_bcd'()) end,
	},
	{
		name = 'Riemann',
		title = 'Riemann curvature',
		eqn = function(self) return var()'R''^ab_cd':eq(self.Riemann'^ab_cd'()) end,
	},
	{
		name = 'Ricci',
		title = 'Ricci curvature',
		eqn = function(self) return var()'R''^a_b':eq(self.Ricci'^a_b'()) end,
	},
	{
		name = 'Gaussian',
		title = 'Gaussian curvature',
		eqn = function(self) return var()'R':eq(self.Gaussian) end,
	},
	{
		name = 'Einstein',
		title = 'trace-reversed Ricci curvature',
		eqn = function(self) return var()'G''^a_b':eq(self.Einstein'^a_b'()) end,
	},
}

function Props:getEqnForField(fieldname)
	local _, field = self.fields:find(nil, function(field)
		return field.name == fieldname
	end)
	return field and field.eqn(self) or nil
end

Props.print = print 

-- print all
function Props:print(printfn)
	printfn = printfn or self.print
	for _,kv in ipairs(self.fields) do
		if self[field.name] then	
			printfn(field.title..':')
			printfn(field.eqn(self))
		end
	end
end

-- print one
function Props:printField(fieldname, printfn)
	printfn = printfn or self.print
	for _,field in ipairs(self.fields) do
		if field.name == fieldname then
			assert(self[field.name])
			printfn(field.title..':')
			printfn(field.eqn(self))
		end
	end
end

-- TODO make it table-based arguments
-- overload self.verbose to output vars as you go
function Props:init(g, gU, c)
	local Tensor = require 'symmath'.Tensor

	self.c = c
	if self.verbose then self:printField'c' end

	-- TODO Tensor.meric accepts non-symmath tables
	-- soo I would need to convert them before outputting
	-- either move this below Tensor.metric, or convert before this line.
	self.g = g
	if self.verbose then self:printField'g' end

	local basis = Tensor.metric(g, gU)
	g = basis.metric
	self.g = g
	gU = basis.metricInverse
	self.gU = gU
	if self.verbose then self:printField'gU' end

	local dg = Tensor'_abc'
	dg['_abc'] = g'_ab,c'()
	self.dg = dg
	if self.verbose then self:printField'dg' end
	
	local expr = ((dg'_abc' + dg'_acb' - dg'_bca') / 2)
	if c then expr = expr + (c'_abc' + c'_acb' - c'_bca')/2 end
	local GammaL = Tensor'_abc'
	GammaL['_abc'] = expr()
	self.GammaL = GammaL
	if self.verbose then self:printField'GammaL' end

	local Gamma = GammaL'^a_bc'()
	self.Gamma = Gamma
	if self.verbose then self:printField'Gamma' end

	local dGamma = Tensor'^a_bcd'
	dGamma['^a_bcd'] = Gamma'^a_bc,d'()
	self.dGamma = dGamma
	if self.verbose then self:printField'dGamma' end

-- this is too slow.  for dim=4, Gamma^a_bc is 4^3 = 64 elements
-- the multiply always does the outer before the inner
-- and the outer operation is 4^6 = 4096 elements
-- TODO analyze the mulOp(TensorRef,TensorRef)
-- and if it has multiple indexes, keep track of them, transform the elements individually, sum them, and only generate the resulting indexes
-- (in this case, 4^4 = 256, much smaller)
-- another TODO to help optimization: keep track of symmetric/antisymmetric terms
	local GammaSq = Tensor'^a_bcd'
	GammaSq['^a_bcd'] = (Gamma'^a_ec' * Gamma'^e_bd')()
	self.GammaSq = GammaSq
	if self.verbose then self:printField'GammaSq' end

	local expr = (dGamma'^a_bdc' - dGamma'^a_bcd' + GammaSq'^a_bcd' - GammaSq'^a_bdc')
	if c then expr = expr - Gamma'^a_be' * c'_cd^e' end
	local RiemannU = Tensor'^a_bcd'
	RiemannU['^a_bcd'] = expr()
	self.RiemannU = RiemannU
	if self.verbose then self:printField'RiemannU' end

	local Riemann = RiemannU'^ab_cd'()
	self.Riemann = Riemann
	if self.verbose then self:printField'Riemann' end

	local Ricci = Tensor'^a_b'
	Ricci['^a_b'] = Riemann'^ca_cb'()
	self.Ricci = Ricci
	if self.verbose then self:printField'Ricci' end

	local Gaussian = Ricci'^a_a'()
	self.Gaussian = Gaussian
	if self.verbose then self:printField'Gaussian' end

	local Einstein = Tensor'^a_b'
	Einstein['^a_b'] = (Ricci'^a_b' - g'^a_b' * Gaussian)()
	self.Einstein = Einstein
	if self.verbose then self:printField'Einstein' end
end

return Props
