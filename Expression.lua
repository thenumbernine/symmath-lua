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
--]]
function Expression:replaceIndex(find, repl, cond)
	local TensorRef = require 'symmath.tensor.TensorRef'
	
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
					
					local first = math.max(0, table.keys(already):inf():byte() - ('a'):byte())
					
					-- TODO pick symbols from the basis associated with the to-be-replaced index
					-- that means excluding those from all other basis
					for i=0,25 do
						local p = string.char(('a'):byte()+(i+first)%26)
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
						[xsymbols:concat()..newsumsymbols:concat()] = 
							findsymbols:concat()..sumsymbols:concat()
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
--]]
function Expression:tidyIndexes()
	-- process each part of an equation independently
	local Equation = require 'symmath.op.Equation'
	if Equation.is(self) then
		return getmetatable(self)(self[1]:tidyIndexes(), self[2]:tidyIndexes())
	end
	
	local TensorRef = require 'symmath.tensor.TensorRef'
	local mul = require 'symmath.op.mul'
	local add = require 'symmath.op.add'
	local sub = require 'symmath.op.sub'

	-- assume by here we're working with non-equation expressions
	-- so find all fixed and sum indexes
	-- don't bother check upper vs lower indexes
	local symbolCounts = table()
	local savedSymbolCounts
	local function rmap(expr)
	
		local ismul = mul.is(expr)
		local isadd = add.is(expr)
		local issub = sub.is(expr)
	
		local push = table(symbolCounts)

		for i=1,#expr do
			rmap(expr[i])
		
			-- if we just got done processing a mul ...
			-- then save the symbolCounts
			-- and if we've saved before
			-- then compare symbol counts
			if isadd or issub then
				if not savedSymbolCounts then
					savedSymbolCounts = table(symbolCounts)
				else
					--print('comparing symbol counts after mul...')
					--print('saved', require 'ext.tolua'(savedSymbolCounts))
					--print('new', require 'ext.tolua'(symbolCounts))
				
					-- assert that the fixed symbols in each sub expression of add or sub match
					-- <=> assert the same number of symbols whose count is 1 match
					-- otherwise we have an invalid tensor index expression
					-- The set of fixed symbols may have changed
					-- The things to check are that any in one are also in the other
					-- and also, if any are fixed that they were not summed indexes somewhere else
					for symbol,count in pairs(symbolCounts) do
						local savedCount = savedSymbolCounts[symbol]
						if not savedCount then
							savedSymbolCounts[symbol] = count
						else
							assert((count == 1) == (savedCount == 1))
						end
					end
				end
			end
		
			if not ismul then symbolCounts = table(push) end
		end
	
		if TensorRef.is(expr) then
			for i=2,#expr do
				local symbol = expr[i].symbol
				symbolCounts[symbol] = (symbolCounts[symbol] or 0) + 1
			end
		end
	end
	rmap(self)
	savedSymbolCounts = savedSymbolCounts or symbolCounts
	--print('counts', require 'ext.tolua'(symbolCounts))

	-- you can only count as you are considering multiplications
	-- i.e. a^ij (b_jk + c_jk) will have two 'k's, but they are fixed
	local fixedSymbols = table()
	local sumSymbols = table()
	for symbol, count in pairs(savedSymbolCounts) do
		if count == 1 then
			fixedSymbols:insert(symbol)
		else
			assert(count > 1)
			sumSymbols:insert(symbol)
		end
	end
	--print('fixed', fixedSymbols:concat())


	-- now relabel
	local sofar = table()
	local replSymIndex = 0	-- TODO don't stray into other index ranges ...
	while fixedSymbols:find(string.char(('a'):byte() + replSymIndex))  do
		replSymIndex = replSymIndex + 1
	end

	local replMap = table()

	-- pick a symbol ...
	-- not in replMap's destination yet
	-- not in the fixed symbol list
	local function getnewsymbol()
	end
	
	local function rmap(expr)
		if expr.clone then expr = expr:clone() end	

		local pushsofar = table(sofar)
		local pushReplSymIndex = replSymIndex
		local ismul = mul.is(expr)

		for i=1,#expr do
			expr[i] = rmap(expr[i]) or expr[i]
		
			-- if it's not a mul then we need to push/pop
			if not ismul then
				sofar = table(pushsofar)
				replSymIndex = pushReplSymIndex 
			end
		end
	
		if TensorRef.is(expr) then
			for i=2,#expr do
				local symbol = expr[i].symbol
				if not fixedSymbols:find(symbol) then
					if not sofar:find(symbol) 
					then
						sofar:insert(symbol)
						local replSym = string.char(('a'):byte() + replSymIndex)
						--print('replacing',symbol,'with',replSym)
						replMap[symbol] = replSym
					
						-- TODO this better ...
						repeat
							replSymIndex = replSymIndex + 1
						until not fixedSymbols:find(string.char(('a'):byte() + replSymIndex)) 
					end
					expr[i].symbol = replMap[expr[i].symbol]
				end
			end
		end
	
		return expr
	end
	local result = rmap(self)

	--[[
	local from = table()
	local to = table()
	for k,v in pairs(replMap) do
		from:insert(k)
		to:insert(v)
	end
	result = result:reindex{[from:concat()] = to:concat()}
	--]]
	
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

--]]
function Expression:symmetrizeIndexes(var, indexes)
	return self:map(function(x)
		local TensorRef = require 'symmath.tensor.TensorRef'
		if TensorRef.is(x) 
		and x[1] == var
		and #x >= table.sup(indexes)+1	-- if the indexes refer to derivatives then make sure they're there
		then
			local sorted = table.map(indexes, function(i)
				return x[i+1].symbol
			end):sort()
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
					sorted = table.map(indexes, function(i)
						return y[i+1].symbol
					end):sort()
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
							indexSymbols:sort()
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


-- returns fixedIndexes, sumIndexes
function Expression:getIndexesUsed()
	-- fixedIndexes are those which appear only once on either side of an equality
	-- sumIndexes appear repeated
end


-- hmm, rules ...
-- static function, 'self' is the class
function Expression:pushRule(name)
	local visitor, rulename = name:split'/':unpack()
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

return Expression
