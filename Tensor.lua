--[[
thoughts on transformation between different sets of indexes:

transformIndexes works fine between upper and lower, using the metric and its inverse
	I think I have some sort of implicit subset working for my adm calculations between 4D and 3D that just chops off a letter (and neglects the 4D projection part)
	... based on the fact that the 3D part of the ADM metric is the 3D spatial metric, and the 3D part of the ADM metric inverse is the 3D spatial metric inverse plus an outer of shift vectors
	... which are orthogonal to the spatial metric (so any spatial terms only operate with the 3D portion anyways)
	
so neglect aside, what is the correct way I should be doing this?

each index set needs a metric (and an inverse, which can be calculated)
...and between each index set needs transform matrices (and their inverses, which can be calculated)
...and between subsequent coordinate systems we can calculate combined transformations

ex:
local t,x,y,z = symmath.vars('t', 'x', 'y', 'z')
local curvedVars = {t,x,y,z}
local tHat, xHat, yHat, zHat = symmath.vars('\hat{t}', '\hat{x}', '\hat{y}', '\hat{z}')
local flatVars = {tHat,xHat,yHat,zHat}
local r, theta, phi = symmath.vars('r, '\\theta', '\\phi')
local eta = Tensor{indexes='_IJ', values=Matrix.identity(#flatVars)}
local u = Tensor('^I', table.unpack(symmath.Vector.sphericalToCartesian(r, theta, phi)))
local e = Tensor{indexes='_u^I', values=u'^I_,u':simplify())
local g = (e'_u^I' * e'_v^J' * eta'_IJ')
local manifold = Tensor.Manifold()
local curvedChart = manifold:Chart{coords=curvedVars, symbols='a-z', metric=function() return g end}				-- 4D curved space
local flatChart = manifold:Chart{coords=flatVars, symbols='I-N', metric=function() return eta end}	-- 4D Minkowski space
--TODO This part ...
manifold:setTransforms{from=curvedSpace, to=flatSpcae, transform=e}

Metric.setTransforms would be the new function
transform= would specify the tensor to transform between coordinate systems
a convention would have to be established such that ...
(for a-h the system from and i-n the system to)

e_a^i e_b^j eta_ij = g_ab
e_a^i e_b^j g^ab = eta_ij
e^a_i e^b_j eta^ij = g^ab
e^a_i e^b_j g_ab = eta_ij

e_a^i v^a = v^i transforms v upper from a->i
e_a^i v_i = v_a transforms v lower from i->a
e^a_i v_a = v_i transforms v lower from a->i
e^a_i v^i = v^a transforms v upper from i->a

it turns out if you do the math, you just need to provide one transform from 'from' to 'to'
then the inverse accomplishes the other direction,
and between uppers and lowers, raising/lowering metrics accordingly
 (in the correct coordinate system) gets you what you want

the thing to be careful of is index order.
http://physics.stackexchange.com/questions/142836/correct-tetrad-index-notation

e_u^I != e^I_u no matter how many papers this is incorrectly stated in

typical linear transforms in index notation have the 'from' as the second coordinate
 and the 'to' as the first: y_i = a_ij x_j
typical vielbein representation follow the same:

metric transformsations:  g_uv = e_u^I e_v^J eta_IJ
inverse metric transformations: eta^IJ = g^uv e_u^I e_v^J

by some linear math we find that, once this is specified,
we can find the inverse transform by either
(1) compute the transpose inverse of the transform metric
(2) raise/lower indexes (i.e. multiply rhs by 'from' metric and lhs by 'to' metric inverse)



also:
Tensor.tangentSpaceOperators{diff(t), diff(x), diff(y), diff(z)}

or equivalent for commutation basis
but that only makes sense in combination with a chart...
and can be used to derive the metric
which, alternatively, we can just ignore the tangent space operators and allow the metric to be specified

and then instead of transforms, use "Chart" objects, and forward/inverse transforms ...


local M = Tensor.Manifold()

-- manifolds have multiple charts. how to handle that?  how to make sure the multiple charts overlap wrt their respective coordinate bounds?
--
local C = Tensor.Chart{
	manifold = M,
	coordinates (or "variables"?) = {x1, x2, ..., xN},

	-- optional
	-- if chart isn't provided then a metric should be.
	chartEmbeddedFunction = function(x)
		-- in order to even build this, a separate set of coordinates / embedded space needs to be defined
		-- or do I need a set of indexes for embedded variables?
		-- I could reproduce that behavior with just an array of expressions and an inner product function
		return Tensor('^I', function(x1, ...) ... end)
	end,

	-- accepts chart() output a and b, returns an expression for the inner product
	-- optional, required for chart() (or should it be optional of chart() is provided as a Tensor of another chart)
	chartInnerProduct = function(a,b)
		local i = var'i'
		-- TODO this isn't possible now, since __index doesn't return an expression itself
		-- but it is possible in Maxima ... so ... maybe I should support it?
		return Sum(a[i] * b[i], i, 1, N)
	end,

	-- or optionally, should I just provide embeddedChart() that returns a Tensor in the chart's coordinates?
	-- and then the inner product is already defined in the embedded chart's space
	-- but in that case, how to handle indexes?
	
	-- in presence of a chart (and basis operators), the metric can be calculated
	-- in absence of it, metric can be provided to describe the manifold behavior
	metric = function(),
		-- this will either be a Tensor (though creating a Tensor means the coordinates are specified, so the ctor know how many dimensions to require for each of its indexes)
		-- or this can be Tensor args, or a function that generates the metric (most flexible?)
		return Tensor('_uv', ...)
	end,

	-- default operators would be coordinate derivatives
	-- the comma index will defer to this
	-- honestly 'tangentSpaceOperators' is the same as overriding Variable:applyDiff
	-- which is better?  should 'applyDiff' even be a thing, since the only place it is used is in Ref for evaluating comma derivative indexes?
	-- so that's a thing: replace Variable:applyDiff() and Tensor.coords{{variables=...}} with Chart.tangentSpaceOperators[]
	tangentSpaceOperators = {
		function(u, x1, x2, ...) return u:diff(x1) end,
		function(u, x1, x2, ...) return u:diff(x2) end,
		...
	},
}

-- returns a (1 0) tensor-of-variables whose domain is the chart (subject to constraints of chart coordinate boundaries)
local x = C:point()

-- returns ... what?  a list of operators?  a list of basis vectors?
local Tx = C:tangentSpace(x)

-- and then for creating tensors, who do I request?
-- the manifold?  nah, it could have multiple charts/multiple coordinates per chart
-- the chart? maybe
-- the tangent space?  since the tensor exists within the tangent space.
-- but then we end up - just to get rolling - having to make all these things first: manifold, chart, point, tangent-space ...
-- and the point will be made of variables anyways so ... it is implicit already in the variables provided to the Chart constructor
-- so, probably, C:tensor(...) => shorthand for Tensor{..., chart=C}


indexes is a question of its own though, since I have *) indexes and *) variables,
and the two act separately for now, but there is crossover in usage when it comes to derivatives (comma deriv vs :diff())
and I want to unify the two somehow, especially wrt the Variable:setDependantVars() functionality ...
... I want to bring that over to the comma deriv and indexes so that comma deriv can implicitly know when to simplify to zero or not (or who knows, even expand to transforms)

so how would that look?
same as it already does? C ctor "symbols='IJKLMN'" ?
and then (store somewhere?) that those tensor index symbols are now associated with this chart,
so that comma using those symbols will simplify based on the letter's variables + the chart's coordinate variables


--]]

local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local string = require 'ext.string'
local Expression = require 'symmath.Expression'
local Array = require 'symmath.Array'
local symmath

--[[
general-purpose degree-1 (successive nesting for degree-n) structure
to be used as vectors, vectors of them as matrices, etc ...
--]]
local Tensor = class(Array)

Tensor.name = 'Tensor'

-- Array is non-commutative
-- because the child class Matrix is non-commutative
-- and frankly, how is multipliction of arrays well-defined?
-- but because Tensor has indexes, now we can commute our objects before carrying out multiplication
Tensor.mulNonCommutative = false

-- namespace:
Tensor.Ref = require 'symmath.tensor.Ref'

Tensor.Index = require 'symmath.tensor.Index'

Tensor.Manifold = require 'symmath.tensor.Manifold'

Tensor.Chart = require 'symmath.tensor.Chart'

Tensor.LeviCivita = require 'symmath.tensor.LeviCivita'

Tensor.DenseCache = require 'symmath.tensor.DenseCache'

-- TODO finishme
Tensor.dual = require 'symmath.tensor.dual'


--[[
how to deal with index symbols
by default use a-z for index symbols
honestly nothing in Tensor uses this, only Expression for its Tensor index stuff applied to all expressions

where to put this?
I was thinking put it in Chart, because Chart is defined with sets of symbols
I was thinking Manifold, since Manifold has lookup for chart based on symbol
I was thinking Tensor, since Tensor is the namespace of all of this
--]]
Tensor.defaultSymbols = require 'symmath.tensor.symbols'.latinSymbols


--[[
TODO Tensor construction:
	- (optional) first argument tensor variance
		- string that is parsed: '_ijk', etc
		- table-of-TensorIndex objects (already in processed form that is returned by parseIndexes)
		- aka args.indexes
	- (optional) n-many dimension numbers of lua numbers or Constants
		- aka args.dim
	- (optional) final argument value generator
		- function that accepts n parameters (for n degree of tensor)
		- table that is n nestings deep (for n degree of tensor)
		- aka args.values

information the constructor needs...
possible combinations:
* * *      	/ contra/covariant + index information (includes variance and dimensions, excludes optional values)
      * *  	\ list of dimension (excludes variance and optional values)
  *       *	/ dense content: expressions as nested tables (includes dimensions, excludes variance)
    *   *  	\ lambdas for content generation (includes values, excludes dimension or variance)

... NOTICE I'm getting rid of non-dense .. I'll just have deferred indexes on *all* expressions, variables included, which will serve the same
now that index evaluation is deferred, value-less tensors can be represented as variables with unevaluated index dereferences:
g = var'g'; g'_ij'	<- will give you a variable with unevaluated dereference _ij.
	evaluating it will cause an error, unless you substitute g for a proper Tensor object

constructors:
	contra/co-variant alone:
		Tensor(string)
		Tensor'^i' = contravariant degree-1
		Tensor'_ij' = covariant degree-2
		Tensor'^i_jk' = mixed degree-3
			default goes to ... contra? co? or neither / separate associated metric?
			associate indexes with metrics?
			functions for converting from/to different basii?

	contra/co-variant + dense values:
		Tensor(string, table)
		Tensor('^i', {1,2,3}) = contravariant degree-3 tensor w/initial values
							(error upon mismatch sizes, or only use what you can / fill the rest with zero?)

	contra/co-variant + sparse values:
		Tensor(string, function)
		Tensor('^ij', function(i,j) return ... end)

	dimensions:
		Tensor(number...)			<- conflict with the dense value definition

	dimensions + lambda:
		Tensor(number..., function)

	dense content:
		Tensor([number|table]...)	<- conflict with dimensions constructor

interpretations:
	Tensor(string) => contra/co-variance
	Tensor(string, function) => contra/co-variance + lambda callback
	Tensor(string, table) => contra/co-variance + dense value
	Tensor(table, function) => contra/co-variance + lambda callback
	Tensor(table, table) => contra/co-variance + dense values
	Tensor(number...) => dense values
	Tensor{dim=table, values=table} => dimension list + lambda callback
	Tensor{dim=table} => dimension list
	Tensor{}

Tensor static members:
	- association of indicies to coordinates

manifold = Tensor.Manifold()
chart = manifold:Chart{coords={t,x,y,z}}
spatialChart = manifold:Chart{symbols='ijk', coords={x,y,z}}
cartesianChart = manifold:Chart{symbols='IJK', coords={whatever flat space vielbein indices you want to use}}

- coordinate transformation information ...
	i.e. lower txyz to upper txyz basis transforms with g^uv,
		upper txyz to lower txyz transforms with g_uv
		lower txyz to lower TXYZ transforms with e_I^u, etc

Tensor have the following attributes:
	- degree (list of dimensions) <- right now dynamcially calculated via :degree()
	- list of associated basis (contra-/co-/neither)
	- associated indices / index ranges?  g_uv spans txyz vs g_ij spans xyz
--]]
function Tensor:init(...)
	symmath = symmath or require 'symmath.namespace'()
	local Constant = symmath.Constant
	local TensorIndex = self.Index
	
	local args = {...}

	local argsAreNamed = type(args[1]) == 'table'
		and (type(args[1].dim) == 'table'
			or type(args[1].indexes) == 'table'
			or type(args[1].indexes) == 'string')

	local valueCallback
	if type(args[#args]) == 'function' then
		valueCallback = table.remove(args)
	elseif argsAreNamed then
		valueCallback = args[1].values
	end

	--[[
	Tensor{[dim={dim1, dim2, ..., dimN}][, values=function(x1,...,xN) ... end)][, indexes={...}]}
		either dim or indexes must be used
	--]]
	if argsAreNamed then
		-- one of these two variables should be defined:
		self.variance = args[1].indexes and TensorIndex.parseIndexes(args[1].indexes) or {}
		local dim = args[1].dim
		--if dim and args[1].indexes then error("can't specify dim and indexes") end
		if dim then
			assert(type(dim) == 'table')
			dim = range(#dim):map(function(i)
				local di = dim[i]
				if Constant:isa(di) then di = di.value end
				assert(type(di) == 'number')
				return di
			end)
			-- construct content from default of zeroes
			local subdim = table(dim)
			local thisdim = subdim:remove(1)
			
			local superArgs = {}
			for i=1,thisdim do
				if #subdim > 0 then
					local subindexes = self.variance and setmetatable(table.sub(self.variance, 2), nil) or nil
					superArgs[i] = Tensor{indexes=subindexes, dim=subdim}
				else
					superArgs[i] = Constant(0)
				end
			end
			Expression.init(self, table.unpack(superArgs))
		else
			-- construct content from default of zeroes
			local subVariance = table(self.variance)
			local firstVariance = table.remove(subVariance, 1)
			
			local chart = self:findChartForSymbol(firstVariance.symbol)
			assert(chart, "looks like you haven't created a chart yet, so I don't know how to determine the dimension of the indexes")

			local superArgs = {}
			for i=1,#chart.coords do
				if #subVariance > 0 then
					superArgs[i] = Tensor(subVariance)
				else
					superArgs[i] = Constant(0)
				end
			end
			Expression.init(self, table.unpack(superArgs))
		end
	else
	
		--[[
		Tensor'^i'
		Tensor'_jk'
		Tensor'^a_bc'
		--]]
		-- got a string of indexes
		if type(args[1]) == 'string'
		-- got an array of TensorIndexes
		or (type(args[1]) == 'table' and TensorIndex:isa(args[1][1]))
		then
			
			local indexes = table.remove(args, 1)
			
			-- *) parse string into indicies (and what chart they belong to) and contra- vs co- variance
			-- should I make a distinction for multi-letter variables? not allowed for the time being ...
			self.variance = TensorIndex.parseIndexes(indexes)

			-- *) complain if there is no Tensor.coords assignment
			-- *) store index information (in this tensor and subtensors ... i.e. this may be {^i, _j, _k}, subtensors would be {_j, _k}, and their subtensors would be {_k}
			-- *) build an empty tensor with degree according to the chart size of the indices

			if #args > 0 then
				-- assert that the sizes are correct
				local subVariance = table(self.variance)
				table.remove(subVariance, 1)
			
				Expression.init(self, table.unpack(args))
				
				-- matches below
				for i=1,#self do
					local x = self[i]
					assert(type(x) == 'table', "tensors can only be constructed with Expressions or tables of Expressions")
					if not Expression:isa(x) then
						-- then assume it's meant to be a sub-tensor
						x = Tensor(subVariance, table.unpack(x))
						self[i] = x
					end
				end
		
			else
				-- construct content from default of zeroes
				local subVariance = table(self.variance)
				local firstVariance = table.remove(subVariance, 1)
				local chart = self:findChartForSymbol(firstVariance.symbol)

				local superArgs = {}
				for i=1,#chart.coords do
					if #subVariance > 0 then
						superArgs[i] = Tensor(subVariance)
					else
						superArgs[i] = Constant(0)
					end
				end
				Expression.init(self, table.unpack(superArgs))
			end
		--[[
		Tensor({row1}, {row2}, ...)
		--]]
		else
			-- if we get a list of tables then call super init ...
			Expression.init(self, ...)

			-- default: covariant?
			-- TODO create defaults according to children (from the Expression.init(self, ...) call)
			self.variance = {}
		
			-- now that children are stored, construct them as lower-degree objects if the arguments were provided implicitly as metatable-less tables
			-- this way we know all children (a) are Tensors and have a ".degree" field, or (b) are non-Tensor Expressions and are degree-0
			for i=1,#self do
				local x = self[i]
				assert(type(x) == 'table', "tensors can only be constructed with Expressions or tables of Expressions")
				if not Expression:isa(x) then
					-- then assume it's meant to be a sub-tensor
					x = Tensor(table.unpack(x))
					self[i] = x
				end
			end
		end
	end

	if valueCallback then
		symmath = symmath or require 'symmath.namespace'()
		local clone = symmath.clone
		for index,_ in self:iter() do
			if type(valueCallback) == 'function' then
				self[index] = clone(valueCallback(table.unpack(index)))
			elseif Array:isa(valueCallback) then
				self[index] = clone(valueCallback[index])
			end
		end
	end
end

function Tensor:clone(...)
	local copy = Tensor.super.clone(self, ...)
	for i=1,#self.variance do
		copy.variance[i] = self.variance[i]:clone()
	end
	return copy
end

--[=[
function Tensor.match(a, b, matches)
	if not Tensor.super.match(a, b, matches) then return false end
--[[
	assert(#a.variance == #b.variance)
	for i=1,#a.variance do
		if a.variance ~= b.variance then return false end
	end
--]]
	return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
end
--]=]

--[[
produce a trace between dimensions i and j
store the result in dimension i, removing dimension j
--]]
function Tensor:trace(i,j)
	symmath = symmath or require 'symmath.namespace'()
	local clone = symmath.clone

	if i == j then
		error("cannot apply contraction across the same index: "..i)
	end

	local dim = self:dim()
	if dim[i] ~= dim[j] then
		error("tried to apply tensor contraction across indices of differing dimension: "..i.."th and "..j.."th of "..table.concat(dim, ','))
	end
	
	local newdim = table(dim)
	-- remove the second index from the new dimension
	local removedDim = table.remove(newdim,j)
	-- keep track of where the first index is in the new dimension
	local newdimI = i
	if j < i then newdimI = newdimI - 1 end
	
	local newVariance = {table.unpack(self.variance)}
	table.remove(newVariance, j)

	return Tensor{
		indexes = newVariance,
		dim = newdim,
		values = function(...)
			local indexes = {...}
			-- now when we reference the unremoved dimension

			local srcIndexes = {table.unpack(indexes)}
			table.insert(srcIndexes, j, indexes[newdimI])
			
			return self:get(srcIndexes)
		end,
	}
end

--[[
this removes the i'th dimension, summing across it

if it removes the last dim then a number is returned (rather than a 0-degree tensor, which I don't support)
--]]
function Tensor:contraction(i)
	symmath = symmath or require 'symmath.namespace'()
	local clone = symmath.clone
	
	local dim = self:dim()
	if i < 1 or i > #dim then error("tried to contract dimension "..i.." when we are only degree "..#dim) end

	-- if there's a valid contraction and we're degree-1 then we're summing across everything
	if #dim == 1 then
		local result
		for i=1,dim[1] do
			if not result then
				result = self[i]
			else
				result = result + self[i]
			end
		end
		return result
	end

	local newdim = table(dim)
	local removedDim = table.remove(newdim,i)

	local newVariance = {table.unpack(self.variance)}
	table.remove(newVariance, i)

	return Tensor{
		indexes = newVariance,
		dim = newdim,
		values = function(...)
			local indexes = {...}
			table.insert(indexes, i, 1)
			local result
			for index=1,removedDim do
				indexes[i] = index
				if not result then
					result = self:get(indexes)
				else
					result = result + self:get(indexes)
				end
			end
			return result
		end,
	}
end

function Tensor:simplifyTraces()
	local modified
	repeat
		modified = false
		for i=1,#self.variance-1 do
			for j=i+1,#self.variance do
				if self.variance[i].symbol == self.variance[j].symbol then
					self = self:trace(i,j):contraction(i)
					if not Tensor:isa(self) then
						return self:simplify()	-- if it's a scalar then return
					end
					modified = true
					break
				end
			end
			if modified then break end
		end
	until not modified
	return self:simplify()
end

--[[
for all permutations of indexes other than i,
take each vector composed of index i
transform it by the provided degree-2 tensor
and store it back where you got it from
--]]
function Tensor:transformIndex(ti, m)
	local dim = self:dim()
	local mdim = m:dim()
	if m:degree() ~= 2 then error("can only transform an index by a degree-2 metric, got a degree "..m:degree()) end
	if mdim[1] ~= mdim[2] then error("can only transform an index by a square metric, got dims "..mdim:concat', ') end
	if dim[ti] ~= mdim[1] then error("tried to transform tensor of dims "..dim:concat', '.." with metric of dims "..mdim:concat', ') end
	return Tensor{dim=dim, values=function(...)
		-- current element being transformed
		local is = {...}
		local vxi = is[ti]	-- the current coordinate along the vector being transformed
		
		local result = 0
		for vi=1,mdim[1] do
			local vis = {table.unpack(is)}
			vis[ti] = vi
			result = result + m:get{vxi, vi} * self:get(vis)
		end
		
		return result
	end}
end

function Tensor:applyRaiseOrLower(i, tensorIndex)
	local t = self:clone()

	-- TODO this matches Tensor:__call
	local srcChart = self:findChartForSymbol(t.variance[i].symbol)
	local dstChart = self:findChartForSymbol(tensorIndex.symbol)

-- TODO what if the tensor was created without variance?
	if tensorIndex.lower ~= t.variance[i].lower then
		-- how do we handle raising indexes of subsets
		local metric = (dstChart and dstChart.metric) or (srcChart and srcChart.metric)
		local metricInverse = (dstChart and dstChart.metricInverse) or (srcChart and srcChart.metricInverse)
		
		if not metric then
			error("tried to raise/lower an index without a metric:"..tostring(self))
		end
	
		local tdim = t:dim()
		if tdim[i] ~= metric:dim()[1]
		or tdim[i] ~= metricInverse:dim()[1]
		then
			print("can't raise/lower index "..i.." until you set the metric tensor to one with dimension matching the tensor you are attempting to raise/lower")
			print(i.."'th dim")
			print("  your tensor's dimensions: "..table.concat(tdim, ','))
			print("  metric dimensions: "..table.concat(metric:dim(),','))
			print("  metric inverse dimensions: "..table.concat(metricInverse:dim(),','))
			error("you can reset the metric tensor via the Chart:setMetric() function")
		end
		
		-- TODO generalize transforms, including inter-basis-symbol-sets
	
		local oldVariance = table.mapi(t.variance, function(v) return v:clone() end)
		if tensorIndex.lower and not t.variance[i].lower then
			t = t:transformIndex(i, metric)
		elseif not tensorIndex.lower and t.variance[i].lower then
			t = t:transformIndex(i, metricInverse)
		else
			error("don't know how to raise/lower these indexes")
		end
			
		symmath = symmath or require 'symmath.namespace'()
		t = symmath.simplify(t)
		t.variance = oldVariance
		t.variance[i].lower = tensorIndex.lower
	end

	return t
end

-- permute the tensor's elements according to the dest variance
-- TODO rename to something that makes more sense? :form() or something, idk,
-- this function is used for reshaping internal form and index ordering
-- maybe 'permute' is good.  maybe 'form' is good.
-- maybe 'reshape'
-- maybe I should have (variance string, tensor) as ctors for Tensor()'s and then permute them there, but then what about 1x1x1 tensor initialization?
function Tensor:permute(dstVariance)
	if type(dstVariance) == 'string' then
		local TensorIndex = self.Index
		dstVariance = TensorIndex.parseIndexes(dstVariance)
	end
	
	-- determine index remapping
	local indexMap = {}
	for i,srcVar in ipairs(self.variance) do
		indexMap[i] = table.find(dstVariance, nil, function(dstVar)
			return srcVar.symbol == dstVar.symbol
		end)
		if not indexMap[i] then
			error("assigning tensor with '"..srcVar.symbol.."' to tensor without that symbol: "..self)
		end
	end

	local olddim = self:dim()
	local newdim = {}
	for i=1,#olddim do
		newdim[i] = olddim[indexMap[i]]
	end

	-- perform assignment
	local success, result = xpcall(function()
		return Tensor{
			indexes = dstVariance,
			dim = newdim,
			values = function(...)
				local dstIndex = {...}
				local srcIndex = {}
				for i=1,#dstIndex do
					srcIndex[i] = dstIndex[indexMap[i]]
				end
				return self:get(srcIndex)
			end,
		}
	end, function(err)
		return "failed for tensor "..self.."\n"
			.. "when converting it to variance "..table.mapi(dstVariance, tostring):concat', '.."\n"
			..err..'\n'..debug.traceback()
	end)
	if not success then error(result) end
	return result
end

-- have to be copied?

-- TODO make this and call identical
-- ... or not.  __call was moved to Expression so expressions could be indexed
Tensor.__index = function(self, key)
	-- parent class access
	local metavalue = getmetatable(self)[key]
	if metavalue then return metavalue end

	-- get a nested element
	if type(key) == 'table' then
		return self:get(key)
	--elseif type(key) == 'string' then	-- TODO interpret index notation
	end

	-- self class access
	local value = rawget(self, key)
	if value then return value end

	-- last fallback to __call
--	return self.__call(self, key)
end

Tensor.__newindex = function(self, key, value)

	-- TODO if value is a Tensor.Ref then run the Tensor.Ref prune transformation ...

	-- I don't think I do much assignment-by-table ...
	--  except for in the Visitor.lookupTable ...
	-- otherwise, looks like it's not allowed in Arrays, where I've overridden it to be the setter
	if type(key) == 'table' then
		self:set(key, value)
		return
	end

	-- handle assignment by tensor indexes
	if type(key) == 'string'
	and (key:sub(1,1) == '^' or key:sub(1,1) == '_')
	then
		local TensorIndex = self.Index
		local dstVariance = TensorIndex.parseIndexes(key)

		-- assert no comma derivatives
		for _,dstVar in ipairs(dstVariance) do
			assert(not dstVar.derivative, "can't assign to a partial derivative tensor")
		end

		-- if we're assigning a non-tensor to a tensor
		-- then implicitly wrap it in a tensor
		if not Tensor:isa(value) then
			symmath = symmath or require 'symmath.namespace'()
			local clone = symmath.clone
			value = Tensor(dstVariance, function(...) return clone(value) end)
		end

		-- raise/lower self according to the key
		-- also apply any change-of-coordinate-system transform
		-- but don't apply subsets of basis
		local dst = self:clone()
		for i=1,#dstVariance do
			dst = dst:applyRaiseOrLower(i, dstVariance[i])
		end

-- [====[ ok now I'm going to do this in :prune()
-- ... but what about subtensor assignment?
-- or was that pruning indexes in Tensor ctor?
-- did I just not do a thorough enough job in Tensor ctor?
		--[[
		for all non-number indexes
		gather all variables of each of those indexes
		iterate across all
		... or, alternatively, wrap all single-variable dstVariance indexes that don't show up in value's variance
		but what if there are two instances of the same single-variable?
		you will have to mark them off as you find them ...
		first find which single-variable indexes exist in both
		then, if there are any left in 'dstVariance', wrap 'value' in those
		
		without this, g['_tt'] = 2 will fail ... and must be written g['_tt'] = Tensor('_tt', 2)
		or g['_ti'] = A'_i' will fail ... and must be written g['_ti'] = Tensor('_ti', A)
		--]]
--print('value variance',table.unpack(value.variance))
--print('dest variance',table.unpack(dstVariance))
		local function mapSingleIndexes(v,k,t)
--print('v.symbol',v.symbol)
			local chart = self:findChartForSymbol(v.symbol)
--print('chart',chart,'variables',chart and #chart.coords)
			return (chart and #chart.coords == 1 and k or nil), #t+1
		end
		local valueSingleVarIndexes = table.mapi(value.variance, mapSingleIndexes)
		local dstSingleVarIndexes = table.mapi(dstVariance, mapSingleIndexes)
--print('value single vars',valueSingleVarIndexes:unpack())
--print('self single vars',dstSingleVarIndexes:unpack())
		for _,dstIndex in ipairs(dstSingleVarIndexes) do
			local v = dstVariance[dstIndex]
			local k = valueSingleVarIndexes:find(nil, function(valueIndex) return v.symbol == value.variance[valueIndex].symbol end)
			if k then
				valueSingleVarIndexes:remove(k)
			else
				-- wrap it in the single-variable index
--print('from ',value)
				local TensorIndex = self.Index
				value = Tensor(table{
					TensorIndex{
						lower = v.lower,
						derivative = not assert(not v.derivative),
						symbol = v.symbol,
					}
				}:append(value.variance), value)
				-- since we're wrapping the value tensor in a new index, increment all the index indexes
				for i=1,#valueSingleVarIndexes do
					valueSingleVarIndexes[i] = valueSingleVarIndexes[i] + 1
				end
--print('to ',value)
			end
		end
		-- if any are left then remove them
		if #valueSingleVarIndexes > 0 then
--print('we still have '..#valueSingleVarIndexes..' left of ',table.mapi(value.variance,tostring):concat',',' at ',valueSingleVarIndexes:unpack())
			value = Tensor(
				-- remove the rest of the single-variance letters
				table.filter(value.variance, function(v,k)
					return not valueSingleVarIndexes:find(k)
				end), function(...)
					local is = {...}
					for i=#valueSingleVarIndexes,1,-1 do
						table.insert(is, valueSingleVarIndexes[i], 1)
					end
					return value[is]
				end)
		end
--]====]

--[====[ TODO what was I about to do here?
		for _,variance in ipairs(dstVariance) do
			local chart = self:findChartForSymbol(variance.symbol)
			if #chart.coords == 1 then
				local variable = chart.coords[1]
			end
		end
--]====]

		-- simplify any expressions ... automatically here?
		--if not Tensor:isa(value) then value = value:simplify() end

		-- permute the indexes of the value to match the source
		-- TODO no need to permute it if the index is entirely variables/numbers, such that the assignment is to a single element in the tensor
--print('permuting...')
		local dst = value:permute(dstVariance)
--for i=1,#dst do print('dst['..i..']', dst[i]) end
		-- reform self to the original variances
		-- TODO once again for scalar assignment or subset assignment
--print('applying variance...')
		dst = dst(self.variance)
--for i=1,#dst do print('dst['..i..']=', dst[i]) end
--print('simplifying...')
		
		dst = dst()
--print('assigning from dst\n'..dst)
-- applying variance to dst puts dst into dst[1] because the subindex isn't there ...

--print('all dst iters:')
--for is in dst:iter() do print(table.concat(is, ',')) end
--print('...done')
		
		--[[ copy in new values
		for is in self:iter() do
--print('index is',table.concat(is, ','), ' assigning '..dst[is]..' to '..self[is])
			self[is] = dst[is]
		end
		--]]
		-- [[ only copy over values in the dst variance
		for isrc in self:iter() do
			-- isrc holds the iter of assignment ... might not be assigned if dstVariance doesn't hold a basis that holds the var
			-- isrc[i] cooresponds to the i'th variable in srcChart.coords
			-- then we find the same variable in dstChart.coords
			-- if it isrc there - read from that variable - and write back to self.iter
			-- if it isn't there - skip this iter
--print('assigning to indexes '..table.concat(isrc, ','))
			assert(#isrc == #dstVariance)
			-- looks similar to transformIndexes in Tensor/Ref.lua
			local indexes = dstVariance
			local notfound = false
			for i=1,#indexes do
				-- don't worry about raising or lowering
				local srcChart = self:findChartForSymbol(self.variance[i].symbol)
				local dstChart = self:findChartForSymbol(indexes[i].symbol)
--print('assigning from '..indexes[i].symbol)
--print('assigning into '..self.variance[i].symbol)

				do--if srcIndex ~= dstIndex then
--print('looking for', srcChart.coords[isrc[i]])
--print('...among variables',table.unpack(dstChart.coords))
					local dstIndex = table.find(dstChart.coords, srcChart.coords[isrc[i]])
					-- however 'dst' has already been transformed to the basis of 'src' ...
					-- ... and padded with zeros (TODO don't bother do that?)
					-- so I don't need to reindex the lookup, just skip the zeroes
--print('dstIndex',dstIndex)
					if not dstIndex then
						notfound = true
						break
					end
				end
			end
			if not notfound then
				self[isrc] = dst[isrc]
			end
		end
		--]]
		
		if #value.variance ~= #self.variance then
			error("can't assign tensors of mismatching number of indexes")
		end
		return
	end

	rawset(self, key, value)
end

--[[
hmm, how to lookup charts from tensors
TODO Tensor.chart would be nice
--]]
function Tensor:findChartForSymbol(symbol)
	local manifold = self.manifold
		or (self.chart and self.chart.manifold)
		or Tensor.Manifold.last
	if not manifold then
		return	--error("don't know what Manifold to use associated with this symbol ... have you built a Manifold yet?")
	end
	return manifold:findChartForSymbol(symbol)
end

function Tensor.pruneAdd(lhs,rhs)
	if not Tensor:isa(lhs) or not Tensor:isa(rhs) then return end

	-- reorganize the elements of rhs so the letters match lhs
	rhs = rhs:permute(lhs.variance)

	-- TODO complain if the raise/lower doesn't match up for each index?

	return Tensor{
		indexes = lhs.variance,
		dim = lhs:dim(),
		values = function(...)
			local indexes = {...}
			return lhs:get(indexes) + rhs:get(indexes)
		end,
	}
end

function Tensor.pruneMul(lhs, rhs)
	symmath = symmath or require 'symmath.namespace'()
	local Array = symmath.Array
	local lhsIsArray = Array:isa(lhs)
	local rhsIsArray = Array:isa(rhs)
	local lhsIsTensor = Tensor:isa(lhs)
	local rhsIsTensor = Tensor:isa(rhs)
	local lhsIsScalar = not lhsIsTensor and not lhsIsArray
	local rhsIsScalar = not rhsIsTensor and not rhsIsArray
	assert(lhsIsTensor or rhsIsTensor)
	if lhsIsTensor and rhsIsTensor then
--[[ old way (7.5 seconds on my problem term)
		-- tensor-tensor mul
		local result = Tensor{
			indexes = table():append(lhs.variance):append(rhs.variance),
			dim = table():append(lhs:dim()):append(rhs:dim()),
			values = function(...)
				local indexes = {...}
				assert(#indexes == #lhs.variance + #rhs.variance)
				local lhsIndexes = {table.unpack(indexes, 1, #lhs.variance)}
				local rhsIndexes = {table.unpack(indexes, #lhs.variance+1, #lhs.variance + #rhs.variance)}
				return lhs:get(lhsIndexes) * rhs:get(rhsIndexes)
			end,
		}
		result = result:simplifyTraces()
		return result
--]]
-- [[ less temporary Tensor constructions.  faster? barely.  7.0 instead of 7.5
		-- has: variance, tensor, loc, dim
		local resultIndexes = setmetatable({}, table)
		local resultIndexInfos = setmetatable({}, table)
		local resultDims = setmetatable({}, table)
		local lhsDim = lhs:dim()
		for i,index in ipairs(lhs.variance) do
			resultIndexes:insert(index)
			local dim = lhsDim[i]
			resultDims:insert(dim)
			resultIndexInfos:insert{loc = i, dim = dim, side = 1}
		end
		local rhsDim = rhs:dim()
		for i,index in ipairs(rhs.variance) do
			resultIndexes:insert(index)
			local dim = rhsDim[i]
			resultDims:insert(dim)
			resultIndexInfos:insert{loc = i, dim = dim, side = 2}
		end
--print("before: "..resultIndexes:mapi(tostring):concat' ')
		local sumAcrossPairs = setmetatable({}, table)
		local sumDims = setmetatable({}, table)
		do
			local found
			repeat
				found = false
				for i=1,#resultIndexInfos-1 do
					for j=i+1,#resultIndexInfos do
						if resultIndexes[i].symbol == resultIndexes[j].symbol then
--print("removing indexes", i, j)
--print("with symbols", resultIndexes[i].symbol, resultIndexes[j].symbol)
							
							local infoj = resultIndexInfos:remove(j)	-- remove larger first
							resultIndexes:remove(j)
							resultDims:remove(j)
							
							local infoi = resultIndexInfos:remove(i)
							resultIndexes:remove(i)
							resultDims:remove(i)

							assert(infoi.dim == infoj.dim)	-- instead of error, maybe just don't simplify?
							sumAcrossPairs:insert{infoi, infoj}
							sumDims:insert(infoi.dim)
							found = true
							break
						end
					end
					if found then break end
				end
			until not found
		end
	
		--[=[ TODO are my sums optimal?
		-- since the TensorRef mul is commutative (so long as all the dense Tensor's indexes are commutative...)
		-- am I picking the optimal mul order? 
		-- or can I better sort my mul() applications to minimize the number of exterior products being created?
		if #sumDims > 0 then
			io.stderr:write(
				table.mapi(lhs.variance, tostring):concat(),
				" * ",
				table.mapi(rhs.variance, tostring):concat(),
				" : sum ",
				sumAcrossPairs:mapi(function(p)
					return table.mapi(p, function(pi)
						return tostring((pi.side==1 and lhs or rhs).variance[pi.loc])
					end):concat' '
				end):concat', ',
				'\n')
			io.stderr:flush()
		end
		--]=]

		local numSums = #sumDims
		local iter = {}
--print("after: "..resultIndexes:mapi(tostring):concat' ')
		local dst = {}
		local srca = {}
		local srcb = {}
		local srcs = {srca, srcb}
		local function resultValueForIndex(...)
			for i=1,select('#', ...) do
				dst[i] = select(i, ...)
			end
			
			for i,info in ipairs(resultIndexInfos) do
				srcs[info.side][info.loc] = dst[i]
			end
--print('setting fixed read indexes of lhs '..require'ext.tolua'(srca)..' rhs '..require'ext.tolua'(srcb))
			
			-- now we can assert all the sumAcrossPairs' index locations are nil in srca and srcb

			local result = setmetatable({}, table)
			--assert(numSum == #sumAcrossPairs)
			if #sumAcrossPairs == 0 then
				-- outer product = no summing, just multiply and return
				-- assert that srca and srcb are already full
				return lhs:get(srca) * rhs:get(srcb)
			end
			

			if numSums > 0 then
				for i=1,numSums do
					iter[i] = 1
				end
				
				local iterdone
				while not iterdone do
					-- callback(indexes) here:
					for pairIndex,pair in ipairs(sumAcrossPairs) do
						for _,info in ipairs(pair) do
							srcs[info.side][info.loc] = iter[pairIndex]
						end
					end
					result:insert(lhs:get(srca) * rhs:get(srcb))
					
					for i=numSums,1,-1 do
						iter[i] = iter[i] + 1
						if iter[i] <= sumDims[i] then break end
						iter[i] = 1
						if i == 1 then iterdone = true end
					end
				end
			end

			if #result == 0 then
				error('somehow our sum indexes iterated over no source values\n'
					..'lhs = '..tostring(lhs)..'\n'
					..'rhs = '..tostring(rhs))
			end
			return symmath.tableToAdd(result)
		end

		if #resultIndexes == 0 then -- return a scalar value
			return resultValueForIndex():simplify()
		else
			return Tensor{
				indexes = resultIndexes,
				dim = resultDims,
				values = resultValueForIndex,
			}:simplify()
		end
--]]
	end
	if lhsIsTensor and rhsIsScalar then
		return Tensor{
			indexes = lhs.variance,
			dim = lhs:dim(),
			values = function(...) return lhs:get{...} * rhs end,
		}
	elseif rhsIsTensor and lhsIsScalar then
		return Tensor{
			indexes = rhs.variance,
			dim = rhs:dim(),
			values = function(...) return lhs * rhs:get{...} end,
		}
	end
end

-- I'm one step away from storing the name locally

-- prints the tensor contents as T_abc = <contents>
function Tensor:print(name)
	symmath = symmath or require 'symmath.namespace'()
	local Variable = symmath.Variable
	local Ref = self.Ref
	local TensorIndex = self.Index
	print(self.Ref(Variable(name), table.unpack(self.variance)):eq(self))
end

Tensor.printElemDefaultSeparator = ';'

-- print non-zero elements
function Tensor:printElem(name, write, defaultsep)
	write = write or io.write
	defaultsep = defaultsep or Tensor.printElemDefaultSeparator
	symmath = symmath or require 'symmath.namespace'()
	local Variable = symmath.Variable
	local Constant = symmath.Constant
	local Ref = self.Ref
	local TensorIndex = self.Index
	local sep = ''
	for index,x in self:iter() do
		if not Constant.isValue(x, 0) then
			if sep ~= '' then
				write(sep, '\n')
			end
			write(tostring(Ref(Variable(name),
					table.mapi(self.variance, function(v,i)
						local chart = self:findChartForSymbol(v.symbol)
						v = v:clone()
						v.symbol = chart
							and chart.coords[index[i]]
							and chart.coords[index[i]].name
							or index[i]
							or i
						return v
					end):unpack()
				):eq(x)))
			sep = defaultsep
		end
	end
	
	-- none found:
	if sep == '' then
		write(tostring(Ref(Variable(name), table.unpack(self.variance)):eq(0)))
	else
		write'\n'
	end
end

function Tensor:antisym()
	-- this is from https://www.lua.org/pil/9.3.html
	function permgen(a, n, s)
		if n == 0 then
			coroutine.yield(a, s)
		else
			for i=1,n do
				a[n], a[i] = a[i], a[n]		-- put i-th element as the last one

				-- swap signs when you remove the ith and insert it as the nth
				-- so exchanging the i'th and the n'th means performing n-i moves to move 'i' to 'n'
				-- ... and n-i-1 moves to move 'n' to 'i'
				-- so the sign flips by 2n-2i-1 % 2 == 1 ... so long as i ~= n already
				local news = i==n and s or -s
				permgen(a, n - 1, news)		-- generate all permutations of the other elements

				a[n], a[i] = a[i], a[n]		-- restore i-th element
			end
		end
	end
	function perm(a)
		a = table(a)
		local n = table.maxn(a)
		return coroutine.wrap(function()
			return permgen(a, n, 1)
		end)
	end

	return Tensor{
		indexes = self.variance,
		values = function(...)
			local indexes = {...}
			-- for all permutations of the indexes ...
			-- add/sub depending on whether it is an even or odd permutation
			local sum = 0
			for p, s in perm(indexes) do
				sum = sum + s * self[p]
			end
			return sum()
		end,
	}
end

-- this is used with Derivative when it simplifies two equal Refs
-- TODO call it 'Kroencher Delta symbol' ?
-- and TODO why is the variable associated with :deltaSymbol() named '.deltaVariable'?
--  how instead about just '.deltaSymbol' and '.getDeltaSymbol()', or equiv with '...Variable' ?
function Tensor:deltaSymbol()
	if not Tensor.deltaVariable then
		symmath = symmath or require 'symmath.namespace'()
		local Variable = symmath.Variable
		Tensor.deltaVariable = Variable'δ'
	end
	return Tensor.deltaVariable
end

-- this as well as deltaSymbol are used with Expression.simplifyMetrics
function Tensor:metricSymbol()
	if not Tensor.metricVariable then
		symmath = symmath or require 'symmath.namespace'()
		local Variable = symmath.Variable
		Tensor.metricVariable = Variable'g'
	end
	return Tensor.metricVariable
end

function Tensor:permutationSymbol()
	if not Tensor.permutationVariable then
		symmath = symmath or require 'symmath.namespace'()
		local Variable = symmath.Variable
		Tensor.permutationVariable = Variable'ε'
	end
	return Tensor.permutationVariable
end

function Tensor:getDefaultDenseCache()
	if not Tensor.defaultDenseCache then
		Tensor.defaultDenseCache = Tensor.DenseCache()
	end
	return Tensor.defaultDenseCache
end

return Tensor
