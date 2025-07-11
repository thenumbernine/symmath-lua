local class = require 'ext.class'
local table = require 'ext.table'
local string = require 'ext.string'
local math = require 'ext.math'
local Binary = require 'symmath.op.Binary'
local symmath

local add = Binary:subclass()
add.precedence = 2
add.name = '+'

--[[
-- auto flatten any adds ...?
-- I don't think anyone depends on nested adds ...
-- and flattening here will make the API easier, requiring less simplify's for matching and ==
function add:init(...)
	add.super.init(self, ...)
	self:flatten()
end
--]]

-- in-place flatten
function add:flatten()
	local i = #self
	while i >= 1 do
		self[i]:flatten()
		if add:isa(self[i]) then
			local x = table.remove(self, i)
			for j=#x,1,-1 do
				table.insert(self, i, x[j])
			end
			i = i + #x
		end
		i = i - 1
	end

	-- TODO while you're here, sort terms, don't violate commutativity.
	-- then, for match and __eq, don't bother with commutativity of terms -- just compare term-by-term.
	-- this can also integrate with the ProdLists somehow, which converts to and fro add's often enough to be slow

	return self
end

function add:isFlattened()
	for i,ch in ipairs(self) do
		if add:isa(ch) then return false end
	end
	return true
end

function add:evaluateDerivative(deriv, ...)
	local result = table()
	for i=1,#self do
		result[i] = deriv(self[i]:cloneIfMutable(), ...)
	end
	return add(result:unpack())
end

--local function print(...) return printbr(...) end

--[[
TODO since add() and mul() can have 'n' children
here we should match wildcards across children, greedy 1-or-more
and allow returning either a[i]'s, or sums-of-a[i]'s, or even 0
and somehow work around 'addNonCommutative' or don't since I just now added it and nothing yet uses it, though mul will have to worry about that eventually.
how to accomplish this:
	1) match children only when not against wildcards
	2) collect said wildcards
	3) with what hasn't been matched, try to match it 1-1 with wildcards...
		might get errors if you match least-to-most restrictive wildcards, where less-restrictive wildcards take matches that more-restrictive wildcards don't
		you should probably always pass wildcards to add() or mul() as most-to-least restrictive
		of coures to be certain to match all, might have to try all possible combinations =(
		so iterate over permutations of non-matched order-independent terms.  if all match then go with it.
--]]
function add.match(a, b, matches)
	symmath = symmath or require 'symmath'
	local Wildcard = symmath.Wildcard
	local Constant = symmath.Constant
--DEBUG(@5):local SingleLine = require 'symmath.export.SingleLine'
--DEBUG(@5):local Verbose = require 'symmath.export.Verbose'
--DEBUG(@5):print("add.match(a="..Verbose(a)..", b="..Verbose(b)..", matches={"..(matches or table()):mapi(Verbose):concat', '..'}) begin')

	matches = matches or table()
	-- if 'b' is an add then fall through
	-- this part is only for wildcard matching of the whole expression
	if not add:isa(b) 	-- if the wildcard is an add then we want to test it here
	and b.wildcardMatches
	then
		if not b:wildcardMatches(a, matches) then return false end
--DEBUG(@5):print(" matching entire expr "..SingleLine(b).." to "..SingleLine(a))
		return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
	end
	if getmetatable(a) ~= getmetatable(b) then return false end

	-- NOTICE, this shallow copy means that the metatables are lost, so don't use "a" or "b" as expressions (unless you reset its metatable)
	a = table(a)
	b = table(b)

	-- compare things order-independent, remove as you go
	-- skip wildcards, do those last
	for i=#a,1,-1 do
		local ai = a[i]
		-- non-commutative compare...
		if not ai.addNonCommutative then
			-- table.find uses == uses __eq which ... should ... only pick j if it is mulNonCommutative as well (crossing fingers, it's based on the equality implementation)
			--local j = b:find(ai)
			local j
			for _j=1,#b do
				local bj = b[_j]
				if not Wildcard:isa(bj)
				-- if bj does match then this will fill in the appropriate match and return 'true'
				-- if it fails to match then it won't fill in the match and will return false
				and ai:match(bj, matches)
				then
					j = _j
					break
				end
			end
			if j then
--DEBUG(@5):print(' add.match: removing matched terms...')
--DEBUG(@5):print(a[i])
--DEBUG(@5):print(b[j])
				a:remove(i)
				b:remove(j)
			end
		end
	end

--DEBUG(@5):print("add.match: what's left after matching commutative non-wildcards:")
--DEBUG(@5):print('a:', a:mapi(SingleLine):concat', ')
--DEBUG(@5):print('b:', b:mapi(SingleLine):concat', ')

	-- now compare what's left in-order (since it's non-commutative)
	-- skip wildcards, do those last
	local function checkWhatsLeft(a, b, matches, indent)
--DEBUG(@5):indent=(indent or 0) + 1
--DEBUG(@5):local tab = (' '):rep(indent)
		-- save the original here
		-- upon success, merge the new matches back into the original argument
		local origMatches = matches
		matches = matches or table()
		a = table(a)
		b = table(b)

--DEBUG(@5):print(tab.."checking match of what's left with "..#a.." elements")

		if #a == 0 and #b == 0 then
--DEBUG(@5):print(tab.."matches - returning true")
			return matches[1] or true, table.unpack(matches, 2, table.maxn(matches))
		end

		-- #a == 0 is fine if b is full of nothing but wildcards
		if #b == 0 and #a > 0 then
--DEBUG(@5):print(tab.."has remaining elements -- returning false")
			return false
		end

		-- TODO bi isn't necessarily a wildcard -- it could be an 'addNonCommutative' term (though nothing does this for addition yet)
		if #a == 0 and #b ~= 0 then
			-- TODO verify that the matches are equal
			for _,bi in ipairs(b) do
				if not Wildcard:isa(bi) then
--DEBUG(@5):print(tab.."expected bi to be a Wildcard, found "..SingleLine(bi))
					return false
				end
				if bi.atLeast and bi.atLeast > 0 then
--DEBUG(@5):print(tab.."remaining Wildcard expected an expression when none are left, failing")
					return false
				end
				if matches[bi.index] then
--DEBUG(@5):print(tab.."matches["..bi.index.."] tried to set to Constant(0), but it already exists as "..SingleLine(matches[bi.index]).." -- failing")
					if matches[bi.index] ~= Constant(0) then
						return false
					end
				else
--DEBUG(@5):print(tab.."setting matches["..bi.index.."] to Constant(0)")
					matches[bi.index] = Constant(0)
				end
			end
		end
		if not Wildcard:isa(b[1]) then
			local a1 = a:remove(1)
			local b1 = b:remove(1)

--DEBUG(@5):print(tab.."isn't a wildcard -- recursive call of match on what's left")
			-- hmm, what if there's a sub-expression that has wildcard
			-- then we need matches
			-- then we need to push/pop matches

			local firstsubmatch = table()
			if not a1:match(b1, firstsubmatch) then
--DEBUG(@5):print(tab.."first match didn't match - failing")
				return false
			end

			for i=1,table.maxn(firstsubmatch) do
				if firstsubmatch[i] ~= nil then
					if matches[i] ~= nil then
						if matches[i] ~= firstsubmatch[i] then
--DEBUG(@5):print(tab.."first submatches don't match previous matches - index "..i.." "..SingleLine(matches[i]).." vs "..SingleLine(firstsubmatch[i]).." - failing")
							return false
						end
					else
--DEBUG(@5):print(tab.."index "..b.index)
--DEBUG(@5):print(tab.."a1: "..SingleLine(a1))
--DEBUG(@5):print(tab.."a: "..a:mapi(SingleLine):concat', ')
--DEBUG(@5):print(tab.."matching add subexpr from first match "..SingleLine(a1).." index "..b.index.." to "..a:mapi(SingleLine):concat', ')
						matches[i] = firstsubmatch[i]
					end
				end
			end


			local restsubmatch = table()
			if not checkWhatsLeft(a, b, restsubmatch, indent) then
--DEBUG(@5):print(tab.."first match didn't match - failing")
				return false
			end

			for i=1,table.maxn(restsubmatch) do
				if restsubmatch[i] ~= nil then
					if matches[i] ~= nil then
						if matches[i] ~= restsubmatch[i] then
--DEBUG(@5):print(tab.."first submatches don't match previous matches - index "..i.." "..SingleLine(matches[i]).." vs "..SingleLine(firstsubmatch[i]).." - failing")
							return false
						end
					else
--DEBUG(@5):print(tab.."matching add subexpr from first match "..SingleLine(a1).." index "..b.index.." to "..a:mapi(SingleLine):concat', ')
						matches[i] = restsubmatch[i]
					end
				end
			end

			-- overlay match matches on what we have already matched so far
			-- also write them back to the original argument since we are returning true
			for k,v in pairs(matches) do origMatches[k] = v end
			return matches[1] or true, table.unpack(matches, 2, table.maxn(matches))
		end

--DEBUG(@5):print(tab.."before checking remaining terms, our matches is: "..table.mapi(matches, SingleLine):concat', ')

		-- now if we have a wildcard ... try all 0-n possible matches of it
		local b1 = b:remove(1)
		for matchSize=math.min(#a, b1.atMost or math.huge),(b1.atLeast or 0),-1 do
--DEBUG(@5):print(tab.."checking matches of size "..matchSize)
			for a in a:permutations() do
				a = table(a)
--DEBUG(@5):print(tab.."checking a permutation "..a:mapi(SingleLine):concat', ')

				local b1match = matchSize == 0 and Constant(0)
					or matchSize == 1 and a[1]
					or setmetatable(a:sub(1, matchSize), add)
--DEBUG(@5):print(tab.."b1match "..SingleLine(b1match))
				local matchesForThisSize = table(matches)
--DEBUG(@5):print(tab.."matchesForThisSize["..b1.index.."] was "..(matchesForThisSize[b1.index] and SingleLine(matchesForThisSize[b1.index]) or 'nil'))
-- this is going to get into a situation of comparing all possible permutations of what's left
-- TODO get rid of this whole recursion system, and just use a permutation iterator
-- then keep trying to match wildcards against what is left until things work
-- you know, with nested wildcard/nonwildcards, we might as well just do this for everything.
				if b1match:match(b1, matchesForThisSize) then
--DEBUG(@5):print(tab.."matchesForThisSize["..b1.index.."] is now "..SingleLine(matchesForThisSize[b1.index]))
					local suba = a:sub(matchSize+1)
--DEBUG(@5):print(tab.."calling recursively on "..#suba.." terms: "..table.mapi(suba, SingleLine):concat', ')
					local didMatch = checkWhatsLeft(suba, b, matchesForThisSize, indent)
--DEBUG(@5):print(tab.."returned results from the sub-checkWhatsLeft : "..table.mapi(results, SingleLine):concat', ')
					if didMatch then
--DEBUG(@5):print(tab.."returning that list for matchSize="..matchSize.."...")
						-- also write them back to the original argument since we are returning true
						for k,v in pairs(matchesForThisSize) do origMatches[k] = v end
						return matchesForThisSize[1] or true, table.unpack(matchesForThisSize, 2, table.maxn(matchesForThisSize))
					end
--DEBUG(@5):print(tab.."continuing...")
				else
--DEBUG(@5):print(tab..Verbose(b1)..':match('..SingleLine(b1match)..') failed')
--DEBUG(@5):print(tab.."the next wildcard had already been matched to "..SingleLine(matchesForThisSize[b1.index]).." when we tried to match it to "..SingleLine(b1match))
				end
				-- otherwise keep checking
			end
		end
		-- all sized matches failed? return false
--DEBUG(@5):print(tab.."all sized matches failed - failing")
		return false
	end

	-- now what's left in b[i] should all be wildcards
	-- we just have to assign them between the a's
	-- but if we want add match to return wildcards of +0 then we can't just rely on a 1-or-more rule
	-- for that reason,

	return checkWhatsLeft(a,b, matches)
	--return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
end

--[[
alright, what if we want to match Constant(0):match(Wildcard(1) + Wildcard(2) ?
add needs its own 'wildcardMatches' function for that to happen
... and that function needs to fall when it encounters adds
and if it doesn't ...
then it needs to look through its children and see if it has all-but-1...

... if it has no non-wildcards then make sure we are matching against Constant(0), and match the wildcards with Constant(0)
... if we have all-but-1 wildcards then make sure we are matching against the remaining non-wildcard, and match the wildcards with Constant(0)
... if we have all-but-2 wildcards then fail

TODO consider addNonCommutative operators
--]]
function add:wildcardMatches(a, matches)
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	local Wildcard = symmath.Wildcard
--DEBUG(@5):local SingleLine = require 'symmath.export.SingleLine'
--DEBUG(@5):local Verbose = require 'symmath.export.Verbose'
--DEBUG(@5):print("add.wildcardMatches(self="..Verbose(self)..", a="..Verbose(a)..", matches={"..matches:mapi(Verbose):concat', '..'})')

	-- 'a' is the 'a' in Expression.match(a,b)
	-- 'b' is 'self'
	local nonWildcards = table()
	local wildcards = table()
	for _,w in ipairs(self) do
		-- TODO what about when add/mul have no sub-wildcards?
		if w.wildcardMatches
		and w:hasChild(function(x) return Wildcard:isa(x) end)
		then
			wildcards:insert(w)
		else
			nonWildcards:insert(w)
		end
	end

--DEBUG(@5):print("add.wildcardMatches children: "..table.mapi(self, Verbose):concat', ')
--DEBUG(@5):print("add.wildcardMatches wildcard children: "..table.mapi(wildcards, Verbose):concat', ')
--DEBUG(@5):print("add.wildcardMatches non-wildcard children: "..table.mapi(nonWildcards, Verbose):concat', ')
	if #nonWildcards > 1 then
--DEBUG(@5):print("add.wildcardMatches too many non-wildcards - failing")
		return false
	end

	local defaultValue = Constant(0)
	local matchExpr = a
	if #nonWildcards == 1 then
		-- TODO what if we are doing x:match(W{1,atLeast=1} + W{2}) ?
		if not a:match(nonWildcards[1], matches) then
--DEBUG(@5):print("add.wildcardMatches single remaining add sub-term didn't match first non-wildcard - failing")
			return false
		end
		-- a matches nonWildcards[1]
		matchExpr = defaultValue
	end

	-- if any of these wildcards needed a term then fail
	-- (that will be handled in the add.match fallthrough
	--  which is why add.match should not call this -- only other non-add Expressions' .match())
	local totalAtLeast = 0
	for _,w in ipairs(wildcards) do
		if w.atLeast and w.atLeast > 0 then
			totalAtLeast = totalAtLeast + w.atLeast
			if totalAtLeast > 1 then
--DEBUG(@5):print("add.wildcardMatches: wildcard needs at least 1, and we have none left - failing")
				return false
			end
		end
	end

	-- when matching wildcards, make sure to match any with 'atLeast' first
	if totalAtLeast == 1 then
		for i,w in ipairs(wildcards) do
			-- TODO make this work for sub-expressions?
			if w.atLeast and w.atLeast > 0 then
				if i > 1 then
--DEBUG(@5):print("add.wildcardMatches moving wildcard with 'atleast' from "..i.." to 1")
					table.remove(wildcards, i)
					table.insert(wildcards, 1, w)
				end
				break
			end
		end
	end

	local mul = symmath.op.mul
	-- match all wildcards to zero
	local function checkWildcardPermutation(wildcards, matches)
		-- match all wildcards to zero
		-- test first, so we don't half-set the 'matches' before failing (TODO am I doing this elsewhere in :match()?)
		-- TODO w.index IS NOT GUARANTEED, if we have (x):match(W(1) + W(2) * W(3)) and add and mul have wildcardMatches
		-- in that case, you need to handle all possible sub-wildcardMatches specifically
--DEBUG(@5):print("add.wildcardMatches: testing against previous matches table...")
		for i,w in ipairs(wildcards) do
			local cmpExpr = i == 1 and matchExpr or defaultValue
--DEBUG(@5):print("add.wildcardMatches: comparing lhs "..Verbose(cmpExpr))
			if add:isa(w) then
				error"match() doesn't work with unflattened add's"
			elseif Wildcard:isa(w)
			or mul:isa(w)
			then
				-- check before going through with it
				if not cmpExpr:match(w, table(matches)) then
					return false
				end
			else
				error("found match(add(unknown))")
			end
		end
		-- finally set all matches to zero and return 'true'
		for i,w in ipairs(wildcards) do
			local cmpExpr = i == 1 and matchExpr or defaultValue
			if Wildcard:isa(w) then
--DEBUG(@5):print('add.wildcardMatches setting index '..w.index..' to '..SingleLine(i == 1 and matchExpr or defaultValue))
				-- write matches.  should already be true.
				assert(cmpExpr:match(w, matches))
				--matches[w.index] = cmpExpr
			elseif mul:isa(w) then
				-- use the state this time, so it does modify "matches"
				assert(cmpExpr:match(w, matches))
			-- elseif add.is shouldn't happen if all adds are flattened upon construction
			elseif add:isa(w) then
				error"match() doesn't work with unflattened add's"
			end
		end
		return true
	end

	for wildcards in wildcards:permutations() do
		wildcards = table(wildcards)
		if checkWildcardPermutation(wildcards, matches) then
--DEBUG(@5):print("add.wildcardMatches: success")
			return matches[1] or true, table.unpack(matches, 2, table.maxn(matches))
		end
	end
--DEBUG(@5):print("add.wildcardMatches: found no matching permutations - failing")
	return false
end


-- TODO if you keep add() constantly sorted then you can just compare element by element
function add.__eq(a,b)
	if getmetatable(a) ~= getmetatable(b) then return false end

	-- compare things order-independent, remove as you go
	a = table(a)
	b = table(b)
	for i=#a,1,-1 do
		local ai = a[i]
		-- non-commutative compare...
		if not ai.addNonCommutative then
			local j
			for _j=1,#b do
				local bj = b[_j]
				if ai == bj then
					j = _j
					break
				end
			end
			if j then
				a:remove(i)
				b:remove(j)
			end
		end
	end

	local n = #a
	if n ~= #b then return false end
	for i=1,n do
		if a[i] ~= b[i] then return false end
	end

	return true
end


add.removeIfContains = require 'symmath.commutativeRemove'

function add:reverse(soln, index)
	-- y = a_1 + ... + a_j(x) + ... + a_n
	-- => a_j(x) = y - a_1 - ... - a_j-1 - a_j+1 - ... a_n
	for k=1,#self do
		if k ~= index then
			soln = soln - self[k]:cloneIfMutable()
		end
	end
	return soln
end

function add:getRealRange()
	if self.cachedSet then return self.cachedSet end
	local I = self[1]:getRealRange()
	if I == nil then
		self.cachedSet = nil
		return nil
	end
	for i=2,#self do
		local I2 = self[i]:getRealRange()
		if I2 == nil then return nil end
		I = I + I2
	end
	self.cachedSet = I
	return self.cachedSet
end

-- lim add = add lim
function add:evaluateLimit(x, a, side)
	symmath = symmath or require 'symmath'
	return symmath.prune(
		add(
			table.mapi(self, function(xi)
				return symmath.Limit(xi, x, a, side)
			end):unpack()
		)
	)
end

--[[
this is a single term^power

TODO ... maybe all expressions should be stored in this form by default?
I think that is similar to how sympy works?
--]]
local ProdTerm = class()

function ProdTerm:init(args)
	self.term = args.term
	self.power = args.power
end

function ProdTerm:__tostring()
	symmath = symmath or require 'symmath'
	local SingleLine = symmath.export.SingleLine
	return SingleLine(self.term)..'^('..SingleLine(self.power)..')'
end
ProdTerm.__concat = string.concat


local function compare(a,b)
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	local Variable = symmath.Variable
	local Derivative = symmath.Derivative
	local Verbose = symmath.export.Verbose
	local TensorRef = symmath.Tensor.Ref


	-- -x becomes (-1)^1 * x^1 by the time we get here, so ...
	local typea = type(a)
	local typeb = type(b)
	local na = (typea == 'string' or typea == 'table') and #a or 0
	local nb = (typeb == 'string' or typeb == 'table') and #b or 0

	-- order of sorting based on class:
	-- constants
	local ca = Constant:isa(a)
	local cb = Constant:isa(b)
	if ca ~= cb then return ca end

	-- variables
	local va = Variable:isa(a)
	local vb = Variable:isa(b)
	if va and vb then
		return a.name < b.name
	end
	if va ~= vb then return va end

	-- TensorRef
	local ta = TensorRef:isa(a)
	local tb = TensorRef:isa(b)
	if ta and tb then
		-- sort by degree
		if na ~= nb then return na < nb end
		-- sort by wrapped expression
		return compare(a[1], b[1])
	end
	if ta ~= tb then return ta end

	-- derivatives
	local da = Derivative:isa(a)
	local db = Derivative:isa(b)
	if da and db then
		-- sort by derivative degree
		if na ~= nb then return na < nb end
		-- sort by derivative variable names
		for i=2,na do
			local ai = a[i]
			local bi = b[i]
			if ai ~= bi then return compare(ai, bi) end
		end
		-- sort by derivative expression
		return compare(a[1], b[1])
	end
	if da ~= db then return da end

	-- Expressions in general
	if a.name ~= b.name then return a.name < b.name end
	if na ~= nb then return na < nb end
	for i=1,na do
		local ai = a[i]
		local bi = b[i]
		if ai ~= bi then return compare(ai, bi) end
	end

	--[[
	4) functions
	5) powers
	6) non-commutative (Arrays etc) ?
	7) etc
	--]]
	local sa = Verbose(a)
	local sb = Verbose(b)
	if #sa ~= #sb then return #sa < #sb end
	return sa < sb
end


--[[
this is a multiplied collection of a1^b1 * a2^b2 * ...
--]]
local ProdList = class()

ProdList.insert = table.insert
ProdList.mapi = table.mapi
ProdList.find = table.find

function ProdList:toExpr()
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant

	local list = table.mapi(self, function(x)
		if Constant.isValue(x.power, 1) then
			return x.term
		else
			--return x.term ^ x.power:prune()
			return x.term ^ x.power:simplify()
		end
	end)

	list = list:filter(function(x)
		return not Constant.isValue(x, 1)
	end)

	list:sort(compare)
	return symmath.tableToMul(list)
end

-- pass it an element of the product list
-- returns true if all the powers are even (and positive?)
-- I'm not using this yet, but for the sake of generalizing, it would be good to switch to this
function ProdList:isSquare()
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	for i,pi in ipairs(self) do
		if
		-- [[ exclude any constants, especially the -1's
		Constant:isa(pi.term)
		--]]
		--[[ if power is 1 then treat 1^1 as an even power (i.e. anything^0)
		(
			Constant.isValue(pi.term, 1)
			and Constant.isValue(pi.power, 1)
		)
		--]]
		or (
			Constant:isa(pi.power)
			-- TODO positiveEvenInteger:contains
			and symmath.set.evenInteger:contains(pi.power)
			and pi.power.value > 0	-- I don't think any power==0's exist at this point
		) then
			-- we're an even power
		else
			return false
		end
	end
	return true
end

function ProdList:__tostring()
	if #self == 0 then return '1' end
	return table.mapi(self, tostring):concat' * '
end
ProdList.__concat = string.concat


-- for the i'th child of an add ...
-- return a list of {term=term, power=power}
local function getProductList(x)
	symmath = symmath or require 'symmath'
	local mul = symmath.op.mul
	local pow = symmath.op.pow
	local Constant = symmath.Constant

	-- get products or individual terms
	local prodList
	if mul:isa(x) then
		prodList = table(x)
	else
		prodList = table{x}
	end

	-- pick out any exponents in any of the products
	prodList = prodList:mapi(function(ch)
		if pow:isa(ch) then
			return ProdTerm{
				term = ch[1],
				power = assert(ch[2]),
			}
		else
			return ProdTerm{
				term = ch,
				power = Constant(1),
			}
		end
	end)

	local newProdList = ProdList()
	for k,x in ipairs(prodList) do
		if Constant:isa(x.term) then
			local c = x.term.value
			if c == 1 then
				-- do nothing -- remove any 1's
			elseif c == 0 then
				newProdList:insert(x)
			else
				if c < 0 then
					-- if it's a negative constant then split out the minus
					newProdList:insert(ProdTerm{
						term = Constant(-1),
						power = x.power,
					})
					c = -c
				end

				--if symmath.set.positiveInteger:contains(list[i])
				if c == math.floor(c) then
					local ppow = {}
					for _,p in ipairs(math.primeFactorization(c)) do
						ppow[p] = (ppow[p] or 0) + 1
					end
					for p,power in pairs(ppow) do
						if power == 1 then
							newProdList:insert(ProdTerm{
								term = Constant(p),
								power = x.power,
							})
						else
							newProdList:insert(ProdTerm{
								term = Constant(p),
								power = x.power * power,
							})
						end
					end
				else
					newProdList:insert(ProdTerm{
						term = Constant(c),
						power = x.power,
					})
				end
			end
		else
			newProdList:insert(x)	-- add the new term
		end
	end
	prodList = newProdList

	return prodList
end

--[[
this is a summed collection p1 + p2 + ...
where each pi is a ProdList above a1^b1 * a2^b2 * ...
--]]
local ProdLists = class()

function ProdLists:init(expr)
	for i,x in ipairs(expr) do
		self[i] = getProductList(x)
	end
end

function ProdLists:sort()
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	table.sort(self, function(a,b)
		-- [[ strip out any -1's before comparing ... which are -1^1's by now
		if #a > 0
		and Constant.isValue(a[1].power, 1)
		and Constant.isValue(a[1].term, -1)
		then
			local na = ProdList()
			for i=2,#a do
				na[i-1] = a[i]
			end
			a = na
		end
		if #b > 0
		and Constant.isValue(b[1].power, 1)
		and Constant.isValue(b[1].term, -1)
		then
			local nb = ProdList()
			for i=2,#b do
				nb[i-1] = b[i]
			end
			b = nb
		end
		--]]

		if #a ~= #b then return #a < #b end
		for i=1,#a do
			if a[i].power ~= b[i].power then return compare(a[i].power, b[i].power) end
			if a[i].term ~= b[i].term then return compare(a[i].term, b[i].term) end
		end
	end)
end

function ProdLists:toExpr()
	local expr = table.mapi(self, function(prodList)
		return prodList:toExpr()
	end)
	return #expr == 1
		and expr[1]
		or setmetatable(expr, add)
end

function ProdLists:__tostring()
	if #self == 0 then return '0' end
	return table.mapi(self, tostring):concat'  +  '
end
ProdLists.__concat = string.concat

add.rules = {
	Factor = {
		{apply = function(factor, expr)
			assert(#expr > 1)

			symmath = symmath or require 'symmath'
			local mul = symmath.op.mul
			local pow = symmath.op.pow
			local Constant = symmath.Constant


			-- [[ x*a + x*b => x * (a + b)
			-- the opposite of this is in mul:prune's applyDistribute
			-- don't leave both of them uncommented or you'll get deadlock


			-- TODO make this a part of add's interface
			-- an iterator / length operator for what terms and what powers are available.
			-- have it return constants and cache low Constant() values

			-- 1) get all terms and powers
			local prodLists = ProdLists(expr)

			-- [[ combine any matching terms
			-- TODO should this be done in the ProdLists() ctor?
			-- but without this, Platonic Solid test has simplification loops ...
			for i=1,#prodLists do
				local pi = prodLists[i]
				local found
				repeat
					found = nil
					local ni = #pi
					for j=1,ni-1 do
						local pij = assert(pi[j])
						for k=ni,j+1,-1 do
							local pik = assert(pi[k])
							if pij.term == pik.term then	-- got a nil reference error here before when it was doing [i][j] vs [i][k] ... hmm ...
								pij.power = (pij.power + pik.power):prune()
								table.remove(pi, k)
								found = true
								break
							end
						end
						if found then break end
					end
				until not found
			end
			--]]
--DEBUG(@5):print('a prodLists', prodLists)

			-- sort by prodLists[i].term, excluding all constants
			prodLists:sort()

--[[
-- maybe changing sort can fix this?
print('prodList', prodLists:toExpr(), '<br>')
for i=1,#prodLists do	-- these are added
	local prodList = prodLists[i]
	-- prodList is a list of a^b's that are mul'd together
	for j=1,#prodList do
		local pi = prodList[j]
		if symmath.set.negativeReal:contains(pi.power) then
			pi.term = pi.term
		end
	end
end
print('prodList', prodLists:toExpr(), '<br>')
--]]
--DEBUG(@5):print('c prodLists', prodLists)

			-- TODO where to put quadratic / polynomial division
			-- I should do this somewhere else, but I'll do it here for now
			-- a^2 - b^2 => (a+b) (a-b)

			--[[ searching prodLists
			if #prodLists == 2 then
				if one of the two has a -1 Constant in its product list
				if both are considered squares (i.e. other than constants, all have even powers)
				then replace them with (x + y)(x - y)
			end
			--]]
			-- [[ searching expr
			if #expr == 2 then
				if symmath.op.pow:isa(expr[1])
				and symmath.set.evenInteger:contains(expr[1][2])
				and symmath.op.mul:isa(expr[2])
				and #expr[2] == 2
				and Constant.isValue(expr[2][1], -1)
				and symmath.op.pow:isa(expr[2][2])
				and symmath.set.evenInteger:contains(expr[2][2][2])
				then
					local a = (expr[1][1] ^ (expr[1][2]/2))
					local b = (expr[2][2][1] ^ (expr[2][2][2]/2))
					return factor:apply( ((a + b) * (a - b)):prune() )
				end
			end
			-- TODO factoring higher polys ... this is just one specific case
			--]]
			-- [=[ this is duplicated in sqrt.Prune
			local function isSquarePow(x)
				return pow:isa(x) and Constant.isValue(x[2], 2)
			end
			if #expr == 3 then
				local squares = table()
				local notsquares = table()
				for i,xi in ipairs(expr) do
					(isSquarePow(xi) and squares or notsquares):insert(i)
				end
				if #squares == 2 then
					assert(#notsquares == 1)
					local a,c = expr[squares[1]], expr[squares[2]]
					local b = expr[notsquares[1]]
					if b == symmath.op.mul(2, a[1], c[1]) then
						return factor:apply( ((a[1] + c[1]) * (a[1] + c[1])):prune() )
					end
					if b == symmath.op.mul(Constant(-2), a[1], c[1]) then
						return factor:apply( ((a[1] - c[1]) * (a[1] - c[1])):prune() )
					end
				end
			end
			--]=]
--DEBUG(@5):print('d prodLists', prodLists)


			-- rebuild exprs accordingly
			assert(#prodLists == #expr)
			expr = prodLists:toExpr()
			assert(#expr > 1)

--DEBUG(@5):print('e prodLists', prodLists)


-- without this (y-x)/(x-y) doesn't simplify to -1
-- but with this our simplification takes forever
--[=[
			local minusOneIndexes = table.mapi(prodLists, function(pj,j)
				return pj:find(nil, function(x)
					return Constant.isValue(x.term, -1)
				end)
			end)
			-- instead of only factoring the -1 out of the constant
			-- also add double the -1 to the rest of the terms (which should equate to being positive)
			-- so that signs don't mess with simplifying division
			-- ex: -1+x => (-1)*1+(-1)*(-1)*x => -1*(1+(-1)*x) => -1*(1-x)
			for i=1,#expr do
				if (
					--if expr[i] has a leading negative constant
					#prodLists[i] > 0
					-- [[ old - expect a leading constant
					and Constant:isa(prodLists[i][1].term)
					and prodLists[i][1].term.value < 0
					--]]
					--[[ alternative to old, but doesn't work like the old does
					and symmath.set.negativeReal:contains(prodLists[i][1])
					--]]
					--[[ new - look through all constants
					-- TODO enabling this breaks things, but the code above is inserting Constant(-1) not in front, so the old check would miss it?
					and prodLists[i]:find(nil, function(x) return Constant.isValue(x, -1) end)
					--]]
				)
				--and symmath.set.negativeReal:contains(expr)
				--and not symmath.set.positiveReal:contains(expr)
				then
					-- only factoring -1's out of i+1 causes us to choose which -1's to factor out based on whatever sorting prodList used
					--  and that's what allows (x-1)/(1-x) => (-1+x)/(1-x) => ((-1)*1 + (-1)^2*x) / (1 + (-1)*x) => ((-1)*(1 + (-1)*x)) / (1 + (-1)*x) => -1
					for j=i+1,#expr do
						-- find a -1
						local index = minusOneIndexes[j]
						if index then
							--prodLists[j][index].power = (prodLists[j][index].power + 2):prune()
							prodLists[j][index].power = (prodLists[j][index].power + 2):simplify()
						else
							-- insert two copies so that one can be factored out
							-- TODO, instead of squaring it, raise it to 2x the power of the constant's separated -1^x
							prodLists[j]:insert(ProdTerm{
								term = Constant(-1),
								power = Constant(2),
							})
						end
					end
				end
			end
--]=]

--DEBUG(@5):print('f prodLists', prodLists)
			-- 2) find smallest set of common terms

			local minProds = setmetatable(prodLists[1]:mapi(function(prod)
				return ProdTerm{
					term = prod.term,
					power = 1,
				}
			end), ProdList)
			for i=2,#prodLists do
				for j=#minProds,1,-1 do
					local found = false
					for k=1,#prodLists[i] do
						if minProds[j].term == prodLists[i][k].term then
							found = true
							break
						end
					end
					if not found then
						table.remove(minProds, j)
					end
				end
			end
--DEBUG(@5):print('minProds', minProds)

			-- found no common factors -- don't touch the expression
			if #minProds == 0 then
				--return
				-- or do touch, return the sorted expression
				-- this lets -x+y == y-x
				return expr
				-- or do you need to rebuild it?
				--return prodLists:toExpr()
			end

			local prune = symmath.prune
			local div = symmath.op.div
			for i,minProd in ipairs(minProds) do
				-- 3) find abs min power of all terms
				local minPower
				local foundNonConstMinPower
				for i=1,#prodLists do
					for j=1,#prodLists[i] do
						if prodLists[i][j].term == minProd.term then
							-- TODO isConstant ?
							-- or should I just handle Constant and div-of-Constant ?
							if Constant:isa(prodLists[i][j].power)
							or (
								div:isa(prodLists[i][j].power)
								and Constant:isa(prodLists[i][j].power[1])
								and Constant:isa(prodLists[i][j].power[2])
							)
							-- TODO also sqrts, adds, blah blah etc - any expression whose leafs are Constants
							-- (which means who does not contain any variables?)
							then
								if minPower == nil then
									minPower = symmath.clone(prodLists[i][j].power)
								else
									local new = prodLists[i][j].power
									if new:le(minPower):isTrue() then
										minPower = new
									end
								end
							else	-- if it is variable then ... just use the ... first?
								if not minPower then
									minPower = prodLists[i][j].power
									foundNonConstMinPower = true
									break
								end
							end
						end
					end
					if foundNonConstMinPower then break end
				end
				minProds[i].power = minPower
				-- 4) factor them out
				for i=1,#prodLists do
					for j=1,#prodLists[i] do
						if prodLists[i][j].term == minProd.term then
							prodLists[i][j].power = prune:apply(prodLists[i][j].power - minPower)
							-- just factor out the first encounter within a mul
							-- in case there are repeated matching terms
							break
						end
					end
				end
			end
--DEBUG(@5):print('minProds with powers', minProds)

			-- start with all the factored-out terms
			-- [[ old
			local terms = minProds:mapi(function(minProd,i) return minProd.term ^ minProd.power end)
			--]]
			--[[ new ... causes simplification loops
			local terms = table()
			for i=1,#minProds do
				if Constant.isNumber(minProds[i].power)
				and minProds[i].power > 0
				then
					terms:insert(minProds[i].term ^ minProds[i].power)
				end
			end
			--]]

			-- [[
			-- remove any product lists that are to the zero power
			-- NOTICE this will put prodLists[] out of sync with expr[]
			for i=#prodLists,1,-1 do	-- here's our adds
				local pli = prodLists[i]
				for j=#pli,1,-1 do		-- here's our muls
					local plij = pli[j]
					if Constant.isValue(plij.power, 0) then
						table.remove(pli,j)
					end
				end
			end
			--]]
--DEBUG(@5):print('prodLists', prodLists)
			-- then add what's left of the original sum
			local lastTerm = prodLists:toExpr()

			-- [[
			-- if anything was factored out then try the quadratic rules on what's left
			if #terms > 0 then
				-- prune is still needed here -- it looks like only to recombine constants (and move them to the left of the muls) before the quadratic testing at the top of Factor is run
				lastTerm = prune(lastTerm)
-- causing stack overflow:
--				lastTerm = factor(lastTerm)
			end
			--]]

			terms:insert(lastTerm)

			local result = #terms == 1 and terms[1] or mul(terms:unpack())

--DEBUG(@5):print('returning result')
--DEBUG(@5):print(result)
			-- prune needs to convert things to div add mul
			-- but factor converted them to mul add (div first or last?)
			-- so don't call prune here, or it will undo what we just did
			--return prune(result)
			return result
		end},
	},

	Prune = {
		{flatten = function(prune, expr, ...)
--[=[ old version
			-- flatten additions
			-- (x + y) + z => x + y + z
			for i=#expr,1,-1 do
				local ch = expr[i]
				if add:isa(ch) then
					expr = expr:clone()
					-- this looks like a job for splice ...
					table.remove(expr, i)
					for j=#ch,1,-1 do
						local chch = assert(ch[j])
						table.insert(expr, i, chch)
					end
					return prune:apply(expr)
				end
			end
--]=]
-- [=[ new version
			-- flatten additions
			-- (x + y) + z => x + y + z
			local flattenArgs
			for i,ch in ipairs(expr) do
				if add:isa(ch) then
					if not flattenArgs then
						flattenArgs = table.sub(expr, 1, i-1)
					end
					flattenArgs:append(ch)
				else
					if flattenArgs then
						flattenArgs:insert(ch)
					--else it will get appended in the table.sub
					-- ... or never, if no add->add's exist
					end
				end
			end
			if flattenArgs then
				return prune:apply(setmetatable(flattenArgs, add))
			end
--]=]
		end},

		-- TODO is this technically valid? inf + c = inf?
		-- or is it only valid in the context of a limit? inf + c = invalid, lim(x+c, x, inf) = inf
		-- also TODO distinct reals vs extendedReals
		{handleInfAndInvalid = function(prune, expr, ...)
			symmath = symmath or require 'symmath'
				-- anything + invalid is invalid
			for i=1,#expr do
				if expr[i] == symmath.invalid then
					return symmath.invalid
				end
			end
			-- inf + -inf is invalid
			for i=1,#expr do
				if expr[i] == symmath.inf then
					for j=1,#expr do
						if j ~= i then
							if expr[j] == symmath.Constant(-1) * symmath.inf then
								return symmath.invalid
							end
						end
					end
				end
			end
			-- inf + anything else is inf
			for i=1,#expr do
				if expr[i] == symmath.inf then
					return symmath.inf
				end
			end

		end},

		-- move all constants to the left hand side and combine them
		-- c1 + x1 + c2 + x2 => (c1+c2) + x1 + x2
		{combineConstants = function(prune, expr, ...)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant

			local cval	-- nil means not cloned yet
			for i=#expr,2,-1 do
				if Constant:isa(expr[i]) then
					if not cval then
						cval = 0
						expr = expr:clone()
					end
					cval = cval + table.remove(expr, i).value
				end
			end

			-- cval is set and expr is cloned if we found any constants not in the far left place
			if cval then
				if Constant:isa(expr[1]) then
					cval = cval + expr[1].value
					if cval == 0 then
						table.remove(expr, 1)
						if #expr == 0 then
							return Constant(0)
						end
					else
						expr[1] = Constant(cval)
					end
				else
					if cval ~= 0 then
						table.insert(expr, 1, Constant(cval))
					end
				end
				assert(#expr > 0)
				if #expr == 1 then
					return expr[1]	-- no need to prune:apply since we applied to all children first.  the only way this isn't a previous child that hasn't been modified is if it is a newly created Constant, in which case what can prune() do?
				else
					return prune:apply(expr)
				end

			-- haven't found a Constant elsewhere, but there's a Constant(0) in the 1st entry ...
			else
				assert(#expr > 1)
				if Constant.isValue(expr[1], 0) then
					-- if we only have two children: 0 + x, return x, no need to clone
					if #expr == 2 then
						return expr[2]
					end
					assert(#expr > 2)
					expr = expr:clone()	-- haven't cloned yet, so clone now
					table.remove(expr, 1)	-- and remove the Constant(0) child
					-- #expr must be >1, so no need to avoid add()'s with only one child
					return prune:apply(expr)
				end
			end
		end},

		{['Array.pruneAdd'] = function(prune, expr, ...)

--[=[ old version
			-- any overloaded subclass simplification
			-- specifically used for vector/matrix addition
			-- only operate on neighboring elements - don't assume commutativitiy, and that we can exchange elements to be arbitrary neighbors
			for i=#expr,2,-1 do
				local rhs = expr[i]
				local lhs = expr[i-1]

				local result
				if lhs.pruneAdd then
					result = lhs.pruneAdd(lhs, rhs)
				elseif rhs.pruneAdd then
					result = rhs.pruneAdd(lhs, rhs)
				end
				if result then
					table.remove(expr, i)
					expr[i-1] = result
					if #expr == 1 then
						expr = expr[1]
					end
					return prune:apply(expr)
				end
			end
--]=]
-- :[=[ new version
			-- any overloaded subclass simplification
			-- specifically used for vector/matrix addition
			-- only operate on neighboring elements - don't assume commutativitiy, and that we can exchange elements to be arbitrary neighbors
			for i=#expr,2,-1 do
				local rhs = expr[i]
				local lhs = expr[i-1]

				local result
				if lhs.pruneAdd then
					-- [[ original
					result = lhs.pruneAdd(lhs, rhs)
					--]]
					--[[tempted to leave this here, even though it slows things down ...
					local fail
					xpcall(function()
						result = lhs.pruneAdd(lhs, rhs)
					end, function(err)
						io.stderr:write(err..'\n'..debug.traceback()..'\n')
						io.stderr:write('lhs =\n'..tostring(lhs)..'\n')
						io.stderr:write('rhs =\n'..tostring(rhs)..'\n')
						fail = true
					end)
					if fail then error'here' end
					--]]
				elseif rhs.pruneAdd then
					result = rhs.pruneAdd(lhs, rhs)
				end
				if result then
					expr = expr:shallowCopy()
					table.remove(expr, i)
					expr[i-1] = result
					if #expr == 1 then
						expr = expr[1]
					end
					return prune:apply(expr)
				end
			end
--]=]
		end},

		{combineMultipliedConstants = function(prune, expr, ...)
			symmath = symmath or require 'symmath'
			local tableCommutativeEqual = symmath.tableCommutativeEqual
			local Constant = symmath.Constant
			local mul = symmath.op.mul
			-- [[ x * c1 + x * c2 => x * (c1 + c2) ... for constants
			do
				local muls = table()
				local nonMuls = table()
				for i,x in ipairs(expr) do
					if mul:isa(x) then
						muls:insert(x)
					else
						nonMuls:insert(x)
					end
				end
				if #muls > 1 then	-- we have more than one multiplication going on ... see if we can combine them
					local baseConst = 0
					local baseTerms
					local didntFind
					for _,mul in ipairs(muls) do
						local nonConstTerms = table.filter(mul, function(x,k)
							if not Constant.isNumber(k) then return end
							return not Constant:isa(x)
						end)
						if not baseTerms then
							baseTerms = nonConstTerms
						else
							if not tableCommutativeEqual(baseTerms, nonConstTerms) then
								didntFind = true
								break
							end
						end
						local constTerms = table.filter(mul, function(x,k)
							if not Constant.isNumber(k) then return end
							return Constant:isa(x)
						end)

						local thisConst = 1
						for _,const in ipairs(constTerms) do
							thisConst = thisConst * const.value
						end

						baseConst = baseConst + thisConst
					end
					if not didntFind then
						local terms = table{baseConst, baseTerms:unpack()}
						assert(#terms > 0)	-- at least baseConst should exist
						if #terms == 1 then
							terms = terms[1]
						else
							terms = mul(terms:unpack())
						end

						local expr
						if #nonMuls == 0 then
							expr = terms
						else
							expr = add(terms, nonMuls:unpack())
						end

						return prune:apply(expr)
					end
				end
			end
			--]]
		end},

		{flattenAddMul = function(prune, expr, ...)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local mul = symmath.op.mul
			local div = symmath.op.div
			local pow = symmath.op.pow

			local function toTerms(x)
				local t = table()
				if mul:isa(x) then
					t:append(x)
				else
					t:insert(x)
				end

				for i=#t,1,-1 do
					local y = t[i]
					-- break down primes/sqrts here
					-- c^((2n+1)/2) => c^n c^(1/2)
					if pow:isa(y)
					and Constant:isa(y[1])
					and div:isa(y[2])
					and Constant:isa(y[2][1])
					and y[2][1].value > 1
					and y[2][1].value < 20	-- upper bound?
					and y[2][1].value % 2 == 1
					and Constant.isValue(y[2][2], 2)
					then
						local n = (y[2][1].value - 1) / 2
						table.remove(t, i)
						table.insert(t, i, y[1] ^ div(1,2))
						table.insert(t, i, Constant(y[1].value ^ n))
					end
				end

				return t
			end

			-- TODO shouldn't this be regardless of the outer add ?
			-- turn any a + (b * (c + d)) => a + (b * c) + (b * d)
			-- [[ if any two children are muls,
			--    and they have all children in common (with the exception of any constants)
			--  then combine them, and combine their constants
			-- x * c1 + x * c2 => x * (c1 + c2) (for c1,c2 constants)
			for i=1,#expr-1 do
				local termsI = toTerms(expr[i])
				for j=i+1,#expr do
					local termsJ = toTerms(expr[j])

					local fail
					local commonTerms = table()
					local constI
					for _,ch in ipairs(termsI) do
						if not termsJ:find(ch) then
							if Constant:isa(ch) then
								if not constI then
									constI = ch.value
								else
									constI = constI * ch.value
								end
							else
								fail = true
								break
							end
						else
							commonTerms:insert(ch)
						end
					end
					if not constI then constI = 1 end

					local constJ
					if not fail then
						for _,ch in ipairs(termsJ) do
							if not termsI:find(ch) then
								if Constant:isa(ch) then
									if not constJ then
										constJ = ch.value
									else
										constJ = constJ * ch.value
									end
								else
									fail = true
									break
								end
							end
						end
					end
					if not constJ then constJ = 1 end

					if not fail then
						expr = expr:shallowCopy()
						table.remove(expr, j)
						if #commonTerms == 0 then
							expr[i] = Constant(constI + constJ)
						else
							expr[i] = mul(Constant(constI + constJ), table.unpack(commonTerms))
						end
						if #expr == 1 then expr = expr[1] end
						return prune:apply(expr)
					end
				end
			end
			--]]
		end},

		{factorOutDivs = function(prune, expr, ...)
			symmath = symmath or require 'symmath'
			local div = symmath.op.div

			--[[ factor out divs ...
			local denom
			local denomIndex
			for i,x in ipairs(expr) do
				if not div:isa(x) then
					denom = nil
					break
				else
					if not denom then
						denom = x[2]
						denomIndex = i
					else
						if x[2] ~= denom then
							denom = nil
							break
						end
					end
				end
			end
			if denom then
				table.remove(expr, denomIndex)
				return prune:apply(expr / denom)
			end
			--]]

			-- [[ divs: c + a/b => (c * b + a) / b
			for i,x in ipairs(expr) do
				if div:isa(x) then
					assert(#x == 2)
					local a,b = table.unpack(x)
					expr = expr:shallowCopy()
					table.remove(expr, i)
					if #expr == 1 then expr = expr[1] end
					expr = (expr * b + a) / b
					--return expr	-- runs much faster (5s vs 60s) without the final prune:apply, but doesn't finish simplifying ...
					return prune:apply(expr)
				end
			end
			--]]
			--[[ divs all at once: a/b + c/d + e => (d*a + b*d + b*d*e) / (b*d)
			-- much faster when you remove the final prune:apply() (5s vs 60s) but doesn't seem to finish simplifying all cases
			local denom
			for i,x in ipairs(expr) do
				if div:isa(x) then
					local xdenom = x[2]
					denom = denom and (denom * xdenom) or xdenom
					expr[i] = x[1]
					for j,y in ipairs(expr) do
						if j ~= i then
							if div:isa(expr[j]) then
								expr[j][1] = expr[j][1] * xdenom
							else
								expr[j] = expr[j] * xdenom
							end
						end
					end
				end
			end
			if denom then
				return expr / denom
				-- this is usually a recursive call, but that seems to be pretty slow, due to something in op.div.rules.Prune maybe?
				--return prune:apply(expr / denom)
			end
			--]]
		end},

		--[=[ trigonometry identities
		-- cos(theta)^2 + sin(theta)^2 => 1
		-- TODO first get a working factor() function
		-- then replace all nodes of cos^2 + sin^2 with 1
		-- ... or of cos^2 with 1 - sin^2 and let the rest cancel out  (best to operate on one function rather than two)
		--  (that 2nd step possibly in a separate simplifyTrig() function of its own?)
		{apply = function(prune, expr, ...)
			local Constant = require 'symmath.Constant'
			local mul = require 'symmath.op.mul'
			local pow = require 'symmath.op.pow'

			do
				local cos = require 'symmath.cos'
				local sin = require 'symmath.sin'
				local Function = require 'symmath.Function'

				local function checkAdd(ch)
					local cosAngle, sinAngle
					local cosIndex, sinIndex
					for i,x in ipairs(ch) do

						if pow:isa(x)
						and Function:isa(x[1])
						and Constant.isValue(x[2], 2)
						then
							if cos:isa(x[1]) then
								if sinAngle then
									if sinAngle == x[1][1] then
										-- then remove sine and cosine and replace with a '1' and set modified
										table.remove(expr, i)	-- remove largest index first
										expr[sinIndex] = Constant(1)
										if #expr == 1 then expr = expr[1] end
										return expr
									end
								else
									cosIndex = i
									cosAngle = x[1][1]
								end
							elseif sin:isa(x[1]) then
								if cosAngle then
									if cosAngle == x[1][1] then
										table.remove(expr, i)
										expr[cosIndex] = Constant(1)
										if #expr == 1 then expr = expr[1] end
										return expr
									end
								else
									sinIndex = i
									sinAngle = x[1][1]
								end
							end
						end
					end
				end

				--[[ not sure what this special case was doing here ...
				do
					local cos = require 'symmath.cos'
					local sin = require 'symmath.sin'
					local Function = require 'symmath.Function'

					-- using factor outright causes simplification loops ...
					-- how about only using it if we find a cos or a sin in our tree?
					local foundTrig = false
					require 'symmath.map'(expr, function(node)
						if cos:isa(node) or sin:isa(node) then
							foundTrig = true
						end
					end)

					if foundTrig then
						local result = checkAdd(expr)
						if result then
							return prune:apply(result)
						end

						-- this is factoring ... and pruning ...
						-- such that it is recursively calling this function for its simplification
						local f = require 'symmath.factor'(expr)
						if f then
							return f
						end
					end
				end
				--]]
				--[[
				if mul:isa(f) then	-- should always be a mul unless there was nothing to factor
					for _,ch in ipairs(f) do
						if add:isa(ch) then
							local result = checkAdd(ch)
							if result then
								return prune:apply(result)
							end
						end
					end
				end
				--]]
			end
		end},
		--]=]

		-- log(a) + log(b) = log(ab)
		{logMul = function(prune, expr)
			symmath = symmath or require 'symmath'
			local found
			local log = symmath.log
			for i=#expr-1,1,-1 do
				local a = expr[i]
				for j=#expr,i+1,-1 do
					local b = expr[j]
					if log:isa(a) and log:isa(b) then
						if not found then
							expr = expr:shallowCopy()
							found = true
						end
						table.remove(expr, j)
						expr[i] = log(a[1] * b[1])
					end
				end
			end
			if #expr == 1 then expr = expr[1] end
			if found then return expr end
		end},
	},

	Tidy = {

		{trig = function(tidy, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local cos = symmath.cos
			local sin = symmath.sin
			local Wildcard = symmath.Wildcard

			-- 1 + -1 * cos(x)^2 => sin(x)^2
			-- this form isn't used by the time this code is reached
			local theta = expr:match(1 + -1 * cos(Wildcard(1))^2)
			if theta then return sin(theta)^2 end

			-- but this form is:
			-- 1 + -(cos(x)^2) => sin(x)^2
			local theta = expr:match(1 + -cos(Wildcard(1))^2)
			if theta then return sin(theta)^2 end

			-- -(1) + cos(x)^2 => -sin(x)^2
			local theta = expr:match(-Constant(1) + cos(Wildcard(1))^2)
			if theta then return -sin(theta)^2 end
		end},

--[[
		-- but if I do this then the next == will fail, since my immediately replacement of sub(a,b) with add(a,unm(b)) was to fix == ...
		-- so a better fix would be just changing the output?
		{apply = function(tidy, expr)
			symmath = symmath or require 'symmath'
print('op.add.rules.Tidy.apply with', symmath.Verbose(expr))
			local unm = symmath.op.unm
			for i=1,#expr-1 do
				-- x + -y => x - y
				if unm:isa(expr[i+1]) then
--[=[ old
					local a = table.remove(expr, i)
					local b = table.remove(expr, i)[1]
					assert(a)
					assert(b)
					table.insert(expr, i, a - b)

					assert(#expr > 0)
					if #expr == 1 then
						expr = expr[1]
					end
					assert(#expr > 1)
					return tidy:apply(expr)
--]=]
-- [=[ new ... not working?
					expr = expr:shallowCopy()
					local a = table.remove(expr, i)
					assert(a)
					local b = table.remove(expr, i)[1]
					assert(b)
					table.insert(expr, i, symmath.op.sub(a, b))
					assert(#expr > 0)
					if #expr == 1 then
						return expr[1]
					end
					assert(#expr > 1)
					return tidy:apply(expr)
--]=]
				end
			end
		end},
--]]
	},
}

return add
