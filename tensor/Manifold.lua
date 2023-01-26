--[[
Should Manifold be an ... Expression?  a Set?  should Set be an Expressoin so that I can introduce set operators like 'union', 'exclusion', 'set-subtract' etc?
For now I think all Manifold will do is collect Chart's
Then maybe later it will handle calculation of transforms between charts

An n-manifold is a collection of points who have a neighborhood of a R^n Euclidian open ball
it is composed of charts that map from U to phi(U) which have a neighborhood of an open ball in R^n

for multiple charts, they use 'transition functions'
which can be deduced by providing an embedded manifold, and computing the chart mapping function jacobian and inverse

so if the range of phi(U) is R^n ... the domain doesn't have to be ...
but
--]]

local class = require 'ext.class'
local table = require 'ext.table'

local Manifold = class()

function Manifold:init(args)
	args = args or {}
	--[[
	Should a chart define its embedded manifold, or should the manifold specify its embeded manifold?
	Likewise, should this field be the embedded manifold, or should it be the embedded chart?
	For now I'll say the manifold will, so all charts a manifold possess are consistent
	--]]
	self.embedded = args.embedded

	--[[
	the dimension of a manifold is its chart range tangent space dimension ...
	but the # of coordinates is the domain dimension ...
	the difference is the vertical tangent space dimension
	(TODO later, this is going to get into tangent bundles, vertical bundles, horitzontal bundles ... )

	if chart is specified then this is redundant ...
	but if Chart is built after Manifold then, until then, dim isn't known ...
	should I allow Manifold to be allocated but not initialized?

	I'll make this optional for now
	and if it is present then I'll use it for index-expression-traces
	or should I use the chart coordinate count for the dim?
	yeah, first manifold.dim, next #chart.coords
	--]]
	self.dim = args.dim

	-- here's another construction issue:
	-- if I allow Manifold to accept Charts then Chart can't need a .manifold in its ctor
	-- I could instead pass Manifold the ctor args to Chart
	-- or I can just let Chart be built later ...
	self.charts = table()

	Manifold.last = self
end

--[[
shorthand for insert .manifold=self into the args
--]]
function Manifold:Chart(args)
	args = table(args):setmetatable(nil)
	args.manifold = self
	return require 'symmath.tensor.Chart'(args)
end

--[[
global
used for mapping from symbols to charts that have been constructed
TODO how to remove them from this list, other than manually?
used so that if someone initializes a Tensor (without explicitly specifying the chart)
then this lookup will be used
TODO should I even do this or just use M.charts?
--]]
--Manifold.allCharts = table()

-- TODO static function for global list, or just local?
function Manifold:findChartForSymbol(symbol)
	if not symbol then return self.charts[1] end
	local thisChart
	for _,chart in ipairs(self.charts) do
		if not chart.symbols then
			-- no symbols <=> uses all symbols
			-- but don't return until we've searched any chart that might have an explicit symbol set
			thisChart = chart
		else
			-- TODO use name=>true table for quick lookup
			if chart.symbols:find(symbol) then return chart end
		end
	end
	return thisChart
end


--[[
hmm, TODO, try to get rid of globals
this is used for Tensor to lookup a static reference,
in order to search through charts and find what symbol matches what chart

but as long as I have this here, and as long as I'm using Manifold.last for Tensor index -> Chart resolution
how about I always keep one default Manifold?

here's a good question:
multiple indexes, multipoint tensor, that means separate tangent spaces and tangent space operators
but does that mean separate charts?
is a multipoint tensor defined by a single chart with multiple sets of tangent space operators
 or is it defined by two charts with matching domains and distinct tangent space operators?
--]]
Manifold.default = Manifold()
Manifold.last = Manifold.default


return Manifold
