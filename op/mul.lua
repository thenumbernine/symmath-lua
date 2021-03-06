local class = require 'ext.class'
local table = require 'ext.table'
local Binary = require 'symmath.op.Binary'
local symmath

local mul = class(Binary)
mul.implicitName = true
mul.precedence = 3
mul.name = '*'

--[[
-- auto flatten any muls
-- this is useful for find/replace, since otherwise the API user has to simplify() everything to get it to match what the CAS produces
-- the problem is, this modifies in-place, which breaks our cardinal rule (and a lot of our code)
function mul:init(...)
	mul.super.init(self, ...)
	self:flatten()
end
--]]

function mul:flatten()
	for i=#self,1,-1 do
		if mul:isa(self[i]) then
			local x = table.remove(self, i)
			for j=#x,1,-1 do
				table.insert(self, i, x[j]:clone())
			end
		end
	end
	return self
end

function mul:flattenAndClone()
	for i=#self,1,-1 do
		local ch = self[i]
		if mul:isa(ch) then
			local expr = {table.unpack(self)}
			table.remove(expr, i)
			for j=#ch,1,-1 do
				local chch = ch[j]
				table.insert(expr, i, chch)
			end
			return mul(table.unpack(expr))
		end
	end
end

function mul:isFlattened()
	for i,ch in ipairs(self) do
		if mul:isa(ch) then return false end
	end
	return true
end

function mul:evaluateDerivative(deriv, ...)
	symmath = symmath or require 'symmath'
	local add = symmath.op.add
	local sums = table()
	for i=1,#self do
		local terms = table()
		for j=1,#self do
			if i == j then
				terms:insert(deriv(self[j]:clone(), ...))
			else
				terms:insert(self[j]:clone())
			end
		end
		if #terms == 1 then
			sums:insert(terms[1])
		else
			sums:insert(mul(terms:unpack()))
		end
	end
	if #sums == 1 then
		return sums[1]
	else
		return add(sums:unpack())
	end
end

mul.removeIfContains = require 'symmath.commutativeRemove'

--local function print(...) return printbr(...) end

-- now that we've got matrix multilpication, this becomes more difficult...
-- non-commutative objects (matrices) need to be compared in-order
-- commutative objects can be compared in any order
function mul.match(a, b, matches)
	symmath = symmath or require 'symmath'
	local Wildcard = symmath.Wildcard
	local Constant = symmath.Constant
local SingleLine = symmath.export.SingleLine
local Verbose = symmath.export.Verbose
--print("mul.match(a="..Verbose(a)..", b="..Verbose(b)..", matches={"..(matches or table()):mapi(Verbose):concat', '..'}) begin')

	matches = matches or table()
	-- if 'b' is a mul then fall through
	-- this part is only for wildcard matching of the whole expression
	if not mul:isa(b)	-- if the wildcard is a mul then we want to test it here
	and b.wildcardMatches
	then
		if not b:wildcardMatches(a, matches) then return false end
--print(" matching entire expr "..SingleLine(b).." to "..SingleLine(a))
		return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
	end
	if getmetatable(a) ~= getmetatable(b) then return false end

	-- NOTICE, this shallow copy means that the metatables are lost, so don't use "a" or "b" as expressions (unless you reset its metatable)
	local a = table(a)
	local b = table(b)
	
	-- compare things order-independent, remove as you go
	-- skip wildcards, do those last
	for i=#a,1,-1 do
		local ai = a[i]
		-- non-commutative compare...
		if not ai.mulNonCommutative then
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
--print(' mul.match: removing matched terms...')
--print(a[i])
--print(b[j])
				a:remove(i)
				b:remove(j)
			end
		end
	end

--print("mul.match: what's left after matching commutative non-wildcards:")
--print('a:', a:mapi(SingleLine):concat', ')
--print('b:', b:mapi(SingleLine):concat', ')

	-- now compare what's left in-order (since it's non-commutative)
	-- skip wildcards, do those last
	local function checkWhatsLeft(a, b, matches, indent)
indent=(indent or 0) + 1
local tab = (' '):rep(indent)
		-- save the original here
		-- upon success, merge the new matches back into the original argument
		local origMatches = matches
		matches = matches or table()
		a = table(a)
		b = table(b)
		
--print(tab.."checking match of what's left with "..#a.." elements")

		if #a == 0 and #b == 0 then
--print(tab.."matches - returning true")
			return matches[1] or true, table.unpack(matches, 2, table.maxn(matches))
		end
		
		-- #a == 0 is fine if b is full of nothing but wildcards
		if #b == 0 and #a > 0 then
--print(tab.."has remaining elements -- returning false")
			return false
		end
		
		-- TODO bi isn't necessarily a wildcard -- it could be an 'mulNonCommutative' term (though nothing does this for multiplication yet)
		if #a == 0 and #b ~= 0 then
			-- TODO verify that the matches are equal
			for _,bi in ipairs(b) do
				if not Wildcard:isa(bi) then
--print(tab.."expected bi to be a Wildcard, found "..SingleLine(bi))
					return false
				end
				if bi.atLeast and bi.atLeast > 0 then
--print(tab.."remaining Wildcard expected an expression when none are left, failing")
					return false
				end
				if matches[bi.index] then
--print(tab.."matches["..bi.index.."] tried to set to Constant(1), but it already exists as "..SingleLine(matches[bi.index]).." -- failing")
					if matches[bi.index] ~= Constant(1) then
						return false
					end
				else
--print(tab.."setting matches["..bi.index.."] to Constant(1)")
					matches[bi.index] = Constant(1)
				end
			end
		end
		if not Wildcard:isa(b[1]) then
			local a1 = a:remove(1)
			local b1 = b:remove(1)

--print(tab.."isn't a wildcard -- recursive call of match on what's left")
			-- hmm, what if there's a sub-expression that has wildcard
			-- then we need matches
			-- then we need to push/pop matches
		
			local firstsubmatch = table()
			if not a1:match(b1, firstsubmatch) then
--print(tab.."first match didn't match - failing")
				return false
			end
		
			for i=1,table.maxn(firstsubmatch) do
				if firstsubmatch[i] ~= nil then
					if matches[i] ~= nil then
						if matches[i] ~= firstsubmatch[i] then
--print(tab.."first submatches don't match previous matches - index "..i.." "..SingleLine(matches[i]).." vs "..SingleLine(firstsubmatch[i]).." - failing")
							return false
						end
					else
--print(tab.."index "..b.index)
--print(tab.."a1: "..SingleLine(a1))
--print(tab.."a: "..a:mapi(SingleLine):concat', ')
--print(tab.."matching mul subexpr from first match "..SingleLine(a1).." index "..b.index.." to "..a:mapi(SingleLine):concat', ')
						matches[i] = firstsubmatch[i]
					end
				end
			end


			local restsubmatch = table()
			if not checkWhatsLeft(a, b, restsubmatch, indent) then
--print(tab.."first match didn't match - failing")
				return false
			end

			for i=1,table.maxn(restsubmatch) do
				if restsubmatch[i] ~= nil then
					if matches[i] ~= nil then
						if matches[i] ~= restsubmatch[i] then
--print(tab.."first submatches don't match previous matches - index "..i.." "..SingleLine(matches[i]).." vs "..SingleLine(firstsubmatch[i]).." - failing")
							return false
						end
					else
--print(tab.."matching mul subexpr from first match "..SingleLine(a1).." index "..b.index.." to "..a:mapi(SingleLine):concat', ')
						matches[i] = restsubmatch[i]
					end
				end
			end

			-- overlay match matches on what we have already matched so far
			-- also write them back to the original argument since we are returning true
			for k,v in pairs(matches) do origMatches[k] = v end
			return matches[1] or true, table.unpack(matches, 2, table.maxn(matches))
		end

--print(tab.."before checking remaining terms, our matches is: "..table.mapi(matches, SingleLine):concat', ')

		-- now if we have a wildcard ... try all 0-n possible matches of it
		local b1 = b:remove(1)
		for matchSize=math.min(#a, b1.atMost or math.huge),(b1.atLeast or 0),-1 do
--print(tab.."checking matches of size "..matchSize)
			for a in a:permutations() do
				a = table(a)
--print(tab.."checking a permutation "..a:mapi(SingleLine):concat', ')
			
				local b1match = matchSize == 0 and Constant(1)
					or matchSize == 1 and a[1]
					or setmetatable(a:sub(1, matchSize), mul)
--print(tab.."b1match "..SingleLine(b1match))
				local matchesForThisSize = table(matches)
--print(tab.."matchesForThisSize["..b1.index.."] was "..(matchesForThisSize[b1.index] and SingleLine(matchesForThisSize[b1.index]) or 'nil'))
				-- this is going to get into a situation of comparing all possible permutations of what's left
				-- TODO get rid of this whole recursion system, and just use a permutation iterator
				-- then keep trying to match wildcards against what is left until things work
				-- you know, with nested wildcard/nonwildcards, we might as well just do this for everything.
				if b1match:match(b1, matchesForThisSize) then
--print(tab.."matchesForThisSize["..b1.index.."] is now "..SingleLine(matchesForThisSize[b1.index]))
					local suba = a:sub(matchSize+1)
--print(tab.."calling recursively on "..#suba.." terms: "..table.mapi(suba, SingleLine):concat', ')			
					local didMatch = checkWhatsLeft(suba, b, matchesForThisSize, indent)
--print(tab.."returned results from the sub-checkWhatsLeft : "..table.mapi(results, SingleLine):concat', ')
					if didMatch then
--print(tab.."returning that list for matchSize="..matchSize.."...")
						-- also write them back to the original argument since we are returning true
						for k,v in pairs(matchesForThisSize) do origMatches[k] = v end
						return matchesForThisSize[1] or true, table.unpack(matchesForThisSize, 2, table.maxn(matchesForThisSize))
					end
--print(tab.."continuing...")
				else
--print(tab..Verbose(b1)..':match('..SingleLine(b1match)..') failed')
--print(tab.."the next wildcard had already been matched to "..SingleLine(matchesForThisSize[b1.index]).." when we tried to match it to "..SingleLine(b1match))
				end
				-- otherwise keep checking
			end
		end
		-- all sized matches failed? return false
--print(tab.."all sized matches failed - failing")
		return false
	end
	
	-- now what's left in b[i] should all be wildcards
	-- we just have to assign them between the a's
	-- but if we want mul match to return wildcards of +0 then we can't just rely on a 1-or-more rule
	-- for that reason,
	
	return checkWhatsLeft(a,b, matches)
	--return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
end

	-- copy of op/add.wildcardMatches, just like match()
function mul:wildcardMatches(a, matches)
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	local Wildcard = symmath.Wildcard
	local add = symmath.op.add
local SingleLine = symmath.export.SingleLine
local Verbose = symmath.export.Verbose
--print("mul.wildcardMatches(self="..Verbose(self)..", a="..Verbose(a)..", matches={"..matches:mapi(Verbose):concat', '..'})')

	-- TODO move this to Expression
	local function find(expr, lookfor)
		if lookfor(expr) then return true end
		local found
		expr:map(function(x)
			if lookfor(x) then
				found = true
			end
		end)
		return found
	end
	
	-- 'a' is the 'a' in Expression.match(a,b)
	-- 'b' is 'self'
	local nonWildcards = table()
	local wildcards = table()
	for _,w in ipairs(self) do
		-- TODO what about when add/mul have no sub-wildcards?
		if w.wildcardMatches
		and find(w, function(x) return Wildcard:isa(x) end)
		then
			wildcards:insert(w)
		else
			nonWildcards:insert(w)
		end
	end

--print("mul.wildcardMatches children: "..table.mapi(self, Verbose):concat', ')
--print("mul.wildcardMatches wildcard children: "..table.mapi(wildcards, Verbose):concat', ')
--print("mul.wildcardMatches non-wildcard children: "..table.mapi(nonWildcards, Verbose):concat', ')

	-- Constant(0):match(2 * Wildcard(1))
	-- 2 is a non-wildcard, Wildcard(1) is a wildcard
	-- but as long as we're inside mul, we just need to match a wildcard to 0
	if Constant.isValue(a, 0) 
	-- make sure we have a single wildcard in the mix 
	and (#nonWildcards == 0 or #wildcards > 0)
	then
		local zeroMatches = table(matches)
		local failed
		-- make sure the matches can match to zero (i.e. no 'dependsOn=x')
		for _,w in ipairs(wildcards) do
			if not a:match(w, zeroMatches) then 
				failed = true
				break
			else
--print("mul.wildcardMatches did match "..a.." to "..w.." with matches "..table.map(zeroMatches, function(v,k,t) return k..'='..v, #t+1 end):concat', ')
			end
		end
		if not failed then
			-- wildcardMatches has to write back to 'matches'
			for k,v in pairs(zeroMatches) do matches[k] = v end
			return matches[1] or true, table.unpack(matches, 2, table.maxn(matches))
		end
		-- else if we failed then fall through
		-- and most likely fail in the next 'return false'
	end

	if #nonWildcards > 1 then
--print("mul.wildcardMatches too many non-wildcards - failing")
		return false
	end

	local defaultValue = Constant(1)
	local matchExpr = a
	if #nonWildcards == 1 then
--print("mul.wildcardMatches matchExpr "..require 'symmath.export.SingleLine'(a))
		-- TODO what if we are doing x:match(W{1,atLeast=1} * W{2}) ?
		if not a:match(nonWildcards[1], matches) then
--print("mul.wildcardMatches single remaining mul sub-term didn't match first non-wildcard - failing")
			return false
		end
		-- a matches nonWildcards[1]
		matchExpr = defaultValue
	end

	-- if any of these wildcards needed a term then fail
	-- (that will be handled in the mul.match fallthrough
	--  which is why mul.match should not call this -- only other non-mul Expressions' .match())			
	local totalAtLeast = 0
	for _,w in ipairs(wildcards) do
		if w.atLeast and w.atLeast > 0 then
			totalAtLeast = totalAtLeast + w.atLeast
			if totalAtLeast > 1 then
--print("mul.wildcardMatches: wildcard needs at least 1, and we have none left - failing") 
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
--print("mul.wildcardMatches moving wildcard with 'atleast' from "..i.." to 1")
					table.remove(wildcards, i)
					table.insert(wildcards, 1, w)
				end
				break
			end
		end
	end

	-- match all wildcards to zero
	local function checkWildcardPermutation(wildcards, matches)
		-- match all wildcards to zero
		-- test first, so we don't half-set the 'matches' before failing (TODO am I doing this elsewhere in :match()?)
		-- TODO w.index IS NOT GUARANTEED, if we have (x):match(W(1) + W(2) * W(3)) and add and mul have wildcardMatches
		-- in that case, you need to handle all possible sub-wildcardMatches specifically
--print("mul.wildcardMatches: testing against previous matches table...")
		for i,w in ipairs(wildcards) do
			local cmpExpr = i == 1 and matchExpr or defaultValue
--print("mul.wildcardMatches: comparing lhs "..Verbose(cmpExpr))
			if mul:isa(w) then
				error"match() doesn't work with unflattened mul's"
			elseif Wildcard:isa(w)
			or add:isa(w)
			then
				-- check before going through with it
				if not cmpExpr:match(w, table(matches)) then
					return false
				end
			else
				error("found match(mul(unknown))")
			end
		end
		-- finally set all matches to zero and return 'true'
		for i,w in ipairs(wildcards) do
			local cmpExpr = i == 1 and matchExpr or defaultValue
			if Wildcard:isa(w) then
--print('mul.wildcardMatches setting index '..w.index..' to '..require 'symmath.export.SingleLine'(i == 1 and matchExpr or defaultValue))
				-- write matches.  should already be true.
				cmpExpr:match(w, matches)
				--matches[w.index] = cmpExpr
			elseif add:isa(w) then
				-- use the state this time, so it does modify "matches"
				cmpExpr:match(w, matches)
			-- elseif mul.is shouldn't happen if all muls are flattened upon construction
			elseif mul:isa(w) then
				error"match() doesn't work with unflattened mul's"
			end
		end
		return true
	end
	
	for wildcards in wildcards:permutations() do
		wildcards = table(wildcards)
		if checkWildcardPermutation(wildcards, matches) then
--print("mul.wildcardMatches: success")
			return matches[1] or true, table.unpack(matches, 2, table.maxn(matches))
		end
	end
--print("mul.wildcardMatches: found no matching permutations - failing")
	return false
end

function mul.__eq(a,b)
	if getmetatable(a) ~= getmetatable(b) then return false end

	-- compare things order-independent, remove as you go
	local a = table(a)
	local b = table(b)
	for i=#a,1,-1 do
		local ai = a[i]
		-- non-commutative compare...
		if not ai.mulNonCommutative then
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

function mul:reverse(soln, index)
	-- y = a_1 * ... * a_j(x) * ... * a_n
	-- => a_j(x) = y / (a_1 * ... * a_j-1 * a_j+1 * ... * a_n)
	for k=1,#self do
		if k ~= index then
			soln = soln / self[k]:clone()
		end
	end
	return soln
end

function mul:getRealDomain()
	if self.cachedSet then return self.cachedSet end
	local I = self[1]:getRealDomain()
	if I == nil then 
		self.cachedSet = nil
		return nil 
	end
	for i=2,#self do
		local I2 = self[i]:getRealDomain()
		if I2 == nil then return nil end
		I = I * I2
	end
	self.cachedSet = I
	return self.cachedSet
end

-- goes horribly slow
--[[
a * (b + c) * d * e => (a * b * d * e) + (a * c * d * e)
--]]
function mul:distribute()
	symmath = symmath or require 'symmath'
	local add = symmath.op.add
	local sub = symmath.op.sub
	for i,ch in ipairs(self) do
		if add:isa(ch) or sub:isa(ch) then
			local terms = table()
			for j,chch in ipairs(ch) do
				local term = self:clone()
				term[i] = chch
				terms:insert(term)
			end
			return getmetatable(ch)(table.unpack(terms))
		end
	end
end

mul.rules = {
	Eval = {
		{apply = function(eval, expr)
			local result = 1
			for _,x in ipairs(expr) do
				result = result * eval:apply(x)
			end
			return result
		end},
	},

	Expand = {
		{apply = function(expand, expr)
			local dstr = expr:distribute()
			if dstr then return expand:apply(dstr) end
		end},
	},

	FactorDivision = {
		{apply = function(factorDivision, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local div = symmath.op.div
			
			-- first time processing we want to simplify()
			--  to remove powers and divisions
			--expr = expr:simplify()
			-- but not recursively ... hmm ...
			
			-- flatten multiplications
			local flat = expr:flattenAndClone()
			if flat then return factorDivision:apply(flat) end

			-- distribute multiplication
			local dstr = expr:distribute()
			if dstr then return factorDivision:apply(dstr) end

			-- [[ same as Prune:

			-- push all fractions to the left
			for i=#expr,2,-1 do
				if div:isa(expr[i])
				and Constant:isa(expr[i][1])
				and Constant:isa(expr[i][2])
				then
					table.insert(expr, 1, table.remove(expr, i))
				end
			end

			-- push all Constants to the lhs, sum as we go
			local cval = 1
			for i=#expr,1,-1 do
				if Constant:isa(expr[i]) then
					cval = cval * table.remove(expr, i).value
				end
			end
			
			-- if it's all constants then return what we got
			if #expr == 0 then 
				return Constant(cval) 
			end
			
			if cval == 0 then 
				return Constant(0) 
			end
			
			if cval ~= 1 then
				table.insert(expr, 1, Constant(cval))
			else
				if #expr == 1 then 
					return factorDivision:apply(expr[1]) 
				end
			end
			
			--]]	
		end},
	},

	Prune = {
		{apply = function(prune, expr)	
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local pow = symmath.op.pow
			local div = symmath.op.div
			
			-- flatten multiplications
			local flat = expr:flattenAndClone()
			if flat then return prune:apply(flat) end
			
			-- move unary minuses up
			--[[ pruning unm immediately
			do
				local unm = require 'symmath.op.unm'
				local unmCount = 0
				for i=1,#expr do
					local ch = expr[i]
					if unm:isa(ch) then
						unmCount = unmCount + 1
						expr[i] = ch[1]
					end
				end
				if unmCount % 2 == 1 then
					return -prune:apply(expr)	-- move unm outside and simplify what's left
				elseif unmCount ~= 0 then
					return prune:apply(expr)	-- got an even number?  remove it and simplify this
				end
			end
			--]]

			-- push all fractions to the left
			for i=#expr,2,-1 do
				if div:isa(expr[i])
				and Constant:isa(expr[i][1])
				and Constant:isa(expr[i][2])
				then
					table.insert(expr, 1, table.remove(expr, i))
				end
			end

			
			-- [[ and now for Matrix*Matrix multiplication ...
			-- do this before the c * 0 = 0 rule
			for i=#expr,2,-1 do
				local rhs = expr[i]
				local lhs = expr[i-1]
			
				local result
				if lhs.pruneMul then
					result = lhs.pruneMul(lhs, rhs)
				elseif rhs.pruneMul then
					result = rhs.pruneMul(lhs, rhs)
				end
				if result then
					table.remove(expr, i)
					expr[i-1] = result
					if #expr == 1 then expr = expr[1] end
					return prune:apply(expr)
				end
			end
			--]]

			-- push all Constants to the lhs, sum as we go
			local cval = 1
			for i=#expr,1,-1 do
				if Constant:isa(expr[i]) then
					cval = cval * table.remove(expr, i).value
				end
			end
			
			-- if it's all constants then return what we got
			if #expr == 0 then 
				return Constant(cval) 
			end
			
			if cval == 0 then 
				return Constant(0) 
			end
			
			if cval ~= 1 then
				table.insert(expr, 1, Constant(cval))
			else
				if #expr == 1 then 
					return prune:apply(expr[1]) 
				end
			end

-- [[
			local Variable = symmath.Variable
			local TensorRef = symmath.TensorRef
			local function compare(a, b) 
				-- Constant
				local ca, cb = Constant:isa(a), Constant:isa(b)
				if ca and not cb then return true end
				if cb and not ca then return false end
				if ca and cb then return a.value < b.value end
				-- div-of-Constants
				local fa = div:isa(a) and Constant:isa(a[1]) and Constant:isa(a[2])
				local fb = div:isa(b) and Constant:isa(b[1]) and Constant:isa(b[2])
				if fa and not fb then return true end
				if fb and not fa then return false end
				if fa and fb then
					if a[2].value < b[2].value then return true end
					if a[2].value > b[2].value then return false end
					if a[1].value < b[1].value then return true end
					if a[1].value > b[1].value then return false end
					return	-- a == b
				end
				-- Variable
				local va, vb = Variable:isa(a), Variable:isa(b)
				if va and not vb then return true end
				if vb and not va then return false end
				if va and vb then return a.name < b.name end
				-- TensorRef-of-Variable
				local ta = TensorRef:isa(a) and Variable:isa(a[1])
				local tb = TensorRef:isa(b) and Variable:isa(b[1])
				if ta and not tb then return true end
				if tb and not ta then return false end
				if ta and tb then 
					local na, nb = #a, #b
					if na < nb then return true end
					if na > nb then return false end
					if a[1].name < b[1].name then return true end
					if a[1].name > b[1].name then return false end
					for j=2,na do
						local na = type(a[j].symbol) == 'number'
						local nb = type(b[j].symbol) == 'number'
						if na and not nb then return true end
						if nb and not na then return false end
						return a[j].symbol < b[j].symbol
					end
					return -- a == b
				end
				-- pow
				local pa = pow:isa(a)
				local pb = pow:isa(b)
				if pa and not pb then return true end
				if pb and not pa then return false end
				if pa and pb then
					local result = compare(a[1], b[1])
					if result ~= nil then return result end
					return compare(a[2], b[2])
				end
			end
			for i=1,#expr-1 do
				for j=i,#expr-1 do
					local k = j + 1
					if not compare(expr[j], expr[k]) then
						expr[j], expr[k] = expr[k], expr[j]
					end
				end
			end
--]]

			-- [[ a^m * a^n => a^(m + n)
			do
				local modified = false
				local i = 1
				while i <= #expr do
					local x = expr[i]
					local base
					local power
					if pow:isa(x) then
						base = x[1]
						power = x[2]
					else
						base = x
						power = Constant(1)
					end
					
					if base then
						local j = i + 1
						while j <= #expr do
							local x2 = expr[j]
							local base2
							local power2
							if pow:isa(x2) then
								base2 = x2[1]
								power2 = x2[2]
							else
								base2 = x2
								power2 = Constant(1)
							end
							if base2 == base then
								modified = true
								table.remove(expr, j)
								j = j - 1
								power = power + power2
							end
							j = j + 1
						end
						if modified then
							expr[i] = base ^ power
						end
					end
					i = i + 1
				end
				if modified then
					if #expr == 1 then expr = expr[1] end
					return prune:apply(expr)
				end
			end
			--]]
			
			-- [[ factor out denominators
			-- a * b * (c / d) => (a * b * c) / d
			--  generalization:
			-- a^m * b^n * (c/d)^p = (a^m * b^n * c^p) / d^p
			do
				local uniqueDenomIndexes = table()
				
				local denoms = table()
				local powers = table()
				local bases = table()
				
				for i=1,#expr do
					-- decompose expressions of the form 
					--  (base / denom) ^ power
					local base = expr[i]
					local power = Constant(1)
					local denom = Constant(1)

					if pow:isa(base) then
						base, power = table.unpack(base)
					end
					if div:isa(base) then
						base, denom = table.unpack(base)
					end
					if not Constant.isValue(denom, 1) then
						uniqueDenomIndexes:insert(i)
					end

					denoms:insert(denom)
					powers:insert(power)
					bases:insert(base)
				end
				
				if #uniqueDenomIndexes > 0 then	
					
					local num
					if #bases == 1 then
						num = bases[1]
						if not Constant.isValue(powers[1], 1) then
							num = num ^ powers[1]
						end
					else
						num = bases:map(function(base,i)
							if Constant.isValue(powers[i], 1) then
								return base
							else
								return base ^ powers[i]
							end
						end)
						assert(#num > 0)
						if #num == 1 then
							num = num[1]
						else
							num = mul(num:unpack())
						end
					end
					
					local denom
					if #uniqueDenomIndexes == 1 then
						local i = uniqueDenomIndexes[1]
						denom = denoms[i]
						if not Constant.isValue(powers[i], 1) then
							denom = denom^powers[i]
						end
					elseif #denoms > 1 then
						denom = mul(table.unpack(uniqueDenomIndexes:map(function(i)
							if Constant.isValue(powers[i], 1) then
								return denoms[i]
							else
								return denoms[i]^powers[i]
							end
						end)))
					end
					
					local expr = num
					if not Constant.isValue(denom, 1) then
						expr = expr / denom
					end
					return prune:apply(expr)
				end
			end
			--]]
		end},
	
		{logPow = function(prune, expr)
			symmath = symmath or require 'symmath'
			-- b log(a) => log(a^b)
			-- I would like to push this to prevent x log(y) => log(y^x)
			-- but I would like to keep -1 * log(y) => log(y^-1)
			-- so I'll make a separate rule for that ...
			for i=1,#expr do
				if symmath.log:isa(expr[i]) then
					expr = expr:clone()
					local a = table.remove(expr,i)
					if #expr == 1 then expr = expr[1] end
					return prune:apply(symmath.log(a[1] ^ expr))
				end
			end	
		end},

		{negLog = function(prune, expr)
			symmath = symmath or require 'symmath'
			-- -1*log(a) => log(1/a)
			if #expr == 2
			and expr[1] == symmath.Constant(-1)
			and symmath.log:isa(expr[2])
			then
				return prune:apply(symmath.log(1/expr[2][1]))
			end	
		end},
	},

	Tidy = {
		{apply = function(tidy, expr)
			symmath = symmath or require 'symmath'
			local unm = symmath.op.unm
			local Constant = symmath.Constant
			
			-- -x * y * z => -(x * y * z)
			-- -x * y * -z => x * y * z
			do
				local unmCount = 0
				for i=1,#expr do
					local ch = expr[i]
					if unm:isa(ch) then
						unmCount = unmCount + 1
						expr[i] = ch[1]
					end
				end
				assert(#expr > 1)
				if unmCount % 2 == 1 then
					return -tidy:apply(expr)	-- move unm outside and simplify what's left
				elseif unmCount ~= 0 then
					return tidy:apply(expr)	-- got an even number?  remove it and simplify this
				end
			end
			
			-- (has to be solved post-prune() because tidy's Constant+unm will have made some new ones)
			-- 1 * x => x 	
			local first = expr[1]
			if Constant:isa(first) and first.value == 1 then
				table.remove(expr, 1)
				if #expr == 1 then
					expr = expr[1]
				end
				return tidy:apply(expr)
			end

			--[[
			-- TODO incorporate the rule x^a * x^b * ... => x^(a+b+...)
			-- but that means separating it out from Prune.apply, and that uses some in-place modification stuff
			-- until then, this is me being lazy and hoping for no infinite recursion:
			-- hmm, and who could've expected, this is causing stack overflows:
			local result = symmath.prune(expr)
			for i=1,#result do
				result[i] = tidy:apply(result[i])
			end
			return result
			--]]
			-- [
			return expr
			--]]
		end},
	
	},
}
-- ExpandPolynomial inherits from Expand
mul.rules.ExpandPolynomial = mul.rules.Expand

return mul
