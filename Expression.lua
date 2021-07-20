local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local string = require 'ext.string'

local Expression = class()

-- no circular dependencies, so load as you need these:
local symmath
local Array, Constant, Equation, Tensor, TensorIndex, TensorRef, Variable, Wildcard, add, clone, determinant, div, eval, inverse, map, mod, mul, pow, sub, symmath, tableCommutativeEqual, transpose, unm, wedge
local eq, ne, gt, ge, lt, le

Expression.precedence = 1
Expression.name = 'Expression'

function Expression:init(...)
	for i=1,select('#', ...) do
		local x = select(i, ...)
		if type(x) == 'number' then
			Constant = Constant or require 'symmath.Constant'
			self[i] = Constant(x)
		elseif type(x) == 'nil' then
			error("can't initialize an expression with a nil child")
		else
			self[i] = x
		end
	end
end

-- deep copy
function Expression:clone()
	clone = clone or require 'symmath.clone'
	local xs = table()
	for i=1,#self do
		xs:insert(clone(self[i]))
	end
	return getmetatable(self)(xs:unpack())
end

--[[
one thought immutability of objects ...
what about all those test scripts wherein I am modifying Array elements?

If objects are immutable then `A[i][j] = something` should produce an error.

Hmm, it's as if I only need to clone for certain objects ...

Array & children = mutable, all other expressions = immutable.

...and use this function everywhere inside of simplify() functions


So when should cloneIfMutable produce a clone?
- Any time an Expression references it?
- Any time a simplify or a visitor is processed?

When should references be copied?
- Always, any other situation?

When should deep copies be used?
- Never / only if the user wants it?

all our Expression operators...
- init = copy references
- evaluateDerivative = cloneIfMutable
- reverse = cloneIfMutable
- simplify / prune / factor / expand / factorDivision
	cloneIfMutable ... just put it inside the visitor, then you don't have to inside the rule code?
		- maybe before each apply() call, to run cloneIfMutable() on every possible node in the tree?  
		  ... that would still create an unnecessary number
		- within the rules, whenever the tree changes.

--]]
function Expression:cloneIfMutable()
	if self.mutable then return self:clone() end
	return self
end

-- create a shallow copy of this object
function Expression:shallowCopy()
	local t = setmetatable({}, getmetatable(self))
	for k,v in pairs(self) do
		t[k] = v
	end
	return t
end

--[[
applies the inverse operation to soln
inverse is performed with regards to child at index
returns result
--]]
function Expression:reverse(soln, index)
	error("don't know how to inverse "..self.name)
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
	if node == self then return true end --error("looking for self") end
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
	symmath = symmath or require 'symmath'
	return symmath.tostring(self)
end

function Expression:tostring(method, ...)
	if not method then
		return tostring(self)
	else
		return symmath.export[method](self, ...)
	end
end

--[[
compares metatable, children length, and children contents.
child order must match.  if your node class's child order doesn't matter then use tableCommutativeEqual

this is used for comparing
for equality and solving, use .eq()
--]]

-- TODO should wildcards also include matching + 0 in add and * 1 in mul?  Why not, I think so.
function Expression.match(a, b, matches)
	matches = matches or table()
	if b.wildcardMatches then
		if not b:wildcardMatches(a, matches) then return false end
			-- return 'true' to match the end of match()
		return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
	end
	if getmetatable(a) ~= getmetatable(b) then return false end
	
	if not a or not b then return false end
	
	-- check subexpressions
	local n = #a
	if n ~= #b then return false end
	for i=1,n do
		if not a[i]:match(b[i], matches) then return false end
	end

	-- hmm, if we do a a:match() using no Wildcard(1)'s then the first arg will be nil
	-- which will cause a 'if a:match()' to fail
	-- so in the strange case that the user doesn't use a Wildcard(1) then put a 'true' in the first arg
	return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
end

function Expression.__eq(a,b)
	if getmetatable(a) ~= getmetatable(b) then return false end
	
	if not a or not b then return false end
	
	-- check subexpressions
	local n = #a
	if n ~= #b then return false end
	for i=1,n do
		if a[i] ~= b[i] then return false end
	end

	return true
end

-- make sure to require Expression and then require the ops
function Expression.__unm(a) 
	Constant = Constant or require 'symmath.Constant'
	if type(a) == 'number' then a = Constant(a) end
	unm = unm or require 'symmath.op.unm'
	return unm(a) 
end

function Expression.__add(a,b)
	if a == 0 then return b end
	if b == 0 then return a end
	
	Constant = Constant or require 'symmath.Constant'
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	if Constant.isValue(a, 0) then return b end
	if Constant.isValue(b, 0) then return a end
	
	Equation = Equation or require 'symmath.op.Equation'
	if Equation:isa(b) then return b.__add(a,b) end

	add = add or require 'symmath.op.add'
	return add(a,b):flatten()
end

function Expression.__sub(a,b) 
	Constant = Constant or require 'symmath.Constant'
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	
	Equation = Equation or require 'symmath.op.Equation'
	if Equation:isa(b) then return b.__sub(a,b) end
	
	if Constant.isValue(a, 0) then return -b end
	if Constant.isValue(b, 0) then return a end

	sub = sub or require 'symmath.op.sub'
	return sub(a,b) 
end

function Expression.__mul(a,b)
	Constant = Constant or require 'symmath.Constant'
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	
	Equation = Equation or require 'symmath.op.Equation'
	if Equation:isa(b) then return b.__mul(a,b) end

--[[
	-- only simplify c * 0 = 0 for constants
	-- because if we have an Array or Equation then we want it to distribute to all elements
	if Constant:isa(a)
	and Constant:isa(b)
	and (a.value == 0 or b.value == 0)
	then
		return Constant(0)
	end
--]]
--[[ test for array or equation, otherise simplify to zero
-- don't do this for inf ... instead 0 * inf = indeterminate form
	Array = Array or require 'symmath.Array'
	if Constant.isValue(a, 0) and not Array:isa(b) and not Equation:isa(b) then return a end
	if Constant.isValue(b, 0) and not Array:isa(a) and not Equation:isa(a) then return b end
--]]
	
	if Constant.isValue(a, 1) then return b end
	if Constant.isValue(b, 1) then return a end

	mul = mul or require 'symmath.op.mul'
	return mul(a,b):flatten()
end

function Expression.__div(a,b) 
	Constant = Constant or require 'symmath.Constant'
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	
	Equation = Equation or require 'symmath.op.Equation'
	if Equation:isa(b) then return b.__div(a,b) end
	
	if Constant:isa(b) then
		if b.value == 0 then 
			symmath = symmath or require 'symmath'
			return symmath.invalid
		end
		if b.value == 1 then return a end
	end
	if Constant:isa(a) and a.value == 0 then return Constant(0) end

	div = div or require 'symmath.op.div'
	return div(a,b) 
end

function Expression.__pow(a,b) 
	Constant = Constant or require 'symmath.Constant'
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	
	Equation = Equation or require 'symmath.op.Equation'
	if Equation:isa(b) then return b.__pow(a,b) end
	
	if Constant:isa(a) and a.value == 0 then 
		if Constant:isa(b) then
			if b.value > 0 then return Constant(0) end
			if b.value == 0 then 
				symmath = symmath or require 'symmath'
				return symmath.invalid 
			end
			if b.value < 0 then 
				symmath = symmath or require 'symmath'
				return symmath.inf
			end
		end
	end
	if Constant:isa(b) and b.value == 1 then return a end

	pow = pow or require 'symmath.op.pow'
	return pow(a,b) 
end

function Expression.__mod(a,b) 
	Constant = Constant or require 'symmath.Constant'
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	
	Equation = Equation or require 'symmath.op.Equation'
	if Equation:isa(b) then return b.__mod(a,b) end

	mod = mod or require 'symmath.op.mod'
	return mod(a,b) 
end

function Expression:flatten()
	for i=1,#self do
		self[i]:flatten()
	end
	return self
end

-- root-level functions that always apply to expressions

Expression.hasChild = require 'symmath.hasChild'
Expression.replace = require 'symmath.replace'
Expression.solve = require 'symmath.solve'
Expression.map = require 'symmath.map'

Expression.prune = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.prune(...) 
end

Expression.distributeDivision = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.distributeDivision(...) 
end

Expression.factorDivision = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.factorDivision(...) 
end

Expression.expand = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.expand(...) 
end

Expression.factor = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.factor(...) 
end

Expression.tidy = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.tidy(...) 
end

Expression.simplify = require 'symmath.simplify'

Expression.polyCoeffs = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.polyCoeffs(...) 
end

Expression.polydiv = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.polydiv(...) 
end

-- i'm using this more often than I thought I would, so I'll put it in the Expression class 
Expression.polydivr = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.polydiv.polydivr(...) 
end

Expression.eval = function(...) 
	eval = eval or require 'symmath.eval'
	return eval(...) 
end
Expression.compile = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.compile(...) 
end

function Expression:lim(...)
	symmath = symmath or require 'symmath'
	return symmath.Limit(self, ...)
end

function Expression:diff(...) 
--[=[
	local Constant = require 'symmath.Constant'
	
	-- TODO double diff() as differential when no variables are used?
	-- or should that be a separate operator?

	-- d/dx c = 0
	if Constant:isa(self) then
		return Constant(0)
	end

	-- d/dx (x) = 1
	local vars = table{...}
	for i,var in ipairs(vars) do
		if var == self then
			vars:remove(i)
			if #vars == 0 then
				return Constant(1)
			else
				return Constant(1):diff(vars:unpack())
			end
		end
	end
--]=]
	symmath = symmath or require 'symmath'
	return symmath.Derivative(self, ...) 
end

function Expression:totalDiff(...)
	symmath = symmath or require 'symmath'
	return symmath.TotalDerivative(self, ...) 
end

Expression.integrate = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.Integral(...) 
end

Expression.taylor = function(...) 
	symmath = symmath or require 'symmath'
	return symmath.taylor(...) 
end

function Expression.wedge(a,b) 
	if type(b) == 'number' then 
		Constant = Constant or require 'symmath.Constant'
		b = Constant(b) 
	end
	
	Equation = Equation or require 'symmath.op.Equation'
	if Equation:isa(b) then return b.wedge(a,b) end
	
	wedge = wedge or require 'symmath.tensor.wedge'
	return wedge(a,b)
end
Expression.dual = function(...) return require 'symmath'.dual(...) end

-- I have to buffer these by a function to prevent require loop
Expression.eq = function(...) 
	eq = eq or require 'symmath.op.eq'
	return eq(...) 
end
Expression.ne = function(...) 
	ne = ne or require 'symmath.op.ne'
	return ne(...) 
end
Expression.gt = function(...) 
	gt = gt or require 'symmath.op.gt'
	return gt(...) 
end
Expression.ge = function(...) 
	ge = ge or require 'symmath.op.ge'
	return ge(...) 
end
Expression.lt = function(...) 
	lt = lt or require 'symmath.op.lt'
	return lt(...) 
end
Expression.le = function(...) 
	le = le or require 'symmath.op.le'
	return le(...) 
end
Expression.approx = function(...)
	symmath = symmath or require 'symmath'
	return symmath.op.approx(...)
end

-- linear system stuff.  do we want these here, or only as a child of Matrix?
Expression.inverse = function(...) 
	inverse = inverse or require 'symmath.matrix.inverse'
	return inverse(...) 
end
Expression.determinant = function(...) 
	determinant = determinant or require 'symmath.matrix.determinant'
	return determinant(...) 
end
Expression.transpose = function(...) 
	transpose = transpose or require 'symmath.matrix.transpose'
	return transpose(...) 
end
-- shorthand ...
Expression.inv = Expression.inverse
Expression.det = Expression.determinant
-- I would do transpose => tr, but tr could be trace too ...

-- ... = list of equations
-- TODO subst on multiplication terms
-- TODO subst automatic reindex of Tensors
-- TODO :expandIndexes() function to split indexes in particular ways (a -> t + k -> t + x + y + z)
function Expression:subst(...)
	eq = eq or require 'symmath.op.eq'
	local result = self:clone()
	for i=1,select('#', ...) do
		local eqn = select(i, ...)
		assert(eq:isa(eqn), "Expression:subst() argument "..i.." is not an equals operator") 
		result = result:replace(eqn:lhs(), eqn:rhs())
	end
	return result
end

--[[
this is like subst but pattern-matches indexes
--]]
function Expression:substIndex(...)
	eq = eq or require 'symmath.op.eq'
	local result = self:clone()
	for i=1,select('#', ...) do
		local eqn = select(i, ...)
		assert(eq:isa(eqn), "Expression:subst() argument "..i.." is not an equals operator") 
		result = result:replaceIndex(eqn:lhs(), eqn:rhs())
	end
	return result
end

-- return the # of nodes in this tree, including this node
function Expression:countNodes()
	local count = 1
	for i,x in ipairs(self) do
		if x.countNodes then count = count + x:countNodes() end
	end
	return count
end

--[[
this is like replace()
except for TensorRefs it pattern matches indexes
args =
	symbols = list of symbols to pick from when we need a new symbol.  default is Tensor.defaultSymbols.
--]]
--[[ TODO pattern matching of trees ...
-- use these with Integral, and use these with replaceIndex(), to make both pieces of code look muuuuch cleaner
local i,j = x:matches( TensorRef(v, Wildcard(1)):diff(TensorRef(v, Wildcard(2))) ) 		-- v'^i':diff(v'^j') = delta^i_j
if i and j then
	return TensorRef(delta, i, j:lower())
end
local i, j = x:matches( TensorRef(v, Wildcard(1)):diff(Wildcard(2)) ) 					-- v'^i':diff(x) = 0
if i and j then
	return 0
end
local i,j,k = x:matches( TensorRef(g, Wildcard(1), Wildcard(2)):diff(Wildcard(3)) )		-- g'_ij':diff(x) = 0
if i and j and k then
	return 0
end

-- or also add reserve keywords of indexes that match to wildcards: '$#':

local i,j = x:matches( v' ^$1':diff(v' _$2') )
if i and j then return TensorRef(v, i, j) end

local i,j = x:matches( v' ^$1':diff(Wildcard(2)) )
if i and j then return 0 end

local i,j,k = x:matches( g' _$1 _$2':diff( Wildcard(3) ) )
if i and j and k then return 0 end
--]]
function Expression:replaceIndex(find, repl, cond, args)
	clone = clone or require 'symmath.clone'
	repl = clone(repl)	-- in case it's a number ...

	TensorRef = TensorRef or require 'symmath.tensor.TensorRef'
	
	-- TODO or pick default symbols from specifying them somewhere ... I guess Tensor.defaultSymbols for the time being 
	Tensor = Tensor or require 'symmath.Tensor'
	local defaultSymbols = args and args.symbols or Tensor.defaultSymbols

	local selfFixed, selfSum, selfExtra = self:getIndexesUsed()
	local findFixed, findSum, findExtra = find:getIndexesUsed()
	local replFixed, replSum, replExtra = repl:getIndexesUsed()

--printbr('selfFixed: '..require 'ext.tolua'(selfFixed))
--printbr('selfSum: '..require 'ext.tolua'(selfSum))
--printbr('selfExtra: '..require 'ext.tolua'(selfExtra))
--printbr('findFixed: '..require 'ext.tolua'(findFixed))
--printbr('findSum: '..require 'ext.tolua'(findSum))
--printbr('findExtra: '..require 'ext.tolua'(findExtra))
--printbr('replFixed: '..require 'ext.tolua'(replFixed))
--printbr('replSum: '..require 'ext.tolua'(replSum))
--printbr('replExtra: '..require 'ext.tolua'(replExtra))

	local selfAll = table():append(selfFixed, selfSum, selfExtra)
	local findAll = table():append(findFixed, findSum, findExtra)
	local replAll = table():append(replFixed, replSum, replExtra)

	-- get a list of unused symbols
	-- TODO only remove the summed indexes that aren't being replaced
	-- but that would mean moving the pick-new-sum-symbol code down into the replace-expression code
	local unusedSymbols = table(defaultSymbols)
	for _,s in ipairs(selfAll) do
		unusedSymbols:removeObject(s.symbol)
	end

	-- TODO, (a * b'^i'):replaceIndex(a, c'^i' * c'_i')) produces c'^i' * c'_i' * b'^i', not c'^j' * c'_j' * b'^i'
	-- if repl contains a sum index which is already present in the expression then it won't reindex

	-- for Gamma^i_jk = gamma^im Gamma_mjk
	-- findFixed+findSum = ijk
	-- replFixed+replSum = ijkm
	-- replSum = m

	-- TODO
	-- so if there are sum symbols in 'self' then
	-- make sure there are equivalent sum symbols in 'find'
	-- and then create a mapping between them
	-- and do not pick new symbols to replace them with

	-- TODO instead of TensorRef.is,, how about searching for 
	--if TensorRef:isa(find) then
	--if not require 'symmath.Variable':isa(find) then
	--if true then
	if not (#selfAll > 0 and #findAll > 0) then
--printbr'only replacing'
		return self:replace(find, repl, cond)
	end
--printbr'reindexing and replacing'

	TensorIndex = TensorIndex or require 'symmath.tensor.TensorIndex'
	Wildcard = Wildcard or require 'symmath.Wildcard'

	-- create our :match() object by replacing all TensorIndex's with Wildcard's
	-- only replace wildcards for the indexes shared in common between 'find' and 'replace'
	local nextWildcardIndex = 1
	local wildcardIndexToTensorIndex = table()
	local tensorIndexToWildcardIndex = {}
	local findWithWildcards = find:map(function(x)
		if TensorIndex:isa(x)
-- [[ only match wildcards indexes shared between find and replace?  maybe?
-- but what about when we want to replace a TensorRef with a non-TensorRef?
-- TODO think about this ... when should a'_i' => b mean the i is fixed, and when should it mean the i is extra?
		and (
			replFixed:find(nil, function(i) return i.symbol == x.symbol end)
			or replExtra:find(nil, function(i) return i.symbol == x.symbol end)
			or findSum:find(nil, function(i) return i.symbol == x.symbol end)
		)
--]]		
		then
			-- return a tensor index with a wildcard
			local wildcardIndex = tensorIndexToWildcardIndex[x.symbol..' '..tostring(not not x.lower)]
			if wildcardIndex then
				return Wildcard{index = assert(wildcardIndex)}
			else
				local w = Wildcard{index = assert(nextWildcardIndex)}
				tensorIndexToWildcardIndex[x.symbol..' '..tostring(not not x.lower)] = nextWildcardIndex
				wildcardIndexToTensorIndex[nextWildcardIndex] = x:clone()
				nextWildcardIndex = nextWildcardIndex + 1
				return w
			end
		end
	end)
--printbr('looking for matches against ', find)
--printbr('...with wildcards replaced, looking for ', findWithWildcards)

	return self:map(function(x)

		local results = table{x:match(findWithWildcards)}
		if results[1] ~= false then
--printbr('found', x)
			
			-- if there were no wildcards then we would've just got back a 'true'
			-- in that case, no need to replace anything?
			-- unless there are any sum indexes in the repl.
			-- in that case, just nil the results[1] so it doesn't mess things up later.
			if results[1] == true then results[1] = nil end
			for wildcardIndex,xIndex in ipairs(results) do
--printbr('match', wildcardIndex, 'is', xIndex)			
				local selfIndex = wildcardIndexToTensorIndex[wildcardIndex]
				if not (xIndex.lower == selfIndex.lower and xIndex.derivative == selfIndex.derivative) then
--printbr("lower or derivative doesn't match original -- failing")
					-- index variance and symbol don't match ... don't replace this one
					return nil
				end
			end

			-- make sure the matching symbols in 'find' are also matching in 'x'
			-- if wildcardIndexToTensorIndex[1] symbol matches wildcardIndexToTensorIndex[2] symbol
			-- then results[1].symbol should match results[2].symbol
			for i=1,#wildcardIndexToTensorIndex-1 do
				for j=i+1,#wildcardIndexToTensorIndex do
					if wildcardIndexToTensorIndex[i].symbol == wildcardIndexToTensorIndex[j].symbol then
						if results[i].symbol ~= results[j].symbol then 
--printbr("find wildcards "..i.." and "..j.." match, but results don't")
							return false 
						end
					end
				end
			end

			-- repl except remap the indexes to match
			local from = ' '..wildcardIndexToTensorIndex:mapi(function(i) return i.symbol end):concat' '
			local to = ' '..results:mapi(function(i) return i.symbol end):concat' '
			
			-- also, reindex the replSum indexes into unused symbols
			-- but don't use 
			for i=1,#replSum do
				from = from .. ' ' .. replSum[i].symbol
				to = to .. ' ' .. assert(unusedSymbols[i], "ran out of symbols")
			end

			local replReindexed = repl:reindex{[from] = to}
--printbr("replacing with (before reindexing) ", repl)
--printbr("reindexing from", from, "to", to)	
--printbr("replacing with (after reindexing) ", replReindexed)
			return replReindexed
		end
	end)
end

-- if we find a space then treat it as space-separated multi-char indexes
local function interpretSymbols(s)
	if type(s) == 'number' then return {s} end
	assert(type(s) == 'string', "expected a string, found "..type(s))
	if s:find' ' then
		return string.split(string.trim(s), ' ')
	else
		return string.split(s)
	end
end

--[[
This will try to pick consistent indexes for matching terms so that subsequent operations can simplify easier
ex: K^a_a + K^b_b should produce K^a_a + K^a_a, which will simplify to 2 K^a_a
This should also pay attention to which indexes are sum (repeated) and which are fixed (single)
TODO use case
K^a_a + K^b_b => K^a_a + K^a_a => 2 K^a_a
a^ij (b_jk + c_jk) shouldn't change ...
a_ijk b^jk + a_ilm b^lm => a_ijk b^jk + a_ijk b^jk => 2 a_jik b^jk

args =
	symbols = list of symbols to pick from when we need a new symbol.  default is Tensor.defaultSymbols.
	fixed = which symbols to not consider summation symbols
	checkFixed = ...
--]]
function Expression:tidyIndexes(args)
	-- process each part of an equation independently
	symmath = symmath or require 'symmath'
	
	-- TODO or pick default symbols from specifying them somewhere ... I guess Tensor.defaultSymbols for the time being 
	Tensor = Tensor or require 'symmath.Tensor'
	local defaultSymbols = Tensor.defaultSymbols

	if symmath.Array:isa(self) 
	or symmath.op.Equation:isa(self)
	then
		local cl = self:clone()
		for i=1,#cl do
			cl[i] = cl[i]:tidyIndexes(args)
		end
		return cl
	end

	local extraFixed = args and args.fixed and interpretSymbols(args.fixed) or nil

	local expr = self
	--expr = expr()	-- hmm, simplify fails one of our tests
	expr = expr:factorDivision()	-- hmm, so does factorDivision()

	local add = symmath.op.add
	local mul = symmath.op.mul
	local TensorRef = symmath.TensorRef

	tableCommutativeEqual = tableCommutativeEqual or require 'symmath.tableCommutativeEqual'
	
	local function tidyTerm(term, checkFixed)
		local fixed, summed = term:getIndexesUsed()
--print('term fixed', require 'ext.tolua'(fixed), '<br>')
--print('term summed', require 'ext.tolua'(summed), '<br>')
		fixed = fixed:mapi(function(x) return x.symbol end)
		summed = summed:mapi(function(x) return x.symbol end)
		
--print('term fixed', require 'ext.tolua'(fixed), '<br>')
--print('term summed', require 'ext.tolua'(summed), '<br>')
		if checkFixed then
			if not tableCommutativeEqual(fixed, checkFixed) then
				error("couldn't tidyIndexes() - two terms had differing fixed indexes")
			end
		end
		
		local allSymbols = table(defaultSymbols)
		for _,s in ipairs(fixed) do
			allSymbols:removeObject(s)
		end
		if extraFixed then
			for _,s in ipairs(extraFixed) do
				allSymbols:removeObject(s)
			end
		end
		
		local indexMap = {}
		for i,s in ipairs(summed) do
			indexMap[' '..s] = ' '..allSymbols[i]
		end
--print('remapping', require 'ext.tolua'(indexMap), '<br>')		
		term = term:reindex(indexMap)

		return term, fixed
	end

	-- if expr is an add then assert all its children have the same fixed indexes
	if add:isa(expr) then
--print('found add<br>')	
		expr[1] = tidyTerm(expr[1])

		for i=2,#expr do
			expr[i] = tidyTerm(expr[i], args and args.checkFixed)
		end
	elseif mul:isa(expr) 
	or TensorRef:isa(expr)
	then
		expr = tidyTerm(expr)
	else
--print('found '..expr.name..'<br>')	
	end
	-- if expr is a mul then its fixed are its fixed.  nothing more to it.
	-- if expr is a function then it should only have sum indexes.
	return expr
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

	clone = clone or require 'symmath.clone'
	TensorIndex = TensorIndex or require 'symmath.tensor.TensorIndex'

-- TODO hmm, why do I have this here?  self.variance is specific to Tensor, but not tested for isa Tensor
-- so this breaks if you have something like x=var'x' x{'_i', '_j'}
-- while x=var'x' x'_ij' and x' _i _j' works fine
	if type(indexes) == 'table' then
		indexes = {table.unpack(indexes)}
		assert(#indexes == #self.variance)
		for i=1,#indexes do
			if type(indexes[i]) == 'number' then
				indexes[i] = TensorIndex{
					lower = self.variance[i].lower,
					symbol = indexes[i],
				}
			elseif type(indexes[i]) == 'table' then
				assert(TensorIndex:isa(indexes[i]))
			else
				error("indexes["..i.."] got unknown type "..type(indexes[i]))
			end
		end
	end
	indexes = TensorIndex.parseIndexes(indexes)
	-- by now 'indexes' should be a table of TensorIndex objects
	-- possibly including comma derivatives
	-- TODO replace comma derivatives with (or make them shorthand for) index-based partial derivative operators
	-- TODO allow for '_,k' incomplete tensor dereferencing *only if* it is comma-derivatives-only
	--  in which case, just append it to the rest of the tensor

	TensorRef = TensorRef or require 'symmath.tensor.TensorRef'
	return TensorRef(self, table.unpack(indexes))
end

--[[
another way tensor is seeping into everything ...
__call does Tensor reindexing, now this does reindexing for all other expressions ...
fwiw this is only being used for subst tensor equalities, which I should automatically incorporate into subst next ...

action is a dirty hack for using this in conjunction with the metric tensor
action can be 'raise' or 'lower'

just like with tensor indexes, insert a space in the beginning to denote that you are using multi-char symbols

args = 
	[to] = from
--]]
function Expression:reindex(args, action)
	local swaps = table()
	for k,v in pairs(args) do
		local tk = interpretSymbols(k)
		local tv = interpretSymbols(v)
		
		if #tk ~= #tv then
			local tolua = require 'ext.tolua'
			error("reindex key and value length needs to match.  got "..tolua(tk).." with "..#tk.." entries vs "..tolua(tv).." with "..#tv.." entries")
		end
		for i=1,#tk do
			swaps:insert{src = {symbol=tk[i]}, dst = {symbol=tv[i]}}
		end
	end
	Tensor = Tensor or require 'symmath.Tensor'
	TensorIndex = TensorIndex or require 'symmath.tensor.TensorIndex'
	local function replaceAllSymbols(expr)
		for _,swap in ipairs(swaps) do
			if expr.symbol == swap.src.symbol then
				expr.symbol = swap.dst.symbol
				if action then
					expr.lower = action == 'lower'
				end
				break
			end
		end
	end
	return self:map(function(expr)
		if TensorIndex:isa(expr) then
			replaceAllSymbols(expr)
		elseif Tensor:isa(expr) then
			for _,index in ipairs(expr.variance) do
				replaceAllSymbols(index)
			end
		end
		return expr
	end)
end


--[[
here's another tensor-specific function that I want to apply to both Tensor and Variable
so I'm putting here ...

this takes the combined comma derivative references and splits off the comma parts into separate references
it is very helpful for replacing tensors
--]]
function Expression:splitOffDerivIndexes()
	TensorRef = TensorRef or require 'symmath.tensor.TensorRef'
	return self:map(function(x)
		if TensorRef:isa(x) then
			local derivIndex = table.sub(x, 2):find(nil, function(ref)
				return ref.derivative
			end) 
			if derivIndex and derivIndex > 1 then
				return TensorRef(
					TensorRef(x[1], table.unpack(x, 2, derivIndex)),
					table.unpack(x, derivIndex+1)
				)
			end
		end
	end)
end

--[[
takes all instances of var'_ijk...' 
and sorts the indexes in 'indexes'
so that all g_ji's turn into g_ij's
and simplification can work better

another thing symmetrizing can do ...
g^kl (d_klj + d_jlk - d_ljk)  symmetrize g {1,2}
... not only sort g^kl
but also sort all indexes in all multiplied expressions which use 'k' or 'l'
so this would become
g^kl (d_klj + d_jkl - d_kjl)
then another symmetrize d {2,3} gives us
g^kl (d_kjl + d_jkl - d_kjl)
g^kl d_jkl

swaps the variance as well, not just the symbol ... and the derivative too ...
... (which means the danger of derivatives being moved out of the rhs places ... test for that)
but if you don't swap variance then  symmetrizing a symbol with mixed variance will introduce mistakes as well
TODO support for covariant derivative
also TODO a script for automatically expanding the upper/lowers and determining if the swapped indexes do in fact match
--]]
function Expression:symmetrizeIndexes(var, indexes, override)
--print('symmetrizing '..var.name..' indexes '..require'ext.tolua'(indexes))
	return self:map(function(x)
		TensorRef = TensorRef or require 'symmath.tensor.TensorRef'
		if TensorRef:isa(x) 
		and x[1] == var
		and #x >= table.sup(indexes)+1	-- if the indexes refer to derivatives then make sure they're there
		then
--print('found matching var: '..x)			
			local indexObjs = table.mapi(indexes, function(i)
				return x[i+1]:clone()
			end)
--print('associated indexes: '..table.mapi(indexObjs, tostring):concat' ')
			assert(#indexObjs == #indexes)
			indexObjs:sort(function(a,b) 
				if a.symbol ~= b.symbol then
					return tostring(a.symbol) < tostring(b.symbol) 
				end
				return tostring(a.lower) < tostring(b.lower)
			end)
--print('indexes, sorted: '..table.mapi(indexObjs, tostring):concat' ')
		
			if not override then
				-- don't allow swaps of derivatives with non-derivatives
				local derivative = indexObjs[1].derivative
				for i=2,#indexObjs do
					if indexObjs[i].derivative ~= derivative then
						error("found first derivative="..tostring(derivative).." next derivative="..tostring(indexObjs[i].derivative))
					end
				end
				-- if swapping derivatives, don't swap uppers (TODO unless it's a covariant derivative)
				if derivative then
					for i,s in ipairs(indexObjs) do
						if not s.lower then
							error("can't exchange derivative indexes")
						end
					end		
				end
			end

			x = x:clone()
			for i,s in ipairs(indexObjs) do
--print('setting '..x[1].name..' index '..(indexes[i]+1)..' to '..s)				
				x[indexes[i]+1].symbol = s.symbol
				x[indexes[i]+1].lower = s.lower
			end
--print('resulting obj: '..x)
			return x
		end
		
		-- if there's a var^ijk... anywhere in the mul
		-- then look for matching indexes in any other TensorRef's in the mul
		mul = mul or require 'symmath.op.mul'
		if mul:isa(x) then
			local found
--print('checking mul: '..x)
			
			-- rather than only use the first set of symmetrized indexes, how about we re-sort other terms for all symmetrized indexes?
			-- i.e. g_ab a^bac => g_(ab) => g_ab a^abc
			-- but  g_ab a^bac g_ef b^feg => g_(ab) .... will only symmetrize the first and not the second (because we are only sorting one per term) 
			for j,y in ipairs(x) do
--print('checking mul term #'..j..': '..y)	
				if TensorRef:isa(y)
				and y[1] == var
				and #y >= table.sup(indexes)+1
				then
					if not found then
						x = x:clone()
						found = true
					end
--print('found matching var: '..y)
					local srcIndexObjs = table.mapi(indexes, function(i)
						return y[i+1]:clone()
					end)
					assert(#srcIndexObjs == #indexes)
--print('associated indexes: '..table.mapi(srcIndexObjs, tostring):concat' ')
					srcIndexObjs:sort(function(a,b) 
						if a.symbol ~= b.symbol then
							return tostring(a.symbol) < tostring(b.symbol) 
						end
						return tostring(a.lower) < tostring(b.lower)
					end)
--print('associated indexes: '..table.mapi(srcIndexObjs, tostring):concat' ')
					
					if not override then
						-- don't allow swaps of derivatives with non-derivatives
						local derivative = srcIndexObjs[1].derivative
						for i=2,#srcIndexObjs do
							if srcIndexObjs[i].derivative ~= derivative then
								error("found first derivative="..tostring(derivative).." next derivative="..tostring(srcIndexObjs[i].derivative))
							end
						end
						-- if swapping derivatives, don't swap uppers (TODO unless it's a covariant derivative)
						if derivative then
							for i,s in ipairs(srcIndexObjs) do
								if not s.lower then
									error("can't exchange derivative indexes")
								end
							end		
						end
					end

					for i,s in ipairs(srcIndexObjs) do
--print('setting '..x[1].name..' index '..(indexes[i]+1)..' to '..s)				
						y[indexes[i]+1].symbol = s.symbol
						y[indexes[i]+1].lower = s.lower
					end
--print('resulting obj: '..y)
					
					-- if we found a matching tensor in a mul - and we sorted it - then next we need to sort all associated indexes in other tensors in the mul

--print('checking mul for matching indexes in other terms...')
					for k=1,#x do
						if k ~= j then -- don't re-sort your own symbols, or else G^d_dc : symmetrize(G, {2,3}) will sort index 1 as well and produce G_cd^d
							x[k] = x[k]:map(function(z)
								if TensorRef:isa(z) then
--print('checking term# '..k..': '..z)
									local dstIndexes = table()
									local indexObjs = table()
									for m=2,#z do
										local sym = z[m].symbol
										local _, s = srcIndexObjs:find(nil, function(s) return s.symbol == sym end)
										if s then
											dstIndexes:insert(m)
											indexObjs:insert(z[m]:clone())
										end
									end
--print('found matching index objs '..table.mapi(indexObjs, tostring):concat' ')
--print('...at indexes '..require 'ext.tolua'(dstIndexes))
									-- can't share any more indexes with our source object than we are symmetrizing ... unless you are breaking index notation rules
									if #dstIndexes > #indexes then
										local msg = "looks like you tried to symmetrize a tensor that was multiplied to another tensor ... and the other tensor was using duplicated sum indexes ... in mul expr "..tostring(x)
										print(msg, '<br>')
										error(msg)
									end
									if #indexObjs >= 2 then
										--[[ TODO just use recursion?
										do return z:symmetrizeIndexes(z[1], dstIndexes) end
										--]]
										
										indexObjs:sort(function(a,b) 
											if a.symbol ~= b.symbol then
												return tostring(a.symbol) < tostring(b.symbol) 
											end
											return tostring(a.lower) < tostring(b.lower)
										end)

										-- [=[ until then, gotta do this check twice
										-- then again, because these sorts are based on relabeling and not on tensor symmetry, it shouldn't matter if they have commas or not
										-- then again, upper/lower does get switched, so if we have a comma then we don't want to switch that.
										-- so we do want to do this, but only for derivative, not for upper/lower
										-- so if we are indirectly sorting
										-- then ...
										-- if they have all the same upper/lower despite mixed commas, we are safe
										-- if they have varying upper/lower but no commas anywhere then we are safe
										-- otherwise, if the upper/lower varies, and we have commas anywhere, then we can't symmetrize this (indirectly)
										if not override 
										and z:hasDerivIndex()
										then
											-- don't allow swaps of derivatives with non-derivatives
											--local lower = z[dstIndexes[1]].lower
											local lower = not not z[dstIndexes[1]].lower
											for m=1,#dstIndexes do
												if not not z[dstIndexes[m]].lower ~= lower then
													return
													--error("found first derivative="..tostring(derivative).." next derivative="..tostring(indexObjs[m].derivative))
												end
											end
										end
										--]=]

										z = z:clone()
										for i,m in ipairs(dstIndexes) do
											z[m].symbol = indexObjs[i].symbol
											z[m].lower = indexObjs[i].lower
										end
										return z
									end
								end
							end)
						end
					end
				end
			end
			if found then return x end
		end
	end)
end

--[[
right now symmath.simplify() puts in the order of div -> mul -> add
this puts things in the order of add -> mul -> div
it does so very poorly, using both simplify() and factorDivision() (which is probably improperly named)
--]]
function Expression:simplifyAddMulDiv()
	symmath = symmath or require 'symmath'
	return self():factorDivision()
	:map(function(y)
		if symmath.op.add:isa(y) then
			local newadd = table()
			for i=1,#y do
				newadd[i] = y[i]():factorDivision()
			end
			return #newadd == 1 and newadd[1] or symmath.op.add(newadd:unpack())
		end
	end)
end

--[[
generalizing this is tough..
this might be getting out of hand:
isMetric(g) = returns true if g is a metric TensorRef
canSimplify(g,t,gi,ti) = returns true if g can be combined with TensorRef t at g's TensorIndex gi and t's TensorIndex ti
--]]
Expression.simplifyMetricsRules = {
	-- returns true/false on whether the simplify works
	delta = {	-- delta^i_j T_ik = T_jk
		isMetric = function(g)
			Tensor = Tensor or require 'symmath.Tensor'
			return g[1] == Tensor:deltaSymbol()
			and g[2].lower ~= g[3].lower
		end,
		canSimplify = function(g, t, gi, ti)
			return t[ti].lower ~= g[gi].lower
		end,
	},
	metric = {	-- g^ij T_jk = T^i_k (provided T is not delta)
		isMetric = function(g)
			Tensor = Tensor or require 'symmath.Tensor'
			return g[1] == Tensor:metricSymbol()
		end,
		canSimplify = function(g, t, gi, ti)
			Tensor = Tensor or require 'symmath.Tensor'
			return t[1] ~= Tensor:deltaSymbol()	-- don't apply g^ij * delta^k_j => delta^ki
			and t[ti].lower ~= g[gi].lower
			-- you know, if derivs are always rightmost, then this is basically if it has any deriv
			--and not t:hasDerivAtOrAfter(ti)		-- don't apply g^ij to T_k,i => T_k^,i
			and not t:hasDerivIndex()
		end,
	},
}
function Expression:simplifyMetrics(rules)
	--deltas, onlyTheseSymbols)
	local expr = self

	Array = Array or require 'symmath.Array'
	Tensor = Tensor or require 'symmath.Tensor'
	TensorRef = TensorRef or require 'symmath.tensor.TensorRef'
	add = add or require 'symmath.op.add'
	mul = mul or require 'symmath.op.mul'
	if Array:isa(expr) then
		return getmetatable(expr):lambda(expr:dim(), function(...)
			local ei = expr:get{...}
			return (ei:simplifyMetrics(rules))
		end)
	end
	Equation = Equation or require 'symmath.op.Equation'
	if Equation:isa(expr) then
		return getmetatable(expr)(
			expr[1]:simplifyMetrics(rules),
			expr[2]:simplifyMetrics(rules)
		)
	end


	-- TODO metricSymbols(), including delta, g, e, ...
	-- also TODO, how to specify how to treat each symbol?
	-- right now I'm just treating deltaSymbol as delta, and any other as a metric
	-- but for a truly flexible framework, we would want to correlate metrics with covariant derivatives for simplification
	if not rules then
		rules = table()
		rules:insert(self.simplifyMetricsRules.delta)
		rules:insert(self.simplifyMetricsRules.metric)
	else
		rules = table(rules)
	end

	expr = expr:clone()
	expr = expr:simplifyAddMulDiv()	-- put it in add-mul-div order
	local function checkMul(expr)
		if not mul:isa(expr) then return expr end

		local found
		repeat
			found = false
			for ruleIndex,rule in ipairs(rules) do
--print('checking rule ', rule)
				for exprGIndex,g in ipairs(expr) do
					if TensorRef:isa(g) 
					and #g == 3 -- no derivatives
					and rule.isMetric(g) -- make sure it matches what we are looking for
					then
--print('found metric symbol '..g)						
						for gi=2,3 do
							local gTensorIndex = g[gi]
							for exprTIndex,t in ipairs(expr) do
								if exprGIndex ~= exprTIndex
								and TensorRef:isa(t) 
								then
									for ti=2,#t do
										local tTensorIndex = t[ti]
										if tTensorIndex.symbol == gTensorIndex.symbol 
										and rule.canSimplify(g, t, gi, ti) 
										then
											local gReplTensorIndex = g[5 - gi]
--print('applying '..g..' to '..t)
											t[ti].symbol = gReplTensorIndex.symbol
											t[ti].lower = gReplTensorIndex.lower
											
											-- hmm, general rule ...
											-- metric^ik metric_kj = delta^i_j for any metric symbol
											if g[1] == t[1]
											and #t == 3
											and t[2].lower ~= t[3].lower
											then
												t[1] = Tensor:deltaSymbol()
											end

											table.remove(expr, exprGIndex)
--print('now we have '..expr)											
											found = true
											break
										end
									end
								end
								if found then break end
							end
							if found then break end
						end
					end
					if found then break end
				end
				if found then break end
			end
		until not found
		if #expr == 1 then expr = expr[1] end
		return expr
	end
	if add:isa(expr) then
		for i=1,#expr do
			expr[i] = checkMul(expr[i])
		end
		if #expr == 1 then expr = expr[1] end
	else
		expr = checkMul(expr)
	end
	return expr
end

--[[
returns fixedIndexes, sumIndexes, extraIndexes
fixedIndexes = the indexes that are used to uniquely index the expression
				the indexes that are shared in common with every expression used
sumIndexes = the indexes used for summing within/ specific to sub-expressions
extraIndexes = any indexes that are not fixed (i.e. shared between all terms), and are not summed.

unm, falls through

for any function ... sinh
	- fixed turn into extra
	- summed fall through

--]]
function Expression:getIndexesUsed()
	TensorIndex = TensorIndex or require 'symmath.tensor.TensorIndex'
	TensorRef = TensorRef or require 'symmath.tensor.TensorRef'
	add = add or require 'symmath.op.add'
	sub = sub or require 'symmath.op.sub'
	mul = mul or require 'symmath.op.mul'

	local function combine(a,b)
		local s = table()
		for _,t in ipairs{a,b} do
			for _,i in ipairs(t) do
				local symbol = i.symbol
				local _,index = s:find(nil, function(i) return i.symbol == symbol end)
				if not index then
					i = i:clone()
					i.count = 1
					s:insert(i)
				else
					index.count = index.count + 1
				end
			end
		end
		return s
	end

	--[[
	- fixed indexes are those with 1 occurrence
	- summed indexes are those with 2 occurrences
	- ... 3 or more occurrences and it is technically not abstract index notation.
		... TODO? return a 4th table of incorrect indexes?
		or TODO error if you find 3 or more?
	--]]
	if TensorRef:isa(self) then
		
		local indexCounts = table()
		for i=2,#self do
			local ti = self[i]
			local symbol = ti.symbol
			local _,indexForSymbol = indexCounts:find(nil, function(index)
				return index.symbol == symbol
			end)
			if not indexForSymbol then
				indexForSymbol = ti:clone()
				indexForSymbol.count = 0	-- should I be using this field in TensorIndex?
				indexCounts:insert(indexForSymbol)
			end
			indexForSymbol.count = indexForSymbol.count + 1
		end
		return 
			-- fixed
			indexCounts:filter(function(index,symbol)
				return index.count == 1
			end),
			-- summed
			indexCounts:filter(function(index,symbol)
				return index.count > 1
			end),
			-- extra
			table()
	
	--[[
	- mul's fixed indexes are the superset of sub-expr fixed-indexes 
		... unless they are matched between sub-exprs, then they are sum indexes
	- mul's summed indexes are a superset of sub-exprs summed,
		... plus those matched between
	- mul's extras ... are also a superset of sub-exprs 
		... unless they match, in which case they go to sum
	--]]
	elseif mul:isa(self) then

		local indexCounts = table()
		local results = table.mapi(self, function(xi,i)
			local fixed, summed, extra = xi:getIndexesUsed()
			for _,ts in ipairs{fixed or {}, summed or {}, extra or {}} do
				for _,ti in ipairs(ts) do
					local symbol = ti.symbol
					local _,indexForSymbol = indexCounts:find(nil, function(index)
						return index.symbol == symbol
					end)
					if not indexForSymbol then
						indexForSymbol = ti:clone()
						indexForSymbol.count = 0	-- should I be using this field in TensorIndex?
						indexForSymbol.extra = ti == extra or nil
						indexCounts:insert(indexForSymbol)
					end
					indexForSymbol.count = indexForSymbol.count + (ts == summed and 2 or 1)
				end
			end
		end)
		return 
			-- fixed
			indexCounts:filter(function(index,symbol)
				return index.count == 1 and not index.extra
			end),
			-- summed
			indexCounts:filter(function(index,symbol)
				return index.count > 1
			end),
			-- extra
			indexCounts:filter(function(index,symbol)
				return index.count == 1 and index.extra
			end)

	--[[
	- fixed = the subset of its sub-expr's fixed indexes 
		... or the super-set?
		subset, this means the whole sum is indexed by these, whereas the individual subexprs could be indexed by more/other things
	- summed = is the superset of its sub-expr's summed indexes
	- extra = are the superset of fixed minus the subset
	--]]
	elseif add:isa(self) or sub:isa(self) then
		local info = table.mapi(self, function(xi)
			local fixed, summed, extra = xi:getIndexesUsed()
			fixed = combine(fixed,extra)
			return {
				fixed = fixed,
				summed = summed,
				-- don't assume extras but deduce them from fixed terms that don't match up
			}
		end)

		local fixedCombined = info[1].fixed
		local summed = info[1].summed
		for i=2,#info do
			fixedCombined = combine(fixedCombined, info[i].fixed)
			summed = combine(summed, info[i].summed)
		end
		
		local fixed = table()
		local extra = table()
		for _,index in ipairs(fixedCombined) do
			local count = index.count
			index.count = 1
			if count == #info then
				fixed:insert(index)
			else
				extra:insert(index)
			end
		end

		return fixed, summed, extra

	elseif Expression:isa(self) then
		-- not an add, sub, mul ... pass through?
		-- how to combine by default?
		-- combine summed?
		-- move all fixed into extra?
		local summed = table()
		local extra = table()
		for i,xi in ipairs(self) do
			local subFixed, subSummed, subExtra = xi:getIndexesUsed()
			extra = combine(extra, subFixed)
			extra = combine(extra, subExtra)
			summed = combine(summed, subSummed)
		end
		return table(), summed, extra
	end
end

-- TODO don't even use this, instead change tensor assignment
function Expression:makeDense()
	Tensor = Tensor or require 'symmath.Tensor'
	local indexes = self:getIndexesUsed()	
	return Tensor(indexes, function(...)
		-- now we have to swap out the comma derivatives of each index with the respective index provided
error'you are here'
		return self:get{...}
	end)
end



--[[
returns a table:
t[sym] = {{expr=expr, index=index}, ...}
	expr is a TensorRef
	index is which index holds this symbol
maybe this will replace 'getIndexesUsed'
at least if this is called on a flattened expression, then the 1-count symbols are the fixed symbols
but getIndexesUsed' fixed indexes are those found in every expression
so this function could replace getIndexesUsed' behavior if it compares the returned exprs to the entire set of exprs
--]]
function Expression:getExprsForIndexSymbols()
	TensorRef = TensorRef or require 'symmath.tensor.TensorRef'
	local exprsForSymbol = {}
	local function rfind(x)
		if TensorRef:isa(x) then
			for i=2,#x do
				local symbol = x[i].symbol
				exprsForSymbol[symbol] = exprsForSymbol[symbol] or table()
				exprsForSymbol[symbol]:insert{expr=x, index=i}
			end
		elseif Expression:isa(x) then
			for i=1,#x do
				rfind(x[i])
			end
		end
	end
	rfind(self)
	return exprsForSymbol
end


-- hmm, rules ...
-- static function, 'self' is the class
function Expression:pushRule(name)
	local visitor, rulename = string.split(name, '/'):unpack()
	assert(visitor and rulename, "Expression:pushRule expected format visitor/rule")	
	
	local rules = assert(self.rules[visitor], "couldn't find visitor "..visitor)
	
	local _, rule = table.find(rules, nil, function(r) return next(r) == rulename end)
	assert(rule, "couldn't find rule named "..rulename.." in visitor "..visitor)

	self.pushedRules = self.pushedRules or table()
	self.pushedRules[rule] = true 
end

function Expression:popRules()
	self.pushedRules = table()
end


-- alternative name? is-function-of?
function Expression:dependsOn(x)
	Variable = Variable or require 'symmath.Variable'
	TensorRef = TensorRef or require 'symmath.tensor.TensorRef'
	map = map or require 'symmath.map'
	
	local found = false
	map(self, function(ai)
		-- x is a sub-expression of the expression
		if ai == x then 
			found = true 
			return 1	-- short-circuit
		end
		-- x'^i' is a sub-expression of the expression
		if TensorRef:isa(ai) and TensorRef:isa(x)
		and ai[1] == x[1]
		and #ai == #x
		then
			found = true
			return 1	-- short-circuit
		end
		-- x or x^i is a dependent variable of a variable in the expression
		if (
			Variable:isa(ai)
			or (TensorRef:isa(ai) and Variable:isa(ai[1]))
		) and ai:dependsOn(x) 
		then 
			found = true 
			return 1	-- short-circuit
		end
	end)
	return found
end

-- returns a table of all variables used by all the expression passed to it
function Expression.getDependentVars(...)
	symmath = symmath or require 'symmath'
	local vars = {}
	local function collectVars(x)
		if symmath.Variable:isa(x) then
			vars[x.name] = x
		end
	end
	for i=1,select('#', ...) do
		select(i, ...):map(collectVars)
	end
	return table.values(vars)
end

--[[
function for telling the interval of arbitrary expressions
TODO maybe a getDomain()?  but I would like separate evaluation for real and complex versions of functions...
technically getRealRange()? since domain is the valid input.

ok for performance I'm going to cache this, in '.cachedSet'
this isn't too far from Variable's explicit override, '.set' ... maybe I should just use .set for every node?
but what happens if an expression is initialized with a variable, the cachedSet is calculated and cached, then the Variable .set is changed? 
well then, you can clear all nodes' .cachedSet by :clone()ing it.  if that's even undesired behavior.
--]]
function Expression:getRealRange()
	-- TODO default to 'real' ?
	return self.cachedSet
end

-- TODO caching as well? or TODO get rid of caching in both?
function Expression:getRealDomain()
	symmath = symmath or require 'symmath'
	return symmath.set.real
end


--[[
transform all indexes by a specific transformation
this is a lot like the above function

how to generalize the above function?
above: if the lower/upper doesn't match our lower/upper then insert multiplciations with metric tensors
ours: if the capital/lowercase doesn't match our capital/lowercase then do the same

rule:
	defaultSymbols = what default symbols to use.  if this isn't specified then Tensor.defaultSymbols is used
	matches = function(x) returns true to use this TensorRef
	applyToIndex = function(x,i,gs,unusedSymbols)
		x = TensorRef we are examining
		i = the i'th index we are examining
		gs = list of added expressions to insert into
		unusedSymbols = list of unused symbols to take from
		returns true if the TensorRef's index needs to be changed
--]]
function Expression:insertTransformsToSetVariance(rule)
	symmath = symmath or require 'symmath'
	local mul = symmath.op.mul
	local Variable = symmath.Variable
	local Tensor = symmath.Tensor
	local TensorRef = symmath.TensorRef

	local defaultSymbols = nil 
		--or args and args.symbols
		or rule.defaultSymbols
		or Tensor.defaultSymbols


	-- TODO assert that we are in add-mul-div form?
	-- otherwise this could introduce bad indexes ...
	-- in fact, even if we are in add-mul-div, applying to multiple products will still run into this issue
	local exprFixed, exprSum, exprExtra = self:getIndexesUsed()
	local exprAll = table():append(exprFixed, exprSum, exprExtra)
	local unusedSymbols = table(defaultSymbols)
	for _,s in ipairs(exprAll) do
		unusedSymbols:removeObject(s.symbol)
	end
	-- so for now i will choose unnecessarily differing symbols
	-- just call tidyIndexes() afterwards to fix this
	
	local handleTerm

	local function fixTensorRef(x)
		x = x:clone()
		-- TODO move this to 'rule'
		if TensorRef:isa(x) then
			if not Variable:isa(x[1]) then
				x[1] = handleTerm(x[1])
			elseif rule.matches(x) then
				local gs = table()
				for i=2,#x do
					rule.applyToIndex(x, i, gs, unusedSymbols)
				end
				return x, gs:unpack()
			end
		end
		return x
	end

	local function handleMul(x)
		local newMul = table()
		for i=1,#x do
			newMul:append{fixTensorRef(x[i])}
		end
		return mul(newMul:unpack())
	end

	-- could be a single term or multiple multiplied terms
	handleTerm = function(expr)
		expr = expr:clone()
		if mul:isa(expr) then
			return handleMul(expr)
		else
			return expr:map(function(x)
				if mul:isa(x) then
					return handleMul(x)
				else
					local results = {fixTensorRef(x)}
					if #results == 1 then
						return results[1]
					else
						return mul(table.unpack(results))
					end
				end
			end)
		end
		return expr
	end
	return handleTerm(self)
end


--[[
self = expression to replace TensorRef's of
t = TensorRef
metric (optional) = metric to use

For this particular TensorRef (of a variable and indexes),
looks for all the TensorRefs of matching variable with matching # of indexes
(and no derivatives for that matter ... unless they are covariant derivatives, or the last index only is changed?),
and insert enough metric terms to raise/lower these so that they will match the 't' argument.
--]]
function Expression:insertMetricsToSetVariance(find, metric)
	symmath = symmath or require 'symmath'
	local TensorRef = symmath.TensorRef
	local TensorIndex = symmath.TensorIndex

	assert(metric)
	
	assert(TensorRef:isa(find))
	--assert(Variable:isa(find[1]))
	assert(not find:hasDerivIndex())	-- TODO handle derivs later?  also TODO call splitOffDerivIndexes() first? or expect the caller to do this 

	return self:insertTransformsToSetVariance{
		matches = function(x)
			return find[1] == x[1]			-- TensorRef base variable matches
			and #find == #x					-- number of indexes match
			and not x:hasDerivIndex()	-- not doing this right now
		end,
		applyToIndex = function(x, i, gs, unusedSymbols)
			local xi = x[i]
			local findi = find[i]
			if not not findi.lower ~= not not xi.lower then
				local sumSymbol = unusedSymbols:remove(1)
				assert(sumSymbol, "couldn't get a new symbol")
				local g = TensorRef(
					metric,
					xi:clone(),
					TensorIndex{
						lower = xi.lower,
						symbol = sumSymbol,
					}
				)
				gs:insert(g)
				xi.lower = findi.lower
				xi.symbol = sumSymbol
			end
		end,
	}
end

-- maybe coroutines will help my whole problem of testing when a mul or add is present ?

function Expression:iteradd()
	symmath = symmath or require 'symmath'
	local add = symmath.op.add
	return coroutine.wrap(function()
		if not add:isa(self) then
			coroutine.yield(self)
			return
		end
		for i=1,#self do
			coroutine.yield(self[i])
		end
	end)
end

function Expression:itermul()
	symmath = symmath or require 'symmath'
	local mul = symmath.op.mul
	return coroutine.wrap(function()
		if not mul:isa(self) then
			coroutine.yield(self)
			return
		end
		for i=1,#self do
			coroutine.yield(self[i])
		end
	end)
end


--[[
Variable and Function names ... and anything else

Right now in Variables I pass in an arg to override the .name field.
But for some variables (the builtin i,e, pi, inf) and for some exporters, it is nice to have custom names.
so how to define this?
How about var.nameForExporter[exporter] = 'some name' ?

and then, the exporter calls ":nameForExporter(exporter.name)" for Variables (and functions too, why not)
and :nameForExporter(exporter) returns the name override, if provided, or otherwise returns the base name?
--]]
local Export
function Expression:nameForExporter(...)
	local n = select('#', ...)
	local exporter, newName = ...
	if n < 1 or n > 2 then
		error("usage: expr:nameForExporter(exporter, [new name]) - gets or sets the name for the specific exporter")
	end

--print((n == 1 and 'getting' or 'setting')..' var.name='..self.name..' args=', ...)

	if type(exporter) == 'string' then
		exporter = require ('symmath.export.'..exporter)
	end

	Export = Export or require 'symmath.export.Export'
	assert(Export:isa(exporter), "expected an Export subclass")

--print('using nameForExporterTable='..self.nameForExporterTable)
--print('...which contains '..require 'ext.tolua'(self.nameForExporterTable and table.map(self.nameForExporterTable, function(v,k) return v, k.name end) or self.nameForExporterTable))
	-- get old name associated with the exporter, or one of its ancestors
	local oldName
	if self.nameForExporterTable then
		local e = exporter
		while e do
--print('checking against exporter='..e..' exporter.name='..e.name)
			local name = self.nameForExporterTable[e.name]
			if name then 
--print('...found '..name)
				oldName = name 
				break
			end
			e = e.super
		end
	end
	-- last use the .name field
	if not oldName then
		oldName = self.name
	end

	-- set new name
	if n == 2 then
		self.nameForExporterTable = self.nameForExporterTable or {}
		-- if the class has it then copy it over
		if self.nameForExporterTable == getmetatable(self.nameForExporterTable) then
			self.nameForExporterTable = setmetatable(table(self.nameForExporterTable), nil)
		end
--print('setting nameForExporterTable='..self.nameForExporterTable..' key/exporter='..exporter..' key/exporter.name='..exporter.name..' value='..newName)
		self.nameForExporterTable[exporter.name] = newName
	end

	-- TODO here - do 'fixVariableNames' - and then use this function everywhere for the name getter.

--print('done and returning name '..oldName)
--print()
	return oldName 
end

-- 
function Expression:plot(args)
	symmath = symmath or require 'symmath'

	-- override args
	args = args or {}
	args[1] = args[1] or {}
	args[1][1] = self
	if not args.outputType then
		if symmath.export.Console:isa(symmath.tostring) then
			-- inline text
			args.outputType = 'Console'
		else
			-- inline SVG
			args.outputType = 'MathJax'
		-- else TODO png? i guess you can just specify this in 'args' with 'terminal' and 'output'
		end
	end

	symmath.export.GnuPlot:plot(args)
end

-- TODO? idk put this in its own file or not?  this is just me being lazy.  
-- honestly this should be done automatically in simplify(), by # of occurrence of each variable
function Expression:polyform()
	symmath = symmath or require 'symmath'
	local Variable = symmath.Variable
	local TensorRef = symmath.TensorRef
	local expr = self
	local vars = table()
	expr:map(function(x)
		if Variable:isa(x)
		or (TensorRef:isa(x) and Variable:isa(x[1]))
		then
			-- TODO ... how about # of indexes?  how about derivatives?  etc
			vars:insertUnique(x)
		end
	end)
	vars:sort(function(a,b)
		local aname = TensorRef:isa(a) and a[1].name or a.name
		local bname = TensorRef:isa(b) and b[1].name or b.name
		return aname < bname
	end)
	for _,var in ipairs(vars) do
		local coeffs = expr:polyCoeffs(var)
		expr = 0
		local extra = coeffs.extra
		coeffs.extra = nil
		local keys = table.keys(coeffs):sort():reverse()
		for _,n in ipairs(keys) do
			local c = coeffs[n]
			if c then
				if n == 0 then
					expr = expr + c
				elseif n == 1 then
					expr = expr + c * var
				else
					expr = expr + c * var^n
				end
			end
		end
		if extra then
			expr = expr + extra
		end
	end
	return expr
end

return Expression
