local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local string = require 'ext.string'

local Expression = class()

Expression.precedence = 1
Expression.name = 'Expression'

function Expression:init(...)
	for i=1,select('#', ...) do
		local x = select(i, ...)
		if type(x) == 'number' then
			local Constant = require 'symmath.Constant'
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
	local clone = require 'symmath.clone'
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
	local symmath = require 'symmath'
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

-- wrap it in a separate function so it can call into subclass :match()
-- TODO ... should this really be :match()?
-- What if you want to compare equality of Wildcard objects?  Then this would return false positives.
function Expression.__eq(a,b)
	return a:match(b)
end

-- make sure to require Expression and then require the ops
function Expression.__unm(a) 
	if type(a) == 'number' then a = Constant(a) end
	return require 'symmath.op.unm'(a) 
end
function Expression.__add(a,b)
	local Constant = require 'symmath.Constant'
	
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__add(a,b) end

	if Constant.isValue(a, 0) then return b end
	if Constant.isValue(b, 0) then return a end

	return require 'symmath.op.add'(a,b):flatten()
end
function Expression.__sub(a,b) 
	local Constant = require 'symmath.Constant'
	
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__sub(a,b) end
	
	if Constant.isValue(a, 0) then return -b end
	if Constant.isValue(b, 0) then return a end

	return require 'symmath.op.sub'(a,b) 
end
function Expression.__mul(a,b) 
	local Constant = require 'symmath.Constant'
	
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__mul(a,b) end

--[[
	-- only simplify c * 0 = 0 for constants
	-- because if we have an Array or Equation then we want it to distribute to all elements
	if Constant.is(a)
	and Constant.is(b)
	and (a.value == 0 or b.value == 0)
	then
		return Constant(0)
	end
--]]
-- [[ test for array or equation, otherise simplify to zero
	if Constant.isValue(a, 0) and not require 'symmath.Array'.is(b) and not require 'symmath.op.Equation'.is(b) then return Constant(0) end
	if Constant.isValue(b, 0) and not require 'symmath.Array'.is(a) and not require 'symmath.op.Equation'.is(a) then return Constant(0) end
--]]
	
	if Constant.isValue(a, 1) then return b end
	if Constant.isValue(b, 1) then return a end

	return require 'symmath.op.mul'(a,b):flatten()
end
function Expression.__div(a,b) 
	local Constant = require 'symmath.Constant'
	
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__div(a,b) end
	
	if Constant.is(b) then
		if b.value == 0 then return require 'symmath'.Invalid() end
		if b.value == 1 then return a end
	end
	if Constant.is(a) and a.value == 0 then return Constant(0) end
	
	return require 'symmath.op.div'(a,b) 
end
function Expression.__pow(a,b) 
	local Constant = require 'symmath.Constant'
	
	if type(a) == 'number' then a = Constant(a) end
	if type(b) == 'number' then b = Constant(b) end
	if require 'symmath.op.Equation'.is(b) then return b.__pow(a,b) end
	
	if Constant.is(a) and a.value == 0 then 
		if Constant.is(b) then
			if b.value > 0 then return Constant(0) end
			if b.value == 0 then return Constant(1) end
			if b.value < 0 then return require 'symmath'.inf end
		end
	end
	if Constant.is(b) and b.value == 1 then return a end
	
	return require 'symmath.op.pow'(a,b) 
end
function Expression.__mod(a,b) 
	if type(a) == 'number' then a = require 'symmath.Constant'(a) end
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
Expression.eval = function(...) return require 'symmath.eval'(...) end
Expression.compile = function(...) return require 'symmath'.compile(...) end

function Expression:diff(...) 
--[=[
	local Constant = require 'symmath.Constant'
	
	-- TODO double diff() as differential when no variables are used?
	-- or should that be a separate operator?

	-- d/dx c = 0
	if Constant.is(self) then
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
	return require 'symmath.Derivative'(self, ...) 
end

Expression.integrate = function(...) return require 'symmath'.Integral(...) end
Expression.taylor = function(...) return require 'symmath'.taylor(...) end

function Expression.wedge(a,b) 
	if type(b) == 'number' then b = require 'symmath.Constant'(b) end
	if require 'symmath.op.Equation'.is(b) then return b.wedge(a,b) end
	return require 'symmath.tensor.wedge'(a,b)
end
Expression.dual = function(...) return require 'symmath'.dual(...) end

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
		result = result:replace(eqn:lhs(), eqn:rhs())
	end
	return result
end

--[[
this is like subst but pattern-matches indexes
--]]
function Expression:substIndex(...)
	local eq = require 'symmath.op.eq'
	local result = self:clone()
	for i=1,select('#', ...) do
		local eqn = select(i, ...)
		assert(eq.is(eqn), "Expression:subst() argument "..i.." is not an equals operator") 
		result = result:replaceIndex(eqn:lhs(), eqn:rhs())
	end
	return result
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
	local TensorRef = require 'symmath.tensor.TensorRef'
	
	-- TODO or pick default symbols from specifying them somewhere ... I guess Tensor.defaultSymbols for the time being 
	local defaultSymbols = require 'symmath.Tensor'.defaultSymbols

	local rfindsymbols = table()
	local function rfind(x)
		if TensorRef.is(x) then
			for i=2,#x do
				rfindsymbols[x[i].symbol] = true
			end
		elseif Expression.is(x) then
			for i=1,#x do
				rfind(x[i])
			end
		end
	end
	rfind(self)
	local selfsymbols = rfindsymbols:keys()
	rfindsymbols = table()
	rfind(find)
	local findsymbols = rfindsymbols:keys()
	rfindsymbols = table()
	rfind(repl)
	local replsymbols = rfindsymbols:keys()

--[[
printbr('selfsymbols', selfsymbols:unpack())
printbr('findsymbols', findsymbols:unpack())
printbr('replsymbols', replsymbols:unpack())
--]]
	-- TODO, (a * b'^i'):replaceIndex(a, c'^i' * c'_i')) produces c'^i' * c'_i' * b'^i', not c'^j' * c'_j' * b'^i'
	-- if repl contains a sum index which is already present in the expression then it won't reindex

	local sumsymbols = table()	
	if #replsymbols > #findsymbols then
		for _,replsymbol in ipairs(replsymbols) do
			if not findsymbols:find(replsymbol) 
			and not sumsymbols:find(replsymbol)
			then
				sumsymbols:insert(replsymbol)
			end
		end
	end

	-- for Gamma^i_jk = gamma^im Gamma_mjk
	-- findsymbols = ijk
	-- replsymbols = ijkm
	-- sumsymbols = m

	if TensorRef.is(find) then
		
		local newsumusedalready = table()
		
		local mul = require 'symmath.op.mul'
		local function rmap(expr, callback)
			if expr.clone then expr = expr:clone() end
		
			--[[
			while traversing parent-first,
			if you come across a mul operation,
			push and pop while new sum symbols you have already used.
			This means not using self:map since it is always child-first, or expanding on it
			--]]
			local pushnewsumusedalready = table(newsumusedalready)
			local ismul = mul.is(expr)
			
			for i=1,#expr do
				expr[i] = rmap(expr[i], callback)
			
				if not ismul then
					newsumusedalready = table(pushnewsumusedalready)
				end
			end

			expr = callback(expr) or expr
		
			return expr
		end
		
		local function sameVariance(a,b)
			if #a ~= #b then return false end
			for i=2,#a do
				if a[i].lower ~= b[i].lower then return false end
				if a[i].derivative ~= b[i].derivative then return false end
			end
			return true
		end
		
		return rmap(self, function(x)
			if TensorRef.is(x) 
			
-- if indexes are split (like for pattern matching derivatives)
-- then this equality will only be true if the nested tensorref's indexes are also identical -- thus defeating the purpose of the index-invariant replace
			and x[1] == find[1]
			
			and sameVariance(x, find)
			then
				local xsymbols = range(2,#x):map(function(i)
					return x[i].symbol
				end)
				-- reindex will convert xsymbols to findsymbols

--local tolua = require 'ext.tolua'

				-- find new symbols that aren't in selfsymbols
				local newsumsymbols = table()
				local function getnewsymbol()
					local already = {}
					for _,s in ipairs(selfsymbols) do already[s] = true end
					for _,s in ipairs(xsymbols) do already[s] = true end
					for _,s in ipairs(newsumsymbols) do already[s] = true end
					for _,s in ipairs(newsumusedalready) do already[s] = true end
				
					-- TODO determine new from last used previous symbol?
					-- TODO pick symbols from the basis associated with the to-be-replaced index
					-- 	that means excluding those from all other basis
					local allsymbols = args and args.symbols or defaultSymbols
					for _,p in ipairs(allsymbols) do
						if not already[p] then
							return p
						end
					end
				end
				for i=1,#sumsymbols do
					newsumsymbols:insert(getnewsymbol())
				end
				newsumusedalready:append(newsumsymbols)
--print('selfsymbols', tolua(selfsymbols))
--print('xsymbols', tolua(xsymbols))
--print('newsumsumbols', tolua(newsumsymbols))

-- TODO also go through and all the other replsymbols
-- (i.e. sum indexes)
-- and compare them to all indexes in self
-- and rename them to not collide
				local result = repl
				if result.reindex then
					result = result:reindex{
						[' '..table():append(findsymbols, sumsymbols):concat' '] =
							' '..table():append(xsymbols, newsumsymbols):concat' '
					}
				end
			
				return result
			end
		end)
	else
		return self:replace(find, repl, cond)
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
--]]
function Expression:tidyIndexes(args)
	-- process each part of an equation independently
	local symmath = require 'symmath'
	
	-- TODO or pick default symbols from specifying them somewhere ... I guess Tensor.defaultSymbols for the time being 
	local defaultSymbols = require 'symmath.Tensor'.defaultSymbols

	if symmath.Array.is(self) 
	or symmath.op.Equation.is(self)
	then
		local cl = self:clone()
		for i=1,#cl do
			cl[i] = cl[i]:tidyIndexes(args)
		end
		return cl
	end

	local TensorRef = require 'symmath.tensor.TensorRef'
	local Verbose = symmath.export.Verbose
	local unm = symmath.op.unm
	local add = symmath.op.add
	local sub = symmath.op.sub
	local mul = symmath.op.mul
	local div = symmath.op.div
	
	local replaces = table()

	local function rmap(expr, parent, childIndex, parents)
		--[[
		new system:
		for each node, recursively return ...
		1) what fixed indexes there are (i.e. indexes not yet summed) ... and their variance
		2) what indexes have already been summed
		
		for TensorRefs, just return the indexes
		--]]
		if TensorRef.is(expr) then
			local fixed = table()
			local summed = table()
			for i=#expr,2,-1 do
				local symbol = expr[i].symbol
				-- if we have a duplicate index within the same tensor then denote it to be a summed index
				local j = fixed:find(symbol)
				if j then
					fixed:remove(j)
					summed:insert(symbol)
					
					-- TODO right here is where we should put in a request for substituting 'symbol' with whatever next free index is available
					-- but we should store it for until after the whole expression is checked 
					-- since if we replace symbols child-first then we'll get x_i^j y_j^k z_k => x_i^b y_b^a z_a
					-- whereas if we replace symbols parent-first, we will get => x_i^a y_a^b z_b
					-- however, to perform the global replace, I'll have to keep track of the information globally ...
					-- i.e. what TensorRef to replace, and which indexes in the TensorRef to replace
			
					local repl = {
						parent = parent,
						childIndex = childIndex,
						parents = table(parents),
						from = symbol,
						summed = table(summed),
					}
					replaces:insert(1, repl)
				else
					fixed:insert(symbol)
				end
			end
			return fixed, summed
		end

		--[[
		add and sub ops, assert the fixed indexes all match, and return a superset of all summed indexes (so no parent reuses any)
		--]]
		local tableCommutativeEqual = symmath.tableCommutativeEqual
		if add.is(expr) or sub.is(expr) then
			local fixed, summed = rmap(expr[1], expr, 1, table(parents):append{expr})
			summed = summed:map(function(v) return true, v end)
			for i=2,#expr do
				local fixedi, summedi = rmap(expr[i], expr, i, table(parents):append{expr})
				-- TODO only assert equality up to variance and symbol.  don't bother with derivative
				if not tableCommutativeEqual(fixed, fixedi) then
					error("found an addition expression whose fixed indexed didn't match:"
						..require 'ext.tolua'(fixed)..' vs '
						..require 'ext.tolua'(fixedi)..' in '..expr)
				end
				summed = table(summed, summedi:map(function(v) return true, v end))
			end
			summed = summed:keys()
			return fixed, summed
		end

		if unm.is(expr) or div.is(expr) then
			return rmap(expr[1], expr, 1, table(parents):append{expr})
		end

		--[[
		for muls, accumulate indexes ...
		... as you pair child nodes' fixed indexes, also keep track of index remapping information
		... and of course replace indexes as you do this
		--]]
		if mul.is(expr) then
			-- before traversing down into a mul
			-- accumulate all the indexes of this mul
			-- and then pass them down through the mul
			-- so that way we know what symbols

			local fixed, summed
			for i=#expr,1,-1 do
				if not fixed then
					fixed, summed = rmap(expr[i], expr, i, table(parents):append{expr})
					fixed = fixed:map(function(symbol) return {symbol=symbol, i=i} end)
					summed = summed:map(function(v) return true, v end)
				else
					local fixedi, summedi = rmap(expr[i], expr, i, table(parents):append{expr})
					fixedi = fixedi:map(function(symbol) return {symbol=symbol, i=i} end)
					summed = table(summed, summedi:map(function(v) return true, v end))
					
					local j=1
					while j <= #fixed do
						local symbol = fixed[j].symbol
					
						local k=1
						while k <= #fixedi do
							
							if symbol == fixedi[k].symbol then
								--assert(not not fixed[j].lower ~= not not fixedi[j].lower, "can't sum two contra- or two co-variant indexes")
								if summed[symbol] then
									error("found a fixed symbol that's also a summed symbol: "..symbol)
								end
								summed[symbol] = true

								-- at this point, when we find a fixed symbol of a child is really a summed symbol of a mul,
								-- we want to tell other replaces related that info ...
						
								-- TODO 
								-- replace another symbol here
								-- for the replace info,
								-- we have to keep track of which expr child index each symbol is in
								local repl = {
									parent = parent,
									childIndex = childIndex,
									parents = table(parents),
									from = symbol,
									summed = summed:keys(),
								}
								replaces:insert(1, repl)

								fixed:remove(j) j=j-1
								fixedi:remove(k) k=k-1
							end
							k=k+1
						end
					
						j=j+1
					end
					
					-- if 'fixed' and 'fixedi' have any symbols in common then
					-- 1) assert they have nothing in common with 'summed' or 'summedi'
					-- 2) assert their variance is opposite
					-- 3) replace all instances in either expression of the symbol with a new symbol
					-- pick the new symbol by
					-- *) can't exist in summed or summedi
					-- *) ... any other constraints?
					fixed:append(fixedi)
				end
			end
			fixed = fixed:map(function(t) return t.symbol end)
			summed = summed:keys()
			return fixed, summed
		end

		return table(), table()
	end
	local fixed, summed = rmap(self, nil, nil, table())

	if args and args.fixed then
		local Tensor = require 'symmath.Tensor'
		fixed = fixed:append(
			table.mapi(Tensor.parseIndexes(
				args.fixed
			), function(index)
				return index.symbol
			end)
		)
	end


	local expr = self
--[[
print('fixed', fixed:concat', ', '<br>')
print('summed', summed:concat', ', '<br>')
for _,repl in ipairs(replaces) do
	print(repl.parent and repl.parent[repl.childIndex] or expr, 
		'from', repl.from, 
		'summed', repl.summed:concat',', 
		'<br>')
end
--]]	
	local function getnewsymbol(repl)
		local replexpr = repl.parent and repl.parent[repl.childIndex] or expr
		local allsymbols = args and args.symbols or defaultSymbols
		for _,symbol in ipairs(allsymbols) do
			if not summed:find(symbol)
			and not fixed:find(symbol)
			and (not repl.block or not repl.block:find(symbol))
			then
				local blocked

				for _,repl2 in ipairs(replaces) do
					local repl2expr = repl2.parent and repl2.parent[repl2.childIndex] or expr
					--[[
					if rawequal(replexpr, repl2expr)
					and symbol == repl2.to then
						blocked = true
						break
					end
					--]]
					for _,parent in ipairs(table(repl.parents):append{replexpr}) do
						if rawequal(parent, repl2expr)
						and repl2.block
						and repl2.block:find(symbol)
						then
							blocked = true
							break
						end
					end
				end

				if not blocked then
					return symbol
				end
			end
		end
		error("couldn't find any new symbols")
	end 
	for i=1,#replaces do
		local repl = replaces[i]
		local replexpr = repl.parent and repl.parent[repl.childIndex] or expr 
		
		repl.to = getnewsymbol(repl)
		repl.block = repl.block or table()
		repl.block:insert(repl.to)
--print('replacing symbol in',replexpr,'from',repl.from,'to',repl.to,'<br>')
	
		-- now cycle through replaces and look for any children of repl
		-- and tell it in advance what symbols to block
		-- what a mess ...
		-- another way around this is passing down the recursion tree what summed indexes are used
		-- but this still requires two separate recursion passes at each node ...
		
		-- but here's the extra frustrating thing
		-- (a^i + b^i_j c^j) (d_i + e_i^k f_k)
		-- repl first the parent mul, then each child add ...
		-- so the parent will pass on the block info to repl
		-- but also -- the first child's block info will have to pass on to the second child
	
		-- so maybe the block info should be stored parent-most
		-- and then checked parent-most	
		for j=1,i-1 do
			local repl2 = replaces[j]
			local repl2expr = repl2.parent and repl2.parent[repl2.childIndex] or expr
			--if in any of repl2's parents is repl then put repl.to in repl2's preemtive block symbol list
			for _,parent in ipairs(repl.parents) do
				if rawequal(parent, repl2expr) then
					repl2.block = repl2.block or table()
					repl2.block:insert(repl.to)
				end
			end
		end
	end
	-- replace, children first
	-- otherwise the replaced would be disconnected from the graph (replaced by clones)
	for i=#replaces,1,-1 do
		local repl = replaces[i]
		if repl.parent then
			repl.parent[repl.childIndex] = repl.parent[repl.childIndex]:reindex{[' '..repl.from] = ' '..repl.to}
		else
			expr = expr:reindex{[' '..repl.from] = ' '..repl.to}
		end
	end
--print('expr', expr, '<br>')
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

	local clone = require 'symmath.clone'
	local Tensor = require 'symmath.Tensor'
	local TensorIndex = require 'symmath.tensor.TensorIndex'

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
	-- TODO allow for '_,k' incomplete tensor dereferencing *only if* it is comma-derivatives-only
	--  in which case, just append it to the rest of the tensor

	local TensorRef = require 'symmath.tensor.TensorRef'
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
	-- if we find a space then treat it as space-separated multi-char indexes
	local function interpret(s)
		if type(s) == 'number' then return {s} end
		assert(type(s) == 'string', "expected a string, found "..type(s))
		if s:find' ' then
			return string.split(string.trim(s), ' ')
		else
			return string.split(s)
		end
	end
	
	local swaps = table()
	for k,v in pairs(args) do
		local tk = interpret(k)
		local tv = interpret(v)
		
		if #tk ~= #tv then
			local tolua = require 'ext.tolua'
			error("reindex key and value length needs to match.  got "..tolua(tk).." with "..#tk.." entries vs "..tolua(tv).." with "..#tv.." entries")
		end
		for i=1,#tk do
			swaps:insert{src = {symbol=tk[i]}, dst = {symbol=tv[i]}}
		end
	end
	local Tensor = require 'symmath.Tensor'
	local TensorIndex = require 'symmath.tensor.TensorIndex'
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


--[[
here's another tensor-specific function that I want to apply to both Tensor and Variable
so I'm putting here ...

this takes the combined comma derivative references and splits off the comma parts into separate references
it is very helpful for replacing tensors
--]]
function Expression:splitOffDerivIndexes()
	local TensorRef = require 'symmath.tensor.TensorRef'
	return self:map(function(x)
		if TensorRef.is(x) then
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

TODO swap the variance as well, not just the symbol ... and the derivative too ...
... (which means the danger of derivatives being moved out of the rhs places ... test for that)
but if you don't swap variance then  symmetrizing a symbol with mixed variance will introduce mistakes as well
--]]
function Expression:symmetrizeIndexes(var, indexes)
	return self:map(function(x)
		local TensorRef = require 'symmath.tensor.TensorRef'
		if TensorRef.is(x) 
		and x[1] == var
		and #x >= table.sup(indexes)+1	-- if the indexes refer to derivatives then make sure they're there
		then
			local lower
			local sorted = table.mapi(indexes, function(i)
				if lower == nil then 
					lower = not not x[i+1].lower
				else
					if (not not x[i+1].lower) ~= lower then
						error("found first lower="..lower.." next lower="..tostring(x[i+1].lower))
					end
				end
				return x[i+1].symbol
			end):sort(function(a,b) return tostring(a) < tostring(b) end)
			for i,sorted in ipairs(sorted) do
				x[indexes[i]+1].symbol = sorted
			end
		end
		
		-- if there's a var^ijk... anywhere in the mul
		-- then look for matching indexes in any other TensorRef's in the mul
		local mul = require 'symmath.op.mul'
		if mul.is(x) then
			local found
			local sorted
			for i=1,#x do
				local y = x[i]
				if TensorRef.is(y)
				and y[1] == var
				and #y >= table.sup(indexes)+1
				then
					sorted = table.mapi(indexes, function(i)
						return y[i+1].symbol
					end):sort(function(a,b) return tostring(a) < tostring(b) end)
					for i,sorted in ipairs(sorted) do
						y[indexes[i]+1].symbol = sorted
					end				
					
					found = true
					break
				end
			end
			
			if found then
				return x:map(function(y)
					if TensorRef.is(y) then
						local indexes = table()
						local indexSymbols = table()
						for j=2,#y do
							local sym = y[j].symbol
							if sorted:find(sym) then
								indexes:insert(j)
								indexSymbols:insert(sym)
							end
						end
						if #indexSymbols >= 2 then
							indexSymbols:sort(function(a,b) return tostring(a) < tostring(b) end)
							for i,j in ipairs(indexes) do
								y[j].symbol = indexSymbols[i]
							end
						end
					end
				end)
			end
		end
	end)
end

-- TODO make this a standard somewhere
local function betterSimplify(x)
	local symmath = require 'symmath'
	return x():factorDivision()
	:map(function(y)
		if symmath.op.add.is(y) then
			local newadd = table()
			for i=1,#y do
				newadd[i] = y[i]():factorDivision()
			end
			return #newadd == 1 and newadd[1] or symmath.op.add(newadd:unpack())
		end
	end)
end

-- generalizing this is tough..
-- this might be getting out of hand:
Expression.simplifyMetricsRules = {
	-- returns true/false on whether the simplify works
	delta = {	-- delta^i_j T_ik = T_jk
		isMetric = function(g)
			return g[1] == require 'symmath.Tensor':deltaSymbol()
			and g[2].lower ~= g[3].lower
		end,
		canSimplify = function(g, t, gi, ti)
			return t[ti].lower ~= g[gi].lower
		end,
	},
	metric = {	-- g^ij T_jk = T^i_k (provided T is not delta)
		isMetric = function(g)
			return g[1] == require 'symmath.Tensor':metricSymbol()
		end,
		canSimplify = function(g, t, gi, ti)
			return t[1] ~= require 'symmath.Tensor':deltaSymbol()	-- don't apply g^ij * delta^k_j => delta^ki
			and t[ti].lower ~= g[gi].lower
			-- you know, if derivs are always rightmost, then this is basically if it has any deriv
			--and not t:hasDerivAtOrAfter(ti)		-- don't apply g^ij to T_k,i => T_k^,i
			and not t:hasDeriv()
		end,
	},
}
function Expression:simplifyMetrics(rules)
	--deltas, onlyTheseSymbols)
	local expr = self

	local Array = require 'symmath.Array'
	local Tensor = require 'symmath.Tensor'
	local TensorRef = require 'symmath.tensor.TensorRef'
	local add = require 'symmath.op.add'
	local mul = require 'symmath.op.mul'
	if Array.is(expr) then
		return getmetatable(expr):lambda(expr:dim(), function(...)
			local ei = expr:get{...}
			return (ei:simplifyMetrics(rules))
		end)
	end
	if require 'symmath.op.Equation'.is(expr) then
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

	expr = betterSimplify(expr)	-- put it in add-mul-div order
	expr = expr:clone()
	local function checkMul(expr)
		if not mul.is(expr) then return expr end

		local found
		repeat
			found = false
			for ruleIndex,rule in ipairs(rules) do
--print('checking rule ', rule)
				for exprGIndex,g in ipairs(expr) do
					if TensorRef.is(g) 
					and #g == 3 -- no derivatives
					and rule.isMetric(g) -- make sure it matches what we are looking for
					then
--print('found metric symbol '..g)						
						for gi=2,3 do
							local gTensorIndex = g[gi]
							for exprTIndex,t in ipairs(expr) do
								if exprGIndex ~= exprTIndex
								and TensorRef.is(t) 
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
	if add.is(expr) then
		for i=1,#expr do
			expr[i] = checkMul(expr[i])
		end
		if #expr == 1 then expr = expr[1] end
	else
		expr = checkMul(expr)
	end
	return expr
end


-- returns fixedIndexes, sumIndexes
function Expression:getIndexesUsed()
	local TensorIndex = require 'symmath.tensor.TensorIndex'
	local TensorRef = require 'symmath.tensor.TensorRef'
	local add = require 'symmath.op.add'
	local sub = require 'symmath.op.sub'
	local indexCounts = table()
	local function rfind(x)
		if TensorRef.is(x) then
			for i=2,#x do
				local symbol = x[i].symbol
				if not indexCounts[symbol] then
					indexCounts[symbol] = x[i]:clone()
					indexCounts[symbol].count = 0	-- should I be using this field in TensorIndex?
				end
				indexCounts[symbol].count = indexCounts[symbol].count + 1
			end
		elseif add.is(x) or sub.is(x) then
			local subIndexes = x[1]:getIndexesUsed():map(function(index)
				return index, index.symbol
			end)
			for i=2,#x do
				local subIndexes2 = x[i]:getIndexesUsed():map(function(index)
					return index, index.symbol
				end)
				
				--assert(subIndexes == subIndexes2)
				for symbol,index in pairs(subIndexes) do
					assert(subIndexes2[symbol].count == index.count)
				end
				for symbol,index in pairs(subIndexes2) do
					assert(subIndexes[symbol].count == index.count)
				end
			end
			for symbol,index in pairs(subIndexes) do
				if not indexCounts[symbol] then
					indexCounts[symbol] = index:clone()
					indexCounts[symbol].count = 0
				end
				indexCounts[symbol].count = indexCounts[symbol].count + index.count
			end
		elseif Expression.is(x) then
			-- if it's a mul then recurse
			-- if it's an add then don't ... instead test
			
			for i=1,#x do
				rfind(x[i])
			end
		end
	end
	rfind(self)
	return indexCounts:filter(function(index,symbol)
		return index.count == 1
	end):values(), indexCounts:filter(function(index,symbol)
		return index.count > 1
	end):values()
end

-- TODO don't even use this, instead change tensor assignment
function Expression:makeDense()
	local Tensor = require 'symmath.Tensor'
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
--]]
function Expression:getExprsForIndexSymbols()
	local TensorRef = require 'symmath.tensor.TensorRef'
	local exprsForSymbol = {}
	local function rfind(x)
		if TensorRef.is(x) then
			for i=2,#x do
				local symbol = x[i].symbol
				exprsForSymbol[symbol] = exprsForSymbol[symbol] or table()
				exprsForSymbol[symbol]:insert{expr=x, index=i}
			end
		elseif Expression.is(x) then
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
	local Variable = require 'symmath.Variable'
	local TensorRef = require 'symmath.tensor.TensorRef'
	local found = false
	require 'symmath.map'(self, function(ai)
		-- x is a sub-expression of the expression
		if ai == x then 
			found = true 
			return 1	-- short-circuit
		end
		-- x'^i' is a sub-expression of the expression
		if TensorRef.is(ai) and TensorRef.is(x)
		and ai[1] == x[1]
		and #ai == #x
		then
			found = true
			return 1	-- short-circuit
		end
		-- x or x^i is a dependent variable of a variable in the expression
		if (
			Variable.is(ai)
			or (TensorRef.is(ai) and Variable.is(ai[1]))
		) and ai:dependsOn(x) 
		then 
			found = true 
			return 1	-- short-circuit
		end
	end)
	return found
end

-- function for telling the interval of arbitrary expressions
-- TODO maybe a getDomain()?  but I would like separate evaluation for real and complex versions of functions...
function Expression:getRealDomain()
	return nil
end

function Expression:treeSize()
	local n = 1
	for i,x in ipairs(self) do
		if x.treeSize then
			n = n + x:treeSize()
		end
	end
	return n
end

return Expression
