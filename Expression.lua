local class = require 'ext.class'
local table = require 'ext.table'

local Expression = class()

Expression.precedence = 1
Expression.name = 'Expression'

function Expression:init(...)
	local ch = {...}
	for i=1,#ch do
		local x = ch[i]
		if type(x) == 'number' then
			local Constant = require 'symmath.Constant'
			self[i] = Constant(x)
		elseif type(x) == 'nil' then
			error("can't set a nil child")
		else
			self[i] = x
		end
	end
end

function Expression:clone()
	local clone = require 'symmath.clone'
	if self then
		local xs = table()
		for i=1,#self do
			xs:insert(clone(self[i]))
		end
		return getmetatable(self)(xs:unpack())
	else
		-- why do I have this condition?
		return getmetatable(self)()
	end
end

--[[
applies the inverse operation to soln
inverse is performed with regards to child at index
returns result
--]]
function Expression:reverse(soln, index)
	error("don't know how to inverse")
end

-- get a flattened tree of all nodes
-- I don't know that I ever use this ...
function Expression:getAllNodes()
	-- add current nodes
	local nodes = table{self}
	-- add child nodes
	if self then
		for _,x in ipairs(self) do
			nodes:append(x:getAllNodes())
		end
	end
	-- done
	return nodes
end

function Expression:findChild(node)
	-- how should I distinguish between find saying "not in our tree" and "it is ourself!"
	if node == self then error("looking for self") end
	for i,x in ipairs(self) do
		-- if it's this node then return its info
		if x == node then return self, i end
		-- check children recursively
		local parent, index = x:findChild(node)
		if parent then return parent, index end
	end
end

function Expression.__concat(a,b)
	return tostring(a) .. tostring(b)
end

function Expression:__tostring()
	local symmath = require 'symmath'
	return symmath.tostring(self)
end

function Expression:tostring(method, ...)
	if not method then
		return tostring(self)
	else
		return require('symmath.tostring.'..method)(self, ...)
	end
end

--[[
compares metatable, children length, and children contents.
child order must match.  if your node type order doesn't matter then use nodeCommutativeEqual

this is used for comparing
for equality and solving, use .eq()
--]]
function Expression.__eq(a,b)
	if getmetatable(a) ~= getmetatable(b) then return false end
	if a == nil ~= b == nil then return false end
	if a and b then
		if #a ~= #b then return false end
		for i=1,#a do
			if a[i] ~= b[i] then return false end
		end
		return true
	end
	error("tried to use generic compare on two objects without child nodes: "..a.." and "..b)
end

-- make sure to require Expression and then require the ops
function Expression.__unm(a) 
	return require 'symmath.op.unm'(a) 
end
function Expression.__add(a,b)
	if type(b) == 'number' then b = require 'symmath.Constant'(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__add(a,b) end
	return require 'symmath.op.add'(a,b) 
end
function Expression.__sub(a,b) 
	if type(b) == 'number' then b = require 'symmath.Constant'(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__sub(a,b) end
	return require 'symmath.op.sub'(a,b) 
end
function Expression.__mul(a,b) 
	if type(b) == 'number' then b = require 'symmath.Constant'(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__mul(a,b) end
	return require 'symmath.op.mul'(a,b) 
end
function Expression.__div(a,b) 
	if type(b) == 'number' then b = require 'symmath.Constant'(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__div(a,b) end
	return require 'symmath.op.div'(a,b) 
end
function Expression.__pow(a,b) 
	if type(b) == 'number' then b = require 'symmath.Constant'(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__pow(a,b) end
	return require 'symmath.op.pow'(a,b) 
end
function Expression.__mod(a,b) 
	if type(b) == 'number' then b = require 'symmath.Constant'(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__mod(a,b) end
	return require 'symmath.op.mod'(a,b) 
end

-- root-level functions that always apply to expressions
Expression.replace = require 'symmath.replace'
Expression.solve = require 'symmath.solve'
Expression.map = require 'symmath.map'
Expression.prune = function(...) return require 'symmath.prune'(...) end
Expression.distributeDivision = function(...) return require 'symmath.distributeDivision'(...) end
Expression.factorDivision = function(...) return require 'symmath.factorDivision'(...) end
Expression.expand = function(...) return require 'symmath.expand'(...) end
Expression.factor = function(...) return require 'symmath.factor'(...) end
Expression.tidy = function(...) return require 'symmath.tidy'(...) end
Expression.simplify = require 'symmath.simplify'
Expression.polyCoeffs = function(...) return require 'symmath.polyCoeffs'(...) end
Expression.eval = function(...) return require 'symmath.eval'(...) end	-- which itself is shorthand for require 'symmath.Derivative'(...)
Expression.compile = function(...) return require 'symmath'.compile(...) end	-- which itself is shorthand for require 'symmath.tostring.Lua').compile(...)
Expression.diff = function(...) return require 'symmath.Derivative'(...) end	-- which itself is shorthand for require 'symmath.Derivative'(...)
Expression.integrate = function(...) return require 'symmath'.Integral(...) end

-- I have to buffer these by a function to prevent require loop
Expression.eq = function(...) return require 'symmath.op.eq'(...) end
Expression.ne = function(...) return require 'symmath.op.ne'(...) end
Expression.gt = function(...) return require 'symmath.op.gt'(...) end
Expression.ge = function(...) return require 'symmath.op.ge'(...) end
Expression.lt = function(...) return require 'symmath.op.lt'(...) end
Expression.le = function(...) return require 'symmath.op.le'(...) end

-- linear system stuff.  do we want these here, or only as a child of Matrix?
Expression.inverse = function(...) return require 'symmath.matrix.inverse'(...) end
Expression.determinant = function(...) return require 'symmath.matrix.determinant'(...) end
Expression.transpose = function(...) return require 'symmath.matrix.transpose'(...) end
-- shorthand ...
Expression.inv = Expression.inverse
Expression.det = Expression.determinant
-- I would do transpose => tr, but tr could be trace too ...

-- ... = list of equations
-- TODO subst on multiplication terms
-- TODO subst automatic reindex of Tensors
-- TODO :expandIndexes() function to split indexes in particular ways (a -> t + k -> t + x + y + z)
function Expression:subst(...)
	local eq = require 'symmath.op.eq'
	local result = self:clone()
	for i=1,select('#', ...) do
		local eqn = select(i, ...)
		assert(eq.is(eqn), "Expression:subst() argument "..i.." is not an equals operator") 
		
		local lhs = eqn:lhs()
		local rhs = eqn:rhs()
	
		-- special case for TensorRef's -- try replacing all index permutations
		local TensorRef = require 'symmath.tensor.TensorRef'
		if lhs:isa(TensorRef) then
			-- TODO
			-- for all permutations of indexes that show up in 'result' ...
			-- ... length the # of indexes to lhs ...
			-- ... reindex both lhs and rhs to that permutation
			-- ... then try to replace 
			result = result:replace(lhs, rhs)
		else
			result = result:replace(lhs, rhs)
		end
	end
	return result
end

-- adding tensor indexing to *all* expressions:
-- once I add function evaluation I'm sure I'll regret this decision
function Expression:__call(...)
	-- calling with nothing?  run a simplify() on it
	-- this is getting ugly ...
	if select('#', ...) == 0 then
		return self:simplify()
	end

--print('__call reindexing')
	-- calling with anything else?  assume index dereference
	local indexes = ...

	local clone = require 'symmath.clone'
	local Tensor = require 'symmath.Tensor'
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
				assert(TensorIndex.is(indexes[i]))
			else
				error("indexes["..i.."] got unknown type "..type(indexes[i]))
			end
		end
	end
	indexes = Tensor.parseIndexes(indexes)
	-- by now 'indexes' should be a table of TensorIndex objects
	-- possibly including comma derivatives
	-- TODO replace comma derivatives with (or make them shorthand for) index-based partial derivative operators

	local TensorRef = require 'symmath.tensor.TensorRef'
	return TensorRef(self, table.unpack(indexes))
end

-- another way tensor is seeping into everything ...
-- __call does Tensor reindexing, now this does reindexing for all other expressions ...
-- fwiw this is only being used for subst tensor equalities, which I should automatically incorporate into subst next ...
function Expression:reindex(args)
	local swaps = table()
	for k,v in pairs(args) do
		-- currently only handles single-char symbols
		-- TODO allow keys to be tables of multi-char symbols
		assert(#k == #v, "reindex key and value length needs to match.  got "..#k.." and "..#v)
		for i=1,#k do
			swaps:insert{src = v:sub(i,i), dst = k:sub(i,i)}
		end
	end
	local Tensor = require 'symmath.Tensor'
	local TensorIndex = require 'symmath.tensor.TensorIndex'
	local function replaceAllSymbols(expr)
		for _,swap in ipairs(swaps) do
			if expr.symbol == swap.src then
				expr.symbol = swap.dst
				break
			end
		end
	end
	return self:map(function(expr)
		if TensorIndex.is(expr) then
			replaceAllSymbols(expr)
		elseif Tensor.is(expr) then
			for _,index in ipairs(expr.variance) do
				replaceAllSymbols(index)
			end
		end
		return expr
	end)
end

return Expression
