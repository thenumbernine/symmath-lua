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
local curvedSpace = CoordinateSystem{variables=curvedVars, symbols='a-z', metric=g}				-- 4D curved space
local flatSpace = CoordinateSystem{variables=flatVars, symbols='I-N', metric=eta}	-- 4D Minkowski space
Tensor.coords{curvedSpace, flatSpace}
Tensor.transforms{from=curvedSpace, to=flatSpcae, transform=e}

Tensor.transforms would be the new function
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

--]]

local table = require 'ext.table'
local class = require 'ext.class'
local Expression = require 'symmath.Expression'
local Array = require 'symmath.Array'

--[[
general-purpose rank-1 (successive nesting for rank-n) structure
to be used as vectors, vectors of them as matrices, etc ...
--]]
local Tensor = class(Array)
Tensor.name = 'Tensor'

--[[
helper function
accepts tensor string with ^, _, a-z, 1-9 
returns table of the following fields for each index:
	- whether this index is contra- (upper) or co-(lower)-variant
	- whether this index is a variable, or a range of variables
	- whether there is a particular kind of derivative associated with this index?  (i.e. comma, semicolon, projection, etc?)

space separated for multi-char symbols/numbers
	however space-separated means you *must* provide upper/lower prefix before *each* symbol/number
	(TODO fix this)
--]]
local function parseIndexes(indexes)
	local TensorIndex = require 'symmath.tensor.TensorIndex'
	
	local function handleTable(indexes)
		indexes = {table.unpack(indexes)}
		local derivative = nil
		for i=1,#indexes do
			if type(indexes[i]) == 'number' then
				indexes[i] = {
					number = indexes[i],
					derivative = derivative,
				}
			elseif type(indexes[i]) == 'table' and getmetatable(indexes[i]) == TensorIndex then
				indexes[i] = indexes[i]:clone()
			elseif type(indexes[i]) ~= 'string' then
				print("got an index that was not a number or string: "..type(indexes[i]))
			else
				local function removeIfFound(sym)
					local found = false
					while true do
						local symIndex = indexes[i]:find(sym,1,true)
						if symIndex then
							indexes[i] = indexes[i]:sub(1,symIndex-1) .. indexes[i]:sub(symIndex+#sym)
							found = true
						else
							break
						end
					end
					return found
				end
				-- if the expression is upper/lower..comma then switch order so comma is first
				if removeIfFound(',') then derivative = 'partial' end
				if removeIfFound(';') then derivative = 'covariant' end
				--if removeIfFound('|') then derivative = 'projection' end
				local lower = not not removeIfFound('_')
				if removeIfFound('^') then
					--print('removing upper denotation from index table (it is default for tables of indices)')
				end
				-- if it has a '_' prefix then just leave it.  that'll be my denotation passed into TensorRepresentation
				if #indexes[i] == 0 then
					print('got an index without a symbol')
				end
				
				if tonumber(indexes[i]) ~= nil then
					indexes[i] = TensorIndex{
						number = tonumber(indexes[i]),
						lower = lower,
						derivative = derivative,
					}
				else
					indexes[i] = TensorIndex{
						symbol = indexes[i],
						lower = lower,
						derivative = derivative,
					}
				end
			end
		end
		return indexes	
	end

	if type(indexes) == 'string' then
		local indexString = indexes
		if indexString:find(' ') then
			indexes = handleTable(indexString:split(' '))
		else
			local lower = false
			local derivative = nil
			indexes = {}
			for i=1,#indexString do
				local ch = indexString:sub(i,i)
				if ch == '^' then
					lower = false 
				elseif ch == '_' then
					lower = true
				elseif ch == ',' then
					derivative = 'partial'
				elseif ch == ';' then
					derivative = 'covariant'
				--elseif ch == '|' then
				--	derivative = 'projection'
				else
					if tonumber(ch) ~= nil then
						table.insert(indexes, TensorIndex{
							number = tonumber(ch),
							lower = lower,
							derivative = derivative,
						})
					else
						table.insert(indexes, TensorIndex{
							symbol = ch,
							lower = lower,
							derivative = derivative,
						})
					end
				end
			end
		end
	elseif type(indexes) == 'table' then
		indexes = handleTable(indexes)
	else
		error('indexes had unknown type: '..type(indexes))
	end
	
	for i,index in ipairs(indexes) do
		assert(index.number or index.symbol, "index missing number or symbol")
	end
	
	return indexes
end

-- array of TensorCoordBasis objects
Tensor.__coordBasis = nil

function Tensor.coords(newCoords)
	local TensorCoordBasis = require 'symmath.tensor.TensorCoordBasis'
	local oldCoords = Tensor.__coordBasis
	if newCoords ~= nil then
		Tensor.__coordBasis = newCoords
		for i=1,#Tensor.__coordBasis do
			assert(type(Tensor.__coordBasis[i]) == 'table')
			if not Tensor.__coordBasis[i].isa
			or not Tensor.__coordBasis[i]:isa(TensorCoordBasis)
			then
				Tensor.__coordBasis[i] = TensorCoordBasis(Tensor.__coordBasis[i])
			end
		end
	end
	return oldCoords
end

local function findBasisForSymbol(symbol)
	if not Tensor.__coordBasis then return end
	for _,basis in ipairs(Tensor.__coordBasis) do
		if not basis.symbols then
			default = basis
		else
			if basis.symbols:find(symbol) then return basis end
		end
	end
	return default
end

--[[
TODO Tensor construction:
	- (optional) first argument tensor variance
		- string that is parsed: '_ijk', etc
		- table-of-TensorIndex objects (already in processed form that is returned by parseIndexes)
		- aka args.indexes 
	- (optional) n-many dimension numbers of lua numbers or Constants
		- aka args.dim
	- (optional) final argument value generator
		- function that accepts n parameters (for n rank of tensor)
		- table that is n nestings deep (for n rank of tensor)
		- aka args.values
...
how to specify index-only (value-less) tensors?
	- extra flag?  'indexOnly=true' only for vararg ... bad idea
	- if values are not provided then the tensor should be a representation with no actual values - i.e. an index-Tensor
		- this means no more defaulting values to zero


information the constructor needs...
possible combinations:
* * *      	/ contra/covariant + index information (includes variance and dimensions, excludes optional values)
      * *  	\ list of dimension (excludes variance and optional values)
  *       *	/ dense content: expressions as nested tables (includes dimensions, excludes variance)
    *   *  	\ lambdas for content generation (includes values, excludes dimension or variance)

constructors:
	contra/co-variant alone:
		Tensor(string)
		Tensor'^i' = contravariant rank-1
		Tensor'_ij' = covariant rank-2
		Tensor'^i_jk' = mixed rank-3
			default goes to ... contra? co? or neither / separate associated metric?
			associate indexes with metrics?
			functions for converting from/to different basii?

	contra/co-variant + dense values:
		Tensor(string, table)
		Tensor('^i', {1,2,3}) = contravariant rank-3 tensor w/initial values
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
	Tensor(number...) => dense values
	Tensor{dim=table, values=table} => dimension list + lambda callback
	Tensor{dim=table} => dimension list
	Tensor{}

Tensor static members:
	- association of indicies to coordinates

Tensor.coords{
	{t,x,y,z},
	{i,j,k} = {x,y,z},
	{I,J,K} = {whatever flat space vielbein indices you want to use},
}
- coordinate transformation information ...
	i.e. lower txyz to upper txyz basis transforms with g^uv,
		upper txyz to lower txyz transforms with g_uv
		lower txyz to lower TXYZ transforms with e_I^u, etc

Tensor have the following attributes:
	- rank (list of dimensions) <- right now dynamcially calculated via :rank()
	- list of associated basis (contra-/co-/neither)
	- associated indices / index ranges?  g_uv spans txyz vs g_ij spans xyz
--]]
function Tensor:init(...)
	local Constant = require 'symmath.Constant'	
	local TensorIndex = require 'symmath.tensor.TensorIndex'
	
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
		self.variance = args[1].indexes and parseIndexes(args[1].indexes) or {}
		local dim = args[1].dim
		--if dim and args[1].indexes then error("can't specify dim and indexes") end
		if dim then
			assert(type(dim) == 'table')
			dim = range(#dim):map(function(i)
				local di = dim[i]
				if Constant.is(di) then di = di.value end
				assert(type(di) == 'number')
				return di
			end)
			-- construct content from default of zeroes
			local subdim = table(dim)
			local thisdim = subdim:remove(1)
			
			local superArgs = {}
			for i=1,thisdim do
				if #subdim > 0 then
					superArgs[i] = Tensor{dim=subdim}
				else
					superArgs[i] = Constant(0)
				end
			end
			Expression.init(self, table.unpack(superArgs))
		else
			-- construct content from default of zeroes
			local subVariance = table(self.variance)
			local firstVariance = table.remove(subVariance, 1)
			
			local basis = findBasisForSymbol(firstVariance.symbol)
			
			local superArgs = {}
			for i=1,#basis.variables do
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
		or (type(args[1]) == 'table' 
			and type(args[1][1]) == 'table'
			and args[1][1].isa
			and args[1][1]:isa(TensorIndex))
		then
			
			local indexes = table.remove(args, 1)
			
			-- *) parse string into indicies (and what basis they belong to) and contra- vs co- variance
			-- should I make a distinction for multi-letter variables? not allowed for the time being ...
			self.variance = parseIndexes(indexes)

			-- *) complain if there is no Tensor.coords assignment
			-- *) store index information (in this tensor and subtensors ... i.e. this may be {^i, _j, _k}, subtensors would be {_j, _k}, and their subtensors would be {_k}
			-- *) build an empty tensor with rank according to the basis size of the indices

			if #args > 0 then
				-- assert that the sizes are correct
				local subVariance = table(self.variance)
				table.remove(subVariance, 1)
			
				Expression.init(self, table.unpack(args))
				
				-- matches below
				for i=1,#self do
					local x = self[i]
					assert(type(x) == 'table', "tensors can only be constructed with Expressions or tables of Expressions") 
					if not (x.isa and x:isa(Expression)) then
						-- then assume it's meant to be a sub-tensor
						x = Tensor(subVariance, table.unpack(x))
						self[i] = x
					end
				end
		
			else
				-- construct content from default of zeroes
				local subVariance = table(self.variance)
				local firstVariance = table.remove(subVariance, 1)
				local basis = findBasisForSymbol(firstVariance.symbol)

				local superArgs = {}
				for i=1,#basis.variables do
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
		
			-- now that children are stored, construct them as lower-rank objects if the arguments were provided implicitly as metatable-less tables
			-- this way we know all children (a) are Tensors and have a ".rank" field, or (b) are non-Tensor Expressions and are rank-0 
			for i=1,#self do
				local x = self[i]
				assert(type(x) == 'table', "tensors can only be constructed with Expressions or tables of Expressions") 
				if not (x.isa and x:isa(Expression)) then
					-- then assume it's meant to be a sub-tensor
					x = Tensor(table.unpack(x))
					self[i] = x
				end
			end
		end
	end

	if valueCallback then
		local clone = require 'symmath.clone'
		for index,_ in self:iter() do
			if type(valueCallback) == 'function' then
				self[index] = clone(valueCallback(table.unpack(index)))
			elseif Array.is(valueCallback) then
				self[index] = clone(valueCallback[index])
			end
		end
	end
end

function Tensor:clone(...)
	local TensorIndex = require 'symmath.tensor.TensorIndex'
	local copy = Tensor.super.clone(self, ...)
	for i=1,#self.variance do
		copy.variance[i] = self.variance[i]:clone()
	end
	return copy
end

function Tensor.__eq(a,b)
	if not Tensor.super.__eq(a,b) then return false end
--[[
	assert(#a.variance == #b.variance)
	for i=1,#a.variance do
		if a.variance ~= b.variance then return false end
	end
--]]
	return true
end

--[[
produce a trace between dimensions i and j
store the result in dimension i, removing dimension j
--]]
function Tensor:trace(i,j)
	local clone = require 'symmath.clone'

	if i == j then
		error("cannot apply contraction across the same index: "..i)
	end

	local dim = self:dim()
	if dim[i] ~= dim[j] then
		error("tried to apply tensor contraction across indices of differing dimension: "..i.."th and "..j.."th of "..table.concat(dim, ','))
	end
	
	local newdim = clone(dim)
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

if it removes the last dim then a number is returned (rather than a 0-rank tensor, which I don't support)
--]]
function Tensor:contraction(i)
	local clone = require 'symmath.clone'
	
	local dim = self:dim()
	assert(i >= 1 and i <= #dim, "tried to contract dimension "..i.." when we are only rank "..#self.dim)

	-- if there's a valid contraction and we're rank-1 then we're summing across everything
	if #dim == 1 then
		local result
		for i=1,dim[1].value do
			if not result then
				result = self[i]
			else
				result = result + self[i]
			end
		end
		return result
	end

	local newdim = clone(dim)
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
			for index=1,removedDim.value do
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
					if not self:isa(Tensor) then
						return self:simplify()	-- if it's a scalra then return
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
transform it by the provided rank-2 tensor
and store it back where you got it from
--]]
function Tensor:transformIndex(ti, m)
	local dim = self:dim()
	local mdim = m:dim()
	assert(m:rank() == 2, "can only transform an index by a rank-2 metric, got a rank "..m:rank())
	assert(mdim[1] == mdim[2], "can only transform an index by a square metric, got dims "..mdim)
	assert(dim[ti] == mdim[1], "tried to transform tensor of dims "..dim.." with metric of dims "..mdim)
	return Tensor{dim=dim, values=function(...)
		-- current element being transformed
		local is = {...}
		local vxi = is[ti]	-- the current coordinate along the vector being transformed
		
		local result = 0
		for vi=1,mdim[1].value do
			local vis = {table.unpack(is)}
			vis[ti] = vi
			result = result + m:get{vxi, vi} * self:get(vis)
		end
		
		return result
	end}
end



-- static
--[[
replaces the specified coordinate basis metric with the specified metric
returns the TensorBasis object

usage:
	Tensor.metric(m, nil, symbol) 		<- replaces the metric of the basis associated with the symbol, calculates the metric inverse
	Tensor.metric(nil, mInv, symbol)	<- replaces the metric inverse of the basis associated with the symbol, calculates the metric
	Tensor.metric(m, mInv, symbol)		<- replaces both the metric and the metric inverse of the basis associated with the symbol 
	Tensor.metric(nil, nil, symbol) 	<- returns the basis associated with the symbol
--]]
function Tensor.metric(metric, metricInverse, symbol)
	local Matrix = require 'symmath.Matrix'
	local basis = findBasisForSymbol(symbol or {})
	if not basis then error("can't set the metric without first setting the coords") end
	if metric or metricInverse then
		basis.metric = metric or Matrix.inverse(metricInverse)
		basis.metricInverse = metricInverse or Matrix.inverse(metric)
	end
	-- TODO convert matrices to tensors?
	-- this means use distinct symbols
	-- also assigning values= isn't working ...
	local a,b
	if basis.symbols then
		if #basis.symbols < 2 then
			error("found a basis with only one symbol, when you need two to represent the metric tensor: " .. tolua(basis))
		end
		-- TODO seems findBasisForSymbol isn't set up to support space-separated symbol strings ...
		a = basis.symbols:sub(1,1)
		b = basis.symbols:sub(2,2)
	else
		a,b = 'a','b'
	end
	assert(a and b and #a>0 and #b>0)
	if not basis.metric:isa(Tensor) then basis.metric = Tensor{indexes={'_'..a, '_'..b}, values=basis.metric} end
	if not basis.metricInverse:isa(Tensor) then basis.metricInverse = Tensor{indexes={'^'..a, '^'..b}, values=basis.metricInverse} end
	return basis
end

function Tensor:applyRaiseOrLower(i, tensorIndex)
	local t = self:clone()

	-- TODO this matches Tensor:__call
	local srcBasis, dstBasis
	if Tensor.__coordBasis then
		srcBasis = findBasisForSymbol(t.variance[i].symbol)
		dstBasis = findBasisForSymbol(tensorIndex.symbol)
	end

	if tensorIndex.lower ~= t.variance[i].lower then
		-- how do we handle raising indexes of subsets
		local metric = (dstBasis and dstBasis.metric) or (srcBasis and srcBasis.metric)
		local metricInverse = (dstBasis and dstBasis.metricInverse) or (srcBasis and srcBasis.metricInverse)
		
		if not metric then
			error("tried to raise/lower an index without a metric")
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
			error("you can reset the metric tensor via the Tensor.coords() function")
		end
		
		-- TODO generalize transforms, including inter-basis-symbol-sets
	
		local oldVariance = table.map(t.variance, function(v) return v:clone() end)
		if tensorIndex.lower and not t.variance[i].lower then
			t = t:transformIndex(i, metric)
		elseif not tensorIndex.lower and t.variance[i].lower then
			t = t:transformIndex(i, metricInverse)
		else
			error("don't know how to raise/lower these indexes")
		end
		t = require 'symmath.simplify'(t)
		t.variance = oldVariance
		t.variance[i].lower = tensorIndex.lower
	end

	return t
end

function Tensor:__call(indexes)
	local clone = require 'symmath.clone'
	local TensorIndex = require 'symmath.tensor.TensorIndex'

	if type(indexes) == 'table' then
		indexes = {table.unpack(indexes)}
		assert(#indexes == #self.variance)
		for i=1,#indexes do
			if type(indexes[i]) == 'number' then
				indexes[i] = TensorIndex{
					lower = self.variance[i].lower,
					number = indexes[i],
				}
			elseif type(indexes[i]) == 'table' then
				assert(indexes[i].isa and indexes[i]:isa(TensorIndex))
			else
				error("indexes["..i.."] got unknown type "..type(indexes[i]))
			end
		end
	end
	indexes = parseIndexes(indexes)

	-- clone self before returning it
	self = clone(self)
	
	-- now transform all indexes that don't match up
	
	local foundDerivative
	local nonDerivativeIndexes = table()
	for i,index in ipairs(indexes) do
		if index.derivative then
			foundDerivative = true
		else
			nonDerivativeIndexes:insert(i)
		end
	end

	--[[ TODO possibly support for comma derivatives of (non-Tensor) scalar expressions?
	if is scalar then
		if #indexes > 0 then
			error("tried to apply "..#indexes.." indexes to a 0-rank tensor (a scalar): "..tostring(tensor))
		end
		if #nonDerivativeIndexes ~= 0 then
			error("Tensor.rep non-tensor needs as zero non-comma indexes as the tensor's rank.  Found "..#nonDerivativeIndexes.." but needed "..0)
		end
	else...
	--]]
	local rank = Tensor.rank(self)
	if #nonDerivativeIndexes ~= rank then
		error("Tensor() needs as many non-derivative indexes as the tensor's rank.  Found "..#nonDerivativeIndexes.." but needed "..rank)
	end

	-- this operates on indexes
	-- which hasn't been expanded according to commas just yet
	-- so commas must be all at the end
	local function transformIndexes(withDerivatives)
		-- raise all indexes, transform tensors accordingly
		for i=1,#indexes do
			if not indexes[i].derivative == not withDerivatives then

				-- TODO replace all of this, the upper/lower transforms, the inter-coordinate transforms
				-- with one general routine for transforming between basii (in place of transformIndex)

				self = self:applyRaiseOrLower(i, indexes[i])
				
				-- TODO this matches Tensor:applyRaiseOrLower
				local srcBasis, dstBasis
				if Tensor.__coordBasis then
					srcBasis = findBasisForSymbol(self.variance[i].symbol)
					dstBasis = findBasisForSymbol(indexes[i].symbol)
				end				
			
				if srcBasis ~= dstBasis then
					-- only handling exchanges of variables at the moment
					
					local indexMap = {}
					for i=1,#dstBasis.variables do
						indexMap[i] = table.find(srcBasis.variables, dstBasis.variables[i])
					end

					self = Tensor{
						indexes = indexes,
						values = function(...)
							local srcIndexes = {...}
							srcIndexes[i] = indexMap[srcIndexes[i]]
							return self[srcIndexes]
						end,
					}
				end

				self.variance[i].symbol = indexes[i].symbol
				self.variance[i].number = indexes[i].number
			end
		end
	end

	transformIndexes(false)

	if foundDerivative then
		-- indexed starting at the first derivative index
		local basisForCommaIndex = {}
		for i=1,#indexes do
			if indexes[i].derivative then
				basisForCommaIndex[i] = findBasisForSymbol(indexes[i].symbol)
			end
		end
	
		local TensorIndex = require 'symmath.tensor.TensorIndex'
		local newVariance = {}
		-- TODO straighten out the upper/lower vs differentiation order
		for i=1,#indexes do
			newVariance[i] = TensorIndex{
				symbol = indexes[i].symbol,
				lower = indexes[i].lower,
				-- ...and i'm not copying the derivative field
			}
		end
		
		self = Tensor{indexes=newVariance, values=function(...)
			local is = {...}
			-- pick out 
			local base = table()
			local deriv = table()
			for i=1,#is do
				if indexes[i].derivative then
					deriv:insert(basisForCommaIndex[i].variables[is[i]])
				else
					base:insert(is[i])
				end
			end
			local x = self:get(base)
			for i=1,#deriv do
				x = x:diff(deriv[i])
			end
			return x
		end}

		-- raise after differentiating
		-- TODO do this after each diff
		transformIndexes(true)
		
		for i=1,#indexes do
			indexes[i].derivative = false
		end
--print('after differentiation: '..tensor)
	end
	
	-- handle specific number/variable indexes
	do
		local foundNumbers = table.find(indexes, nil, function(index) return index.number end)
		if foundNumbers then
			local newdim = self:dim()
			local srcIndexes = {table.unpack(indexes)}
			local sis = {}
			for i=#newdim,1,-1 do
				if indexes[i].number then
					sis[i] = indexes[i].number
					table.remove(indexes, i)
					table.remove(newdim, i)
				end
			end
			if #newdim == 0 then
				return self:get(sis)
			else
				local dstToSrc = {}
				for i=1,#newdim do
					dstToSrc[i] = assert(table.find(srcIndexes, indexes[i]))
				end
				self = Tensor{
					dim = newdim,
					indexes = self.variance,
					values = function(...)
						local is = {...}
						for i=1,#is do
							sis[dstToSrc[i]] = is[i]
						end
						return self:get(sis)
					end,
				}
			end
		end
	end

	-- for all indexes
	
	-- apply any summations upon construction
	-- if any two indexes match then zero non-diagonal entries in the resulting tensor
	--  (scaling with the delta tensor)

	self = self:simplifyTraces()
	if not self:isa(Tensor) then return self end
	
	for i,index in ipairs(self.variance) do
		assert(index.number or index.symbol, "failed to find index on "..i.." of "..#self.variance)
	end	

	return self
end

-- permute the tensor's elements according to the dest variance
function Tensor:permute(dstVariance)
	-- determine index remapping
	local indexMap = {}
	for i,srcVar in ipairs(self.variance) do
		indexMap[i] = table.find(dstVariance, nil, function(dstVar)
			return srcVar.symbol == dstVar.symbol
		end)
		assert(indexMap[i], "assigning tensor with '"..srcVar.symbol.."' to tensor without that symbol")
	end

	local olddim = self:dim()
	local newdim = {}
	for i=1,#olddim do
		newdim[i] = olddim[indexMap[i]]
	end

	-- perform assignment
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
end
	

-- have to be copied?

-- TODO make this and call identical
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
		local dstVariance = parseIndexes(key)
		
		-- assert no comma derivatives
		for _,dstVar in ipairs(dstVariance) do
			assert(not dstVar.derivative, "can't assign to a partial derivative tensor")
		end

		-- raise/lower self according to the key
		-- also apply any change-of-coordinate-system transform
		-- but don't apply subsets of basis
		local dst = self:clone()
		for i=1,#dstVariance do
			dst = dst:applyRaiseOrLower(i, dstVariance[i])
		end

		-- for all non-number indexes
		-- gather all variables of each of those indexes
		-- iterate across all
		

		-- permute the indexes of the value to match the source
		-- TODO no need to permute it if the index is entirely variables/numbers, such that the assignment is to a single element in the tensor
		local dst = value:permute(dstVariance)

		-- reform self to the original variances
		-- TODO once again for scalar assignment or subset assignment
		dst = dst(self.variance)
		
		-- copy in new values
		for is in self:iter() do
			self[is] = dst[is]
		end
		
		if #value.variance ~= #self.variance then
			error("can't assign tensors of mismatching number of indexes")
		end
		return
	end

	rawset(self, key, value)
end

function Tensor.pruneAdd(lhs,rhs)
	if not Tensor.is(lhs) or not Tensor.is(rhs) then return end

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
	local Array = require 'symmath.Array'
	local table = require 'ext.table'
	local lhsIsArray = Array.is(lhs)
	local rhsIsArray = Array.is(rhs)
	local lhsIsTensor = Tensor.is(lhs)
	local rhsIsTensor = Tensor.is(rhs)
	local lhsIsScalar = not lhsIsTensor and not lhsIsArray
	local rhsIsScalar = not rhsIsTensor and not rhsIsArray
	assert(lhsIsTensor or rhsIsTensor)
	if lhsIsTensor and rhsIsTensor then
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

return Tensor
