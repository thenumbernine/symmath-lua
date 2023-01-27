--[[


----------- original TensorCoordBasis class: -----------
TensorCoordBasis represents an entry in the coordSrcs
complete with
	variables = table of what variables are in this basis
		- if this is variables, assumes the basis is e_i = diff(variable[i])
		- if this is a function, uses the function to apply the basis
		- TODO rename to 'basis'
	symbols = what symbols are used to representing this basis
			symbols == nil means all symbols
			like Tensor variance, if there is a space present then symbols are assumed to be space-separated multi-chars
			otherwise they are assumed to be single chars
	(c) what metrics are used for raising/lowering
	[(d)] what linear transforms go between this and the other TensorCoordBasis's

	signature = array of signature associated with each variable, used as inner product with Hodge dual
----------- end original TensorCoordBasis class: -----------
--]]

local class = require 'ext.class'
local table = require 'ext.table'
local string = require 'ext.string'
local range = require 'ext.range'

local Chart = class()

function Chart:init(args)
	args = args or {}
	self.manifold = args.manifold or require 'symmath.tensor.Manifold'.last	-- if no Manifold is provided, then ... use the default? or use the last created?
	self.manifold.charts:insertUnique(self)
	self.coords = table(assert(args.coords))
	local n = #self.coords

	-- originally in tensor/TensorCoordBasis.lua
	-- nil means use all
	if args.symbols and #args.symbols > 0 then
		if args.symbols:find' ' then
			self.symbols = string.split(string.trim(args.symbols), ' ')
		else
			self.symbols = table()
			for i=1,#args.symbols do
				self.symbols[i] = args.symbols:sub(i,i)
			end
		end
	end

	-- TODO makek use of this
	-- in fact, if .manifold is provided, then this shouldn't be needed (instead use embedded.signature? or embedded.innerProduct?)
	if args.signature or self.symbols then
		local clone = require 'symmath.clone'
		self.signature = range(#(self.symbols or args.signature)):mapi(function(i)
			if args.signature then
				return clone(args.signature[i])
			end
			return require 'symmath.Constant'(1)
		end)
	end

	-- TODO inter-basis transforms as well?  i.e. vielbein would be the inter-transform from curved coords to Minkowski coords
	-- these can be inferred from the manifold.embedded if it is provided


	-- optional, generator, called after .coords is assigned (so the Tensor knows what dimension its indexes need to be)
	if args.metric then
		self:setMetric(args.metric())
	end

--[[
I don't like the idea of passing holonomic basis elements and overloading these operators to make the chart anholonomic.
However I don't like the idea of using the same variables in the holonomic and anholonomic case.
And I also don't like the idea of tacking on a single function into Variable solely for the purpose of Chart tangent space evaluation.
So here's my solution:
Define the chart using the holonomic coordinates.
Then, for anholonomic charts, use a second set of variables, (thetaHat, phiHat, etc), strictly for distinct indexes,
and define their associated tangentSpaceOperators in the Chart as differentiating wrt the original holonomic coordinates
... and then do whatever linear transform or whatever that you want to do.
--]]
	--[[
	optional
	default: use expr:diff(coords[i])

	TODO what to do for multipoint tensors (tensor with symbols associated with multiple charts
		best example of this: an embedding derivative i.e. a jacobian)
	another reason for a global registry of index symbols?
	--]]
	self.tangentSpaceOperators = args.tangentSpaceOperators
	if not self.tangentSpaceOperators then
		-- TODO should I allow shorthand specifying anholonomic operators via linear transform from the holonomic?
		-- or should I require a list of functions that linearly transform inputs manually?
		self.tangentSpaceOperators = self.coords:mapi(function(xi)
			return function(expr)
				return expr:diff(xi)	-- ... evaluate?
			end
		end)

		-- originally in tests/metric catalog.lua
		-- if we want to shorthand the anholonomic operator linear system:
		if args.eHolToE then
			local Matrix = require 'symmath.Matrix'
			local Constant = require 'symmath.Constant'
			local eHolToE = args.eHolToE
			for i=1,n do
				local onesi = Matrix:lambda({1,n}, function(_,j) return j==i and 1 or 0 end)
				if eHolToE[i] == onesi[1] then
					self.tangentSpaceOperators[i] = function(expr)
						return expr:diff(self.coords[i])
					end
				else
					self.tangentSpaceOperators[i] = function(expr)
						local sum = Constant(0)
						for j=1,n do
							sum = sum + eHolToE[i][j] * expr:diff(self.coords[j])
						end
						return sum()
					end
				end
			end
		end
	else
		self.tangentSpaceOperators = table(self.tangentSpaceOperators)
		assert(#self.tangentSpaceOperators == n, "expected number of tangentSpaceOperators to equal number of coords")
	end


	-- previously in tests/metric catalog.lua
	-- now in hydro-cl/hydro/coord/coord.lua
	local a,b,c = 'a', 'b', 'c'
	if self.symbols then
		if #self.symbols >= 3 then
			a,b,c = table.unpack(self.symbols, 1, 3)
		else
			a,b,c = nil,nil, nil	-- silent fail.  TODO how about a warning somehow?
		end
	end
	if a then
		self.commutation = self:Tensor{indexes=' _'..a..' _'..b..' ^'..c}
		local Constant = require 'symmath.Constant'
		local Variable = require 'symmath.Variable'
		local factorLinearSystem = require 'symmath.factorLinearSystem'
		local zeta = Variable('\\zeta', self.coords)
		local dzeta = table.mapi(self.coords, function(xk) return zeta:diff(xk) end)
		for i,di in ipairs(self.tangentSpaceOperators) do
			for j,dj in ipairs(self.tangentSpaceOperators) do
				local diff = di(dj(zeta)) - dj(di(zeta))
				local diffEval = diff()
				if not Constant.isValue(diffEval, 0) then
					local A,b = factorLinearSystem({diff}, dzeta)
					-- now extract zeta:diff(uk)
					-- and divide by e_k to get the correct coefficient
					-- TODO this assumes that e_a is only a function of partial_a
					-- if e_a is a linear combination of e_a^b partial_b then you can work it out to find
					-- c_ab^d = (e^-1)_c^d (e_a^r e_b^c_,r - e_b^r e_a^c_,r)
					-- TODO put this somewhere else so everyone can use it
					assert(Constant.isValue(b[1][1], 0))
					for k,dk in ipairs(self.tangentSpaceOperators) do
						local coeff = (A[1][k] * dzeta[k] / dk(zeta))()
						-- assert dphi is nowhere in coeff ...
						self.commutation[i][j][k] = coeff
					end
				end
			end
		end
	end

	--self.allCharts:insert(self)
end

-- originally in Tensor.metric()
--[[
replaces the specified coordinate basis metric with the specified metric
returns the TensorBasis object

usage:
	chart:setMetric(m, nil) 	<- replaces the metric of the chart, calculates the metric inverse
	chart:setMetric(nil, mInv)	<- replaces the metric inverse of the chart, calculates the metric
	chart:setMetric(m, mInv)	<- replaces both the metric and the metric inverse of the chart
	chart:setMetric(nil, nil) 	<- clears the metric and inverse
--]]
function Chart:setMetric(metric, metricInverse)
	assert(metric or metricInverse, "why did you call this function if you weren't providing a metric or an inverse?")
	if metric or metricInverse then
		local Matrix = require 'symmath.Matrix'
		self.metric = metric or Matrix.inverse(metricInverse)
		self.metricInverse = metricInverse or Matrix.inverse(metric)
	else
		self.metric = nil
		self.metricInverse = nil
		return
	end

	-- TODO make this its own function of Chart?
	-- and TODO how about a global registry somewhere of what chart is associated with what symbols?
	local a,b
	if self.symbols then
		if #self.symbols < 2 then
			error("found a Chart with only one symbol, when you need two to represent the metric tensor: " .. require 'ext.tolua'(self))
		end
		-- TODO seems findChartForSymbol isn't set up to support space-separated symbol strings ...
		a = self.symbols[1]
		b = self.symbols[2]
	else
		a, b = 'a','b'
	end
	assert(a and b and #a>0 and #b>0)

	local Tensor = require 'symmath.Tensor'
	if not Tensor:isa(self.metric) then
		self.metric = Tensor{
			indexes = {'_'..a, '_'..b},
			values = self.metric,
		}
	end
	if not Tensor:isa(self.metricInverse) then
		self.metricInverse = Tensor{
			indexes = {'^'..a, '^'..b},
			values = self.metricInverse,
		}
	end
end

--[[
TODO how to override 'chart=self' when Tensor ctor is vararg and usually not with tables ...
TODO but do this during construction
because the indexes need to know the chart coordinate dimension
I might have to get rid of vararg init of Tensor?
or make arg init .values= synonymous with vararg?
or do I even need this as a member function?

Instead I can just infer dimension from the chart associated with each index of the Tensor
but what about overlapping indexes that are used in the list of symbols for multiple Charts?
--]]
function Chart:Tensor(...)
	local t = table.pack(...)
	local args = t[1]
	-- TODO when is 'args' ctor arguments and when it is some Tensor to :clone() ?
	assert(type(args) == 'table', "hmm, I'm working out the kinks of this")
	args = table(args):setmetatable(nil)
	args.chart = self
	t[1] = args
	--args.chart = self?
	return require 'symmath.Tensor'(t:unpack())
	--result.chart = self?
end

return Chart
