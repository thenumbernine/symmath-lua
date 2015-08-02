require 'ext'
local Expression = require 'symmath.Expression'


--[[
general-purpose rank-1 (successive nesting for rank-n) structure
to be used as vectors, vectors of them as matrices, etc ...
--]]
local Tensor = class(Expression)
Tensor.name = 'Tensor'
Tensor.mulNonCommutative = true
Tensor.precedence = 10


--[[
helper function
accepts tensor string with ^, _, a-z, 1-9 
returns table of the following fields for each index:
	- whether this index is contra- (upper) or co-(lower)-variant
	- whether this index is a variable, or a range of variables
	- whether there is a particular kind of derivative associated with this index?  (i.e. comma, semicolon, projection, etc?)
--]]
local function parseIndexes(indexes)
	local TensorIndex = require 'symmath.TensorIndex'
	
	local function handleTable(indexes)
		indexes = {unpack(indexes)}
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
		assert(index.number or index.symbol)
	end
	
	return indexes
end

-- array of TensorCoordBasis objects
Tensor.__coordSrcs = nil

function Tensor.coords(newCoords)
	local TensorCoordBasis = require 'symmath.TensorCoordBasis'
	local oldCoords = Tensor.__coordSrcs
	if newCoords ~= nil then
		Tensor.__coordSrcs = newCoords
		for i=1,#Tensor.__coordSrcs do
			assert(type(Tensor.__coordSrcs[i]) == 'table')
			if not Tensor.__coordSrcs[i].isa
			or not Tensor.__coordSrcs[i]:isa(TensorCoordBasis)
			then
				Tensor.__coordSrcs[i] = TensorCoordBasis(Tensor.__coordSrcs[i])
			end
		end
	end
	return oldCoords
end

local function findBasisForSymbol(symbol)
	for _,basis in ipairs(Tensor.__coordSrcs) do
		if not basis.symbols then
			default = basis
		else
			if basis.symbols:find(symbol) then return basis end
		end
	end
	return default
end

--[[
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

Tensor.coords = {
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
	local TensorIndex = require 'symmath.TensorIndex'
	
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
		if dim and args[1].indexes then
			error("can't specify dim and indexes")
		end
		if dim then
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
			Tensor.super.init(self, unpack(superArgs))
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
			Tensor.super.init(self, unpack(superArgs))
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

			if not Tensor.__coordSrcs then
				error("can't assign tensor by indexes until Tensor.coords has been defined")
			end
			-- *) complain if there is no Tensor.coords assignment
			-- *) store index information (in this tensor and subtensors ... i.e. this may be {^i, _j, _k}, subtensors would be {_j, _k}, and their subtensors would be {_k}
			-- *) build an empty tensor with rank according to the basis size of the indices

			if #args > 0 then
				-- assert that the sizes are correct
				local subVariance = table(self.variance)
				table.remove(subVariance, 1)
			
				Tensor.super.init(self, unpack(args))
				
				-- matches below
				for i=1,#self do
					local x = self[i]
					assert(type(x) == 'table', "tensors can only be constructed with Expressions or tables of Expressions") 
					if not (x.isa and x:isa(Expression)) then
						-- then assume it's meant to be a sub-tensor
						x = Tensor(subVariance, unpack(x))
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
				Tensor.super.init(self, unpack(superArgs))
			end
		--[[
		Tensor({row1}, {row2}, ...)
		--]]
		else
			-- if we get a list of tables then call super init ...	
			Tensor.super.init(self, ...)

			-- default: covariant?
			-- TODO create defaults according to children (from the Tensor.super.init(self, ...) call)
			self.variance = {}
		
			-- now that children are stored, construct them as lower-rank objects if the arguments were provided implicitly as metatable-less tables
			-- this way we know all children (a) are Tensors and have a ".rank" field, or (b) are non-Tensor Expressions and are rank-0 
			for i=1,#self do
				local x = self[i]
				assert(type(x) == 'table', "tensors can only be constructed with Expressions or tables of Expressions") 
				if not (x.isa and x:isa(Expression)) then
					-- then assume it's meant to be a sub-tensor
					x = Tensor(unpack(x))
					self[i] = x
				end
			end
		end
	end

	if valueCallback then
		for index,_ in self:iter() do
			self[index] = valueCallback(unpack(index))
		end
	end
end

function Tensor:clone(...)
	local TensorIndex = require 'symmath.TensorIndex'
	local copy = Tensor.super.clone(self, ...)
	for i=1,#self.variance do
		copy.variance[i] = TensorIndex(self.variance[i])
	end
	return copy
end

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
	return rawget(self, key)
end

Tensor.__newindex = function(self, key, value)
	
	-- I don't think I do much assignment-by-table ...
	--  except for in the Visitor.lookupTable ...
	-- otherwise, looks like it's not allowed in Tensors, where I've overridden it to be the setter
	if type(key) == 'table' then
		self:set(key, value)
		return
	end

	rawset(self, key, value)
end

function Tensor:get(index)
	local x = self
	for i=1,#index do
		x = x[index[i]]
	end
	return x
end

function Tensor:set(index, value)
	local x = self
	for i=1,#index-1 do
		x = x[index[i]]
	end
	x[index[#index]] = value
	-- TODO return the old, for functionality?
	-- or just ignore it, since this is predominantly the implementation of __newindex, which has no return type?
end

-- returns a for loop iterator that cycles across all indexes and values within the tensor
-- usage: for index,value in t:iter() do ... end
-- where #index == t:rank() and contains elements 1 <= index[i] <= t:dim()[i]
function Tensor:iter()
	local dim = self:dim()
	local n = #dim
	
	local index = {}
	for i=1,n do
		index[i] = 1
	end
	
	return coroutine.wrap(function()
		while true do
			coroutine.yield(index, self:get(index))
			for i=1,n do
				index[i] = index[i] + 1
				if index[i] <= dim[i] then break end
				index[i] = 1
				if i == n then return end
			end
		end
	end)
end

-- calculated rank was a great idea, except when the Tensor is dynamically constructed
function Tensor:rank()
	-- note to self: empty Tensor objects means no way of representing empty rank>1 objects 
	-- ... which means special case of type assertion of the determinant being always rank-2 (except for empty matrices)
	-- ... unless I also introduce "shallow" tensors vs "deep" tensors ... "shallow" being represented only by their indices and contra-/co-variance (and "deep" being these)
	if #self == 0 then return 0 end

	-- hmm, how should we determine rank?
	local minRank, maxRank
	for i=1,#self do
		local rank = self[i].rank and self[i]:rank() or 0
		if i == 1 then
			minRank = rank
			maxRank = rank
		else
			minRank = math.min(minRank, rank)
			maxRank = math.max(maxRank, rank)
		end
	end
	if minRank ~= maxRank then
		error("At the moment I don't allow mixed-rank elements in tensors.  I might lighten up on this later.")
	end

	return minRank + 1
end

function Tensor:dim()
	local dim = Tensor()
	dim.rank = 1
	
	-- if we have no children then we can't tell any info of rank
	if #self == 0 then return dim end

	local rank = self:rank()
	if rank == 1 then
		dim[1] = #self
		return dim
	end

	-- get first child's dim
	local subdim_1 = Tensor.dim(self[1])

	assert(#subdim_1 == rank-1, "tensor has subtensor with inequal rank")

	-- make sure they're equal for all children
	for j=2,#self do
		local subdim_j = Tensor.dim(self[j])
		assert(#subdim_j == rank-1, "tensor has subtensor with inequal rank")
		
		for k=1,#subdim_1 do
			if subdim_1[k] ~= subdim_j[k] then
				error("tensor has subtensor with inequal dimensions")
			end
		end
	end

	-- copy subrank into 
	for i=1,rank-1 do
		dim[i+1] = subdim_1[i]
	end
	dim[1] = #self
	return dim
end

-- works like Expression.__eq except checks for Tensor subclass equality rather than strictly metatable equality
function Tensor.__eq(a,b)
	if not (type(a) == 'table' and a.isa and a:isa(Tensor)) then return false end
	if not (type(b) == 'table' and b.isa and b:isa(Tensor)) then return false end
	if a and b then
		if #a ~= #b then return false end
		for i=1,#a do
			if a[i] ~= b[i] then return false end
		end
		return true
	end
end

--[[
produce a trace between dimensions i and j
store the result in dimension i, removing dimension j
--]]
function Tensor:trace(i,j)
	if i == j then
		error("cannot apply contraction across the same index: "..i)
	end

	local dim = self:dim()
	if dim[i] ~= dim[j] then
		error("tried to apply tensor contraction across indices of differing dimension: "..i.."th and "..j.."th of "..table.concat(self.dim, ','))
	end
	
	local newdim = {unpack(dim)}
	-- remove the second index from the new dimension
	local removedDim = table.remove(newdim,j)
	-- keep track of where the first index is in the new dimension
	local newdimI = i
	if j < i then newdimI = newdimI - 1 end

	local result = Tensor(self.variance)
	return Tensor{dim=newdim, values=function(...)
		local indexes = {...}
		-- now when we reference the unremoved dimension

		local srcIndexes = {unpack(indexes)}
		table.insert(srcIndexes, j, indexes[newdimI])
		
		return self:elem(srcIndexes)
	end}
end

--[[
for all permutations of indexes other than i,
take each vector composed of index i
transform it by the provided rank-2 tensor
and store it back where you got it from
--]]
function Tensor:transformIndex(ti, m)
	assert(m:rank() == 2, "can only transform an index by a rank-2 metric, got a rank "..m:rank())
	assert(m:dim()[1] == m:dim()[2], "can only transform an index by a square metric, got dims "..table.concat(m:dim(),','))
	assert(self:dim()[ti] == m:dim()[1], "tried to transform tensor of dims "..table.concat(self:dim(),',').." with metric of dims "..table.concat(m:dim(),','))
	return Tensor{dim=self:dim(), values=function(...)
		-- current element being transformed
		local is = {...}
		local vxi = is[ti]	-- the current coordinate along the vector being transformed
		
		local result = 0
		for vi=1,m:dim()[1] do
			local vis = {unpack(is)}
			vis[ti] = vi
			result = result + m:get{vxi, vi} * self:get(vis)
		end
		
		return result
	end}
end



-- static
-- replaces the specified coordinate basis metric with the specified metric
function Tensor.metric(metric, symbol)
	local Matrix = require 'symmath.matrix'
	local defaultBasis = findBasisForSymbol(symbol or {})
	defaultBasis.metric = metric
	defaultBasis.metricInverse = Matrix.inverse(metric)
end

function Tensor:__call(indexes)
	local clone = require 'symmath.clone'
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

				local srcBasis = findBasisForSymbol(self.variance[i].symbol)
				local dstBasis = findBasisForSymbol(indexes[i].symbol)
				
				if indexes[i].lower ~= self.variance[i].lower then
					-- how do we handle raising indexes of subsets
					local metric = (dstBasis or srcBasis).metric
					local metricInverse = (dstBasis or srcBasis).metricInverse
					
					if not metric then
						error("tried to raise/lower an index without a metric")
					end
					
					if self:dim()[i] ~= metric:dim()[1]
					or self:dim()[i] ~= metricInverse:dim()[1]
					then
						print("can't raise/lower index "..i.." until you set the metric tensor to one with dimension matching the tensor you are attempting to raise/lower")
						print(i.."'th dim")
						print("  your tensor's dimensions: "..table.concat(self:dim(), ','))
						print("  metric dimensions: "..table.concat(metric:dim(),','))
						print("  metric inverse dimensions: "..table.concat(metricInverse:dim(),','))
						error("you can reset the metric tensor via the Tensor.coords() function")
					end
					
					-- TODO generalize transforms, including inter-basis-symbol-sets
				
					local oldVariance = table.map(self.variance, function(v) return v:clone() end)
					if indexes[i].lower and not self.variance[i].lower then
						self = self:transformIndex(i, metric)
					elseif not indexes[i].lower and self.variance[i].lower then
						self = self:transformIndex(i, metricInverse)
					else
						error("don't know how to raise/lower these indexes")
					end
					self = require 'symmath.simplify'(self)
					self.variance = oldVariance
					self.variance[i].lower = indexes[i].lower
				end
			
				if srcBasis ~= dstBasis then
					-- only handling exchanges of variables at the moment
					
					local indexMap = {}
					for i=1,#dstBasis.variables do
						indexMap[i] = table.find(srcBasis.variables, dstBasis.variables[i])
					end

					self = Tensor{indexes=indexes, values=function(...)
-- error - this isn't getting called
						local srcIndexes = {...}
						srcIndexes[i] = indexMap[srcIndexes[i]]
						return self[srcIndexes]
					end}
				end
			
				self.variance[i].symbol = indexes[i].symbol
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
		
		local newdim = table{unpack(self:dim())}
		for i=1,#indexes do
			if indexes[i].derivative then
				newdim[i] = #basisForCommaIndex[i].variables
			end
		end
	
		local TensorIndex = require 'symmath.TensorIndex'
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
	
	-- TODO handle specific number/variable indexes


	-- for all indexes
	
	-- apply any summations upon construction
	-- if any two indexes match then zero non-diagonal entries in the resulting tensor
	--  (scaling with the delta tensor)
	
	local modified
	repeat
		modified = false
		for i=1,#self.variance-1 do
			for j=i+1,#self.variance do
				if self.variance[i] == self.variance[j] then
					self = self:trace(i,j)
					table.remove(self.variance,j)	-- remove one of the two matching indices
					modified = true
					break
				end
			end
			if modified then break end
		end
	until not modified
	
	for i,index in ipairs(self.variance) do
		assert(index.number or index.symbol, "failed to find index on "..i.." of "..#self.variance)
	end	

	return self
end

return Tensor

