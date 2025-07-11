local table = require 'ext.table'
local math = require 'ext.math'
local Binary = require 'symmath.op.Binary'
local symmath

local mul = Binary:subclass()
mul.precedence = 3
mul.name = '*'
mul.nameForExporterTable = {}
mul.nameForExporterTable.LaTeX = ''	-- implicit mul, no symbol, but export/LaTeX.lua's symmath.op.mul exporter already has custom code, so you don't need this...

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
	local i = #self
	while i >= 1 do
		self[i]:flatten()
		if mul:isa(self[i]) then
			local x = table.remove(self, i)
			for j=#x,1,-1 do
				table.insert(self, i, x[j])
			end
			i = i + #x
		end
		i = i - 1
	end
	return self
end

-- TODO fix this too to not require multiple calls?
-- or can we just assert that the visitor will be called on the children so it doesn't matter?
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
--DEBUG(@5):local SingleLine = symmath.export.SingleLine
--DEBUG(@5):local Verbose = symmath.export.Verbose
--DEBUG(@5):print("mul.match(a="..Verbose(a)..", b="..Verbose(b)..", matches={"..(matches or table()):mapi(Verbose):concat', '..'}) begin')

	matches = matches or table()
	-- if 'b' is a mul then fall through
	-- this part is only for wildcard matching of the whole expression
	if not mul:isa(b)	-- if the wildcard is a mul then we want to test it here
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
--DEBUG(@5):print(' mul.match: removing matched terms...')
--DEBUG(@5):print(a[i])
--DEBUG(@5):print(b[j])
				a:remove(i)
				b:remove(j)
			end
		end
	end

--DEBUG(@5):print("mul.match: what's left after matching commutative non-wildcards:")
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

		-- TODO bi isn't necessarily a wildcard -- it could be an 'mulNonCommutative' term (though nothing does this for multiplication yet)
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
--DEBUG(@5):print(tab.."matches["..bi.index.."] tried to set to Constant(1), but it already exists as "..SingleLine(matches[bi.index]).." -- failing")
					if matches[bi.index] ~= Constant(1) then
						return false
					end
				else
--DEBUG(@5):print(tab.."setting matches["..bi.index.."] to Constant(1)")
					matches[bi.index] = Constant(1)
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
--DEBUG(@5):print(tab.."matching mul subexpr from first match "..SingleLine(a1).." index "..b.index.." to "..a:mapi(SingleLine):concat', ')
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
--DEBUG(@5):print(tab.."matching mul subexpr from first match "..SingleLine(a1).." index "..b.index.." to "..a:mapi(SingleLine):concat', ')
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

				local b1match = matchSize == 0 and Constant(1)
					or matchSize == 1 and a[1]
					or setmetatable(a:sub(1, matchSize), mul)
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
	local pow = symmath.op.pow
--DEBUG(@5):local SingleLine = symmath.export.SingleLine
--DEBUG(@5):local Verbose = symmath.export.Verbose
--DEBUG(@5):print("mul.wildcardMatches(self="..Verbose(self)..", a="..Verbose(a)..", matches={"..matches:mapi(Verbose):concat', '..'})')

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

--DEBUG(@5):print("mul.wildcardMatches children: "..table.mapi(self, Verbose):concat', ')
--DEBUG(@5):print("mul.wildcardMatches wildcard children: "..table.mapi(wildcards, Verbose):concat', ')
--DEBUG(@5):print("mul.wildcardMatches non-wildcard children: "..table.mapi(nonWildcards, Verbose):concat', ')

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
--DEBUG(@5):print("mul.wildcardMatches did match "..a.." to "..w.." with matches "..table.map(zeroMatches, function(v,k,t) return k..'='..v, #t+1 end):concat', ')
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
--DEBUG(@5):print("mul.wildcardMatches too many non-wildcards - failing")
		return false
	end

	local defaultValue = Constant(1)
	local matchExpr = a
	if #nonWildcards == 1
	and #wildcards > 0
	then
--DEBUG(@5):print("mul.wildcardMatches matchExpr "..require 'symmath.export.SingleLine'(a))
		-- TODO what if we are doing x:match(W{1,atLeast=1} * W{2}) ?
		local submatches = table(matches)
		if not a:match(nonWildcards[1], submatches) then
--DEBUG(@5):print("mul.wildcardMatches single remaining mul sub-term didn't match first non-wildcard - failing")

			--[[
			(a = Constant(4)) : match ( b = mul(Constant (2), Wildcard(1)) )
			calls (b = mul(Constant (2), Wildcard(1))) : wildcardMatches ( (a = Constant(4)) )
			has 1 non-wildcard: Constant(2)
			and 1 wildcard: Wildcard(1)

			now if (a = Constant(4)) matches (nw[1] = Constant(2)) then the next condition hits
			 and we continue on with our matched expresssion set to the operator identity of Constant(1)
			but if it doesn't match ...
			... what if we can just factor one out of the other?

			this is a question of the scope of the function:
			how much is this tree matching, and how much is this unknown substitution?
			tree matching? fail here.
			unknown-substitution? set the match to the fraction of
			--]]

			--[[ unknown-substitution
			-- this does fix Constant(4):match(Constant(2) * Wildcard(1))
			-- but this causes op/div's pattern matching to a / (b + sqrt(c))
			--  to successfully match a nil value
			-- TODO this is breaking a lot of integral tests as well
			if symmath.matchMulUnknownSubstitution
			and #wildcards > 0
			then
				matchExpr = (a / nonWildcards[1])()
				submatches = table(matches)
				if matchExpr:match(wildcards[1], submatches) then
					for k,v in pairs(matches) do matches[k] = nil end
					for k,v in pairs(submatches) do matches[k] = v end
					for i=2,#wildcards do defaultValue:match(wildcadrs[i], matches) end
--for i=1,#wildcards do
--	print('wildcards['..wildcards[i].index..'] = '..symmath.export.SingleLine(matches[wildcards[i].index]))
--end
					return matches[1] or true, table.unpack(matches, 2, table.maxn(matches))
				end
			end
			--]]
			return false
		else
			-- a:match(nonWildcards[1]) success so keep the matches:
			for k,v in pairs(matches) do matches[k] = nil end
			for k,v in pairs(submatches) do matches[k] = v end
			-- success, so matches have been written
			-- a matches nonWildcards[1]
			matchExpr = defaultValue
		end
	end

	-- if any of these wildcards needed a term then fail
	-- (that will be handled in the mul.match fallthrough
	--  which is why mul.match should not call this -- only other non-mul Expressions' .match())
	local totalAtLeast = 0
	for _,w in ipairs(wildcards) do
		if w.atLeast and w.atLeast > 0 then
			totalAtLeast = totalAtLeast + w.atLeast
			if totalAtLeast > 1 then
--DEBUG(@5):print("mul.wildcardMatches: wildcard needs at least 1, and we have none left - failing")
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
--DEBUG(@5):print("mul.wildcardMatches moving wildcard with 'atleast' from "..i.." to 1")
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
--DEBUG(@5):print("mul.wildcardMatches: testing against previous matches table...")
		for i,w in ipairs(wildcards) do
			local cmpExpr = i == 1 and matchExpr or defaultValue
--DEBUG(@5):print("mul.wildcardMatches: comparing lhs "..Verbose(cmpExpr))
			if mul:isa(w) then
				error"match() doesn't work with unflattened mul's"
			elseif Wildcard:isa(w)
			or add:isa(w)
			or pow:isa(w)
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
--DEBUG(@5):print('mul.wildcardMatches setting index '..w.index..' to '..require 'symmath.export.SingleLine'(i == 1 and matchExpr or defaultValue))
				-- write matches.  should already be true.
				cmpExpr:match(w, matches)
				--matches[w.index] = cmpExpr
			elseif add:isa(w) then
				-- use the state this time, so it does modify "matches"
				cmpExpr:match(w, matches)
			elseif pow:isa(w) then
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
--DEBUG(@5):print("mul.wildcardMatches: success")
			return matches[1] or true, table.unpack(matches, 2, table.maxn(matches))
		end
	end
--DEBUG(@5):print("mul.wildcardMatches: found no matching permutations - failing")
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

function mul:getRealRange()
	if self.cachedSet then return self.cachedSet end
	local I = self[1]:getRealRange()
	if I == nil then
		self.cachedSet = nil
		return nil
	end
	for i=2,#self do
		local I2 = self[i]:getRealRange()
		if I2 == nil then return nil end
		I = I * I2
	end
	self.cachedSet = I
	return self.cachedSet
end

-- lim mul = mul lim
function mul:evaluateLimit(x, a, side)
	symmath = symmath or require 'symmath'
	local Limit = symmath.Limit

	-- TODO handle indeterminate forms here?  or outside of limits?
	-- right now they are evaluated outside of limits...
	return symmath.prune(
		mul(
			table.mapi(self, function(fi)
				return Limit(fi, x, a, side)
			end):unpack()
		)
	)
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

local function isConstantFraction(expr)
	symmath = symmath or require 'symmath'
	local div = symmath.op.div
	local Constant = symmath.Constant
	return div:isa(expr) and Constant:isa(expr[1]) and Constant:isa(expr[2])
end

local function isConstantFractionValue(expr, num, denom)
	symmath = symmath or require 'symmath'
	local div = symmath.op.div
	local Constant = symmath.Constant
	return div:isa(expr) and Constant.isValue(expr[1], num) and Constant.isValue(expr[2], denom)
end


mul.rules = {
-- [[
	Expand = {
		{apply = function(expand, expr)
			local dstr = expr:distribute()
			if dstr then
				return expand:apply(dstr)
			end
		end},
	},
--]]

	-- not sure where this rule should go, or if I already have a copy somewhere ....
	Factor = {

-- [[ a^n * b^n => (a * b)^n
-- this is also in mul/Prune/combineMulOfLikePow
-- and the opposite is in pow/Expand/expandMulOfLikePow and pow/Prune/expandMulOfLikePow
-- I'm removing it here after a reorganization of rules because now, with prune() turning expressions into div add mul, this is causing stack overflows
		{combineMulOfLikePow = function(factor, expr)
			symmath = symmath or require 'symmath'
			local pow = symmath.op.pow
			for i=1,#expr-1 do
				if pow:isa(expr[i]) then
					for j=i+1,#expr do
						if pow:isa(expr[j]) then
							if expr[i][2] == expr[j][2] then
								-- powers match, combine
								local repl = (expr[i][1] * expr[j][1]) ^ expr[i][2]
								expr = expr:clone()
								table.remove(expr, j)
								expr[i] = repl
								if #expr == 1 then expr = expr[1] end
								--expr = expr:prune()
								--expr = expr:expand()
								--expr = expr:prune()
								--expr = factor:apply(expr)
								return expr
							end
						end
					end
				end
			end
		end},
--]]

--[[
-- hmm ... raise everything to the lowest power?
-- if there are any sqrts, square everything?
-- this is for 2/sqrt(6) => sqrt(2)/sqrt(3)
-- this seems to do more harm than good, esp when summing fractions of sqrts
-- This also looks dangerous, like it would be cancelling negatives somewhere.
		{raiseEverythingToLowestPower = function(factor, expr)
			symmath = symmath or require 'symmath'
			local sqrt = symmath.sqrt
			local pow = symmath.op.pow
			local div = symmath.op.div
			local Constant = symmath.Constant
			for i,x in ipairs(expr) do
				if pow:isa(x)
				and symmath.set.integer:contains(x[1])
				and #math.primeFactorization(x[1].value) > 1
				and div:isa(x[2])
				and Constant.isValue(x[2][2], 2)
				and Constant.isValue(x[2][1], -1)
				then
					return factor:apply(sqrt((expr^2):prune()))
				end
			end
		end},
--]]

-- [[ how about turning p*x^-q/2 into p/x^(q/2) here?
-- still prevents sums of fractions of sqrts ...
		{negPowToDivPow = function(factor, expr)
			symmath = symmath or require 'symmath'
			local pow = symmath.op.pow
			local div = symmath.op.div
			local Constant = symmath.Constant
			for i,x in ipairs(expr) do
				if pow:isa(x)
				and symmath.set.integer:contains(x[1])
				--and #math.primeFactorization(x[1].value) > 1
				and div:isa(x[2])
				and Constant.isValue(x[2][2], 2)
				--[=[
				and Constant.isValue(x[2][1], -1)
				then
					expr = expr:clone()
					table.remove(expr, i)
					if #expr == 1 then expr = expr[1] end
					return factor:apply(expr / symmath.sqrt(x[1]))
					--return factor:apply(symmath.sqrt((expr^2):prune()))
				end
				--]=]
				-- [=[
				--[==[
				and Constant:isa(x[2][1])
				and x[2][1].value < 0
				and (x[2][1].value % 2) == 1
				--]==]
				-- [==[ TODO oddNegativeInteger .. or sets based on conditions ...
				and symmath.set.oddInteger:contains(x[2][1])
				and symmath.set.negativeReal:contains(x[2][1])
				--]==]
				then
					expr = expr:clone()
					table.remove(expr, i)
					if #expr == 1 then expr = expr[1] end
					return factor:apply(expr / x[1]^div(-x[2][1], x[2][2]))
					--return factor:apply(symmath.sqrt((expr^2):prune()))
				end
				--]=]
			end
		end},
--]]
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
		{flatten = function(prune, expr)
			-- flatten multiplications
			local flat = expr:flattenAndClone()
			if flat then return prune:apply(flat) end
		end},

-- move unary minuses up
--[[ pruning unm immediately
		{moveUnmUp = function(prune, expr)
			symmath = symmath or require 'symmath'
			local unm = symmath.op.unm
			local unmCount = 0
			local modified
			for i=1,#expr do
				local ch = expr[i]
				if unm:isa(ch) then
					unmCount = unmCount + 1
					expr[i] = ch[1]
					modified = true
				end
			end
			if modified then
				if unmCount % 2 == 1 then
					return -prune:apply(expr)	-- move unm outside and simplify what's left
				elseif unmCount ~= 0 then
					return prune:apply(expr)	-- got an even number?  remove it and simplify this
				end
			end
		end},
--]]

		{handleInfAndNan = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local invalid = symmath.invalid
			local inf = symmath.inf
			local negativeReal = symmath.set.negativeReal

			-- anything * invalid is invalid
			for i=1,#expr do
				if expr[i] == invalid then
--DEBUG(@5):print("mul by invalid ... makes invalid")
					return invalid
				end
			end

			-- inf * anything = inf
			-- inf * -anything = -inf
			local hasinf
			local haszero
			local sign = 1
			for i=1,#expr do
				if expr[i] == inf then
					hasinf = true
				end
				if Constant.isValue(expr[i], 0) then
					haszero = true
				end
				-- TODO recursively call instead of for-loop
				-- and TODO if expr[i] is not in positive or negative real then don't simplify it, because it is arbitrary.
				-- x * inf cannot be simplified to +inf or -inf.
				if negativeReal:contains(expr[i]) then
					sign = -sign
				end
			end
			if hasinf then
				if haszero then
--DEBUG(@5):print("mul hasinf and hazero ... makes invalid")
					return invalid
				end
				if sign == -1 then
					-- use the pruned form, but don't call prune, or it gets an infinite loop
					return Constant(-1) * inf
				end
				return inf
			end
		end},

--[[ push fractions of constants to the left ... as a separate rule.
-- ... does this even do anything?
-- no, i'm pretty sure prune() will turn a mul div into a div mul
-- so until further notice it is disabled
		{pushFractionsOfConstantsLeft = function(prune, expr)
			local function shouldMoveLeft(i)
				return isConstantFraction(expr[i])
					and not isConstantFraction(expr[i-1])
			end
			local hasBeenCloned
			local function doMoveLeft(i)
				if not hasBeenCloned then
					expr = expr:clone()
					hasBeenCloned = true
				end
				expr[i], expr[i-1] = expr[i-1], expr[i]
			end
			-- push all fractions of constants to the left
			for i=2,#expr do
				-- if we can move it left ...
				if shouldMoveLeft(i) then
					-- then move it left as far as we can
					for j=i,2,-1 do
						doMoveLeft(j)
						if j > 2 and shouldMoveLeft(j) then break end
					end
				end
			end
			if hasBeenCloned then
				return prune:apply(expr)
			end
		end},
--]]

-- [[ another one that doesn't affect any unit tests and I completely forgot why it's here
		{tensorRule = function(expr, prune)
			symmath = symmath or require 'symmath'
			local Tensor = symmath.Tensor
			local TensorRef = Tensor.Ref

			local modified

			-- TODO here
			-- next step is pruneMul for simplifying things like Tensor's
			-- but a few steps further is sorting terms, which also can sort TensorRef's
			-- also it looks like that sort doesn't respect mulNonCommute
			-- so a good TODO would be to move the sort up here, or the pruneMul down there
			-- and then sort the TensorRefs such that evaluating Tensor:pruneMul left to right is done optimally

			-- [=[ ok so since TensorRef of Tensor isn't commutative, lets sort them here
			-- oh yeah TensorRef-of-Tensor has already been prune()'d into a Tensor, so ...

			-- wait TensorRef of Tensor mul is commutative, isn't it?  though Matrix mul isn't.
			local indexesOfTensors
			for i,x in ipairs(expr) do
				if Tensor:isa(x) then
					indexesOfTensors = indexesOfTensors or table()
					indexesOfTensors:insert(i)
				end
			end
--DEBUG(@5):print('indexesOfTensors: '..(indexesOfTensors and table.concat(indexesOfTensors, ',') or 'nil'))
			if indexesOfTensors and #indexesOfTensors > 1 then
				local tensors = table()
				-- indexesOfTensors is in-order, so remove them in reverse order
				for i=#indexesOfTensors,1,-1 do
					if not modified then
						expr = expr:clone()
						modified = true
					end
					tensors:insert(table.remove(expr, indexesOfTensors[i]))
				end
			--[==[ method #1: something about counting number of sum indexes
--DEBUG(@5):print('#tensors: '..#tensors)
				-- ok now sort them by number of sum indexes between them
				-- TODO what metric should I use here ...
				local tensorsForSymbols = {}
				for i,t in ipairs(tensors) do
					for _,index in ipairs(t.variance) do
						local sym = index.symbol
--DEBUG(@5):print('adding tensor #'..i..' to symbol	'..sym)
						tensorsForSymbols[sym] = tensorsForSymbols[sym] or table()
						tensorsForSymbols[sym]:insert(t)
					end
				end
				-- higher #tensorsForSymbols[sym] means more terms summed between them
--DEBUG(@5):print('keys(tensorsForSymbols): '..table.keys(tensorsForSymbols):concat',')

				-- ok now we need to associate tensors with counts
				-- so sum up the counts of the number
				local countsForTensors = {}
				for sym,ts in pairs(tensorsForSymbols) do
--DEBUG(@5):print('enumerating '..sym..' #tensors '..#ts)
					for _,t in ipairs(ts) do
						countsForTensors[t] = (countsForTensors[t] or 0) + (#ts - 1)
					end
				end
--DEBUG(@5):print('#keys(countsForTensors): '..#table.keys(countsForTensors))

				local bestTensors = table.map(countsForTensors, function(count, t, dst)
					return {count=count, t=t}, #dst+1
				end):sort(function(a,b)
					-- greatest # goes first
					return a.count > b.count
				end)
--DEBUG(@5):for _,tcs in ipairs(bestTensors) do
--DEBUG(@5):	print('count '..tcs.count..' tensor '..symmath.Verbose(tcs.t))
--DEBUG(@5):end
				-- now from last to first insert in the end of expr
				-- this way when we Tensor.pruneMul from last to first, it will get the least sums first
				for i=#bestTensors,1,-1 do
					if not modified then
						expr = expr:clone()
						modified = true
					end
					local p = bestTensors[i]
					table.insert(expr, p.t)
				end
			--]==]
			-- [==[ method #2: look at all pairs, sort them by # indexes left after summing
			-- then greedy pull tensors in that order
			-- but that means replacing each pulled pair with the result of the pair's mul
				local insertLoc = #expr+1
--DEBUG(@5):print('insertLoc', insertLoc)
				repeat
--DEBUG(@5):print('#tensors: '..#tensors)
					local tensorPairs = table()
					local mul = symmath.op.mul
					local Variable = symmath.Variable
					for i=1,#tensors-1 do
						local ti = tensors[i]
						for j=i+1,#tensors do
							local tj = tensors[j]
							local mulexpr = mul(
								TensorRef(Variable'tmp1', table.unpack(ti.variance)),
								TensorRef(Variable'tmp2', table.unpack(tj.variance))
							)
							local fixed, sum, extra = mulexpr:getIndexesUsed()
							tensorPairs:insert{
								indexes = {i,j},
								mulexpr = mulexpr,
								fixed = fixed,
								sum = sum,
								extra = extra,
							}
						end
					end
					local best = tensorPairs:inf(function(a,b)
						return #a.fixed < #b.fixed
					end)
					-- ok now we have 'best' ...
					-- insert them into the end of the expr
					local i, j = table.unpack(best.indexes)
					if i > j then i,j = j,i end
					local ti = table.remove(tensors,j)
					local tj = table.remove(tensors,i)
--DEBUG(@5):print('#expr', #expr, 'insertLoc', insertLoc)
					if not ti.fake then
						if not modified then
							expr = expr:clone()
							modified = true
						end
						table.insert(expr, insertLoc, ti)
					end
--DEBUG(@5):print('#expr', #expr, 'insertLoc', insertLoc)
					if not tj.fake then
						if not modified then
							expr = expr:clone()
							modified = true
						end
						table.insert(expr, insertLoc, tj)
					end
--DEBUG(@5):print('#tensors is now '..#tensors)
					if #tensors == 0 then break end
					tensors:insert{
						fake = true,
						variance = best.fixed,
					}
				until false
--DEBUG(@5):print'done'
			--]==]
			end
			--]=]

			if modified then
				return prune:apply(expr)
			end
		end},
--]]

-- [[ and now for Matrix*Matrix multiplication ...
-- Do this before the c * 0 = 0 rule.
		{matrixMul = function(prune, expr)
			symmath = symmath or require 'symmath'
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
					expr = expr:clone()
					table.remove(expr, i)
					expr[i-1] = result
					if #expr == 1 then expr = expr[1] end
					return prune:apply(expr)
				end
			end
		end},
--]]

-- [===[		-- TODO FIXME THIS HAS MODIFICATION IN-PLACE
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
--DEBUG(@5):print('Prune/apply: '..symmath.export.SingleLine(expr))
--DEBUG(@5):print('...aka: '..symmath.export.Verbose(expr))
			local Constant = symmath.Constant
			local pow = symmath.op.pow
			local Variable = symmath.Variable
			local TensorRef = symmath.Tensor.Ref

			--expr = expr:clone()	-- wow this causes a lot of damage

			--[[ here push all mulNonCommutes to the rhs
			TODO why am I even sorting these?
			I should just bin them all according to some classifications
			1) constants
			2) fractions-of-constants
			4) terms to a constant power
			3) etc
			5) Tensor (commutes ... mind you TensorRef-of-Tensor has already been prune'd into a Tensor)
			4) Array, Matrix (doesn't commute)
			--]]


			-- push all Constants to the lhs, mul as we go
			-- if we get a times 0 then return 0
			--local hasBeenCloned
			local cval = 1
			for i=#expr,1,-1 do
				local x = expr[i]
				if Constant:isa(x) then
					if x.value == 0 then
						return Constant(0)
					end
					--[=[ for some reason this one causes all sorts of errors
					if not hasBeenCloned then
						expr = expr:clone()
						hasBeenCloned = true
					end
					--]=]
					-- otherwise cval * x.value should not equal zero ...
					table.remove(expr, i)
					cval = cval * x.value
				end
			end

			-- if it's all constants then return what we got
			if #expr == 0 then
				return Constant(cval)
			end

			if cval ~= 1 then
				--[=[ for some reason this one causes all sorts of errors
				if not hasBeenCloned then
					expr = expr:clone()
					hasBeenCloned = true
				end
				--]=]
				table.insert(expr, 1, Constant(cval))
			else
				if #expr == 1 then
					--return prune:apply(expr[1])
					-- cheap trick to fix the problem
					-- (frac(1,2)*sqrt(3))*(frac(sqrt(2),sqrt(3))) + (-frac(1,2))*(frac(1,3)*-sqrt(2))
					-- is requiring two :simplify()'s in order to simplify fully
					-- just insert a :tidy() for the time being and things seem to work
					return prune:apply(expr[1]:tidy())
				end
			end

-- [[
			-- TODO use the same compare() that's in op/add.lua
			local function compare(a, b)
				-- Constant
				local ca, cb = Constant:isa(a), Constant:isa(b)
				if ca and not cb then return true end
				if cb and not ca then return false end
				if ca and cb then return a.value < b.value end
				-- div-of-Constants
				local fa = isConstantFraction(a)
				local fb = isConstantFraction(b)
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
						if a[j].symbol < b[j].symbol then return true end
						if a[j].symbol > b[j].symbol then return false end
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
		end},

-- [[ a^m * a^n => a^(m + n)
-- notice that the rule before and after are important to this one
		{combinePows = function(prune, expr)
			symmath = symmath or require 'symmath'
			local pow = symmath.op.pow
			local Constant = symmath.Constant

			--[=[ before combining powers, separate out any -1's from constants
			-- this fixes my -2 * 2^(-1/2) simplify bug, but somehow screws up everything
			--
			-- Feel like I should timestamp this next comment: I'm not seeing the alleged bug anymore.
			--
			local mul = symmath.op.mul
			if mul:isa(expr)
			and Constant:isa(expr[1])
			and expr[1].value < 0
			and expr[1].value ~= -1
			then
				expr = expr:clone()
				expr[1] = Constant(-expr[1].value)
				table.insert(expr, 1, Constant(-1))
			end
			--]=]

			local function getBasePower(x)
				if pow:isa(x) then
					return x[1], x[2]
				end

				-- [=[ I have a weird bug where 4 * 2^(-1/2) won't simplify to 2 sqrt(2)
				if Constant:isa(x) then
					-- TODO get this to work for bignumber ...
					if type(x.value) == 'number'
					and x.value > 1 
					then
						local sqrtx = math.sqrt(x.value)
						-- TODO set integer test?
						if sqrtx == math.floor(sqrtx) then
							return Constant(sqrtx), Constant(2)
						end
					end
				end
				--]=]
				-- same with -2 * 2^(-1/2) ... hmm ...

				return x, Constant(1)
			end

			local modified = false
			local i = 1
			while i <= #expr do
				local x = expr[i]
				local base, power = getBasePower(x)
				if base then
					local j = i + 1
					while j <= #expr do
						local x2 = expr[j]
						local base2, power2 = getBasePower(x2)
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
		end},
--]]

--[[ after combining powers, re-merge any leading -1's:
-- -1 * c * ... => -c * ...
-- TODO maybe it's bad to assume structure of the mul after Prune:apply is finished ...
-- NOTICE not seeing a need for this anymore ... ?  If there is then add it into the unit tests.
		{mergeLeadingNegativeConstant = function(prune, expr)
			symmath = symmath or require 'symmath'
			local mul = symmath.op.mul
			local Constant = symmath.Constant
			if mul:isa(expr)
			and Constant.isValue(expr[1], -1)
			and Constant:isa(expr[2])
			then
				return
--					prune:apply(	-- NOTICE this causes a stack overflow
						symmath.tableToMul{
							Constant(-expr[2].value),
							table.unpack(expr, 3)
						}
--					)
			end
		end},
--]]

-- [[ factor out denominators
-- a * b * (c / d) => (a * b * c) / d
--  generalization:
-- a^m * b^n * (c/d)^p = (a^m * b^n * c^p) / d^p
		{factorDenominators = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local pow = symmath.op.pow
			local div = symmath.op.div

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
		end},
--]===]

-- [[ a^n * b^n => (a * b)^n
--[=[
this rule here passes the unit tests
but it puts Platonic Solids in a simplification loop...
TODO respect mulCommutative
only test to your neighbor
and have a step above for pushing all commutative terms to one side

it turns out this also kills: (x*y)/(x*y)^2 => 1/(x*y)
but this makes work: sqrt(sqrt(sqrt(5) + 1) * sqrt(sqrt(5) - 1)) => 2

but if I only do this for sqrts?
that appeases that particular unit tests.

but even that also kills simplification of sqrt(f) * (g + sqrt(g))

so between the two cases...

looks like I can solve both unit tests if I only apply this to powers-of-adds
so when we find mul -> pow -> add
--]=]
		{combineMulOfLikePow_mulPowAdd = function(prune, expr)
			symmath = symmath or require 'symmath'
			local pow = symmath.op.pow
			local add = symmath.op.add
			for i=1,#expr-1 do
				if pow:isa(expr[i])
				--[=[ only for pow-of-sqrts?
				and isConstantFractionValue(expr[i], 1, 2)
				--]=]
				-- [=[ only for pow-of-add?
				and add:isa(expr[i][1])
				--]=]
				then
					for j=i+1,#expr do
						if pow:isa(expr[j])
						--[=[ only for pow-of-sqrts?
						and isConstantFractionValue(expr[j], 1, 2)
						--]=]
						-- [=[ only for pow-of-add?
						and add:isa(expr[j][1])
						--]=]
						then
							if expr[i][2] == expr[j][2] then
								-- powers match, combine
								local repl = (expr[i][1] * expr[j][1]):prune() ^ expr[i][2]
								--repl = repl:prune()	-- causes loops
								expr = expr:clone()
								table.remove(expr, j)
								expr[i] = repl
								if #expr == 1 then expr = expr[1] end
								--expr = prune:apply(expr)	-- causes loops
								return expr
							end
						end
					end
				end
			end
		end},
--]]

--[[ how about turning c*x^-1/2 into c/sqrt(x) here?
-- still prevents sums of fractions of sqrts ...
		{replacePowHalfWithSqrt = function(prune, expr)
			local sqrt = symmath.sqrt
			local pow = symmath.op.pow
			local div = symmath.op.div
			local Constant = symmath.Constant
			for i,x in ipairs(expr) do
				if pow:isa(x)
				and symmath.set.integer:contains(x[1])
				-- without this we get a stack overflow:
				-- but without this, and without the return prune, it fixes 3*1/sqrt(2) not simplifying
				and #math.primeFactorization(x[1].value) > 1
				and isConstantFractionValue(x[2], -1, 2)
				then
					expr = expr:clone()
					table.remove(expr, i)
					if #expr == 1 then expr = expr[1] end
					--return prune:apply(expr / sqrt(x[1]))
					return expr / sqrt(x[1])
					--return factor:apply(sqrt((expr^2):prune()))
				end
			end
		end},
--]]

-- [[ a^n * b^n => (a * b)^n
-- the general case of this seems to interfere wtih combineMulOfLikePow_mulPowAdd above
-- so i'll just have this only apply to constants-to-some power
		{combineMulOfLikePow_constants = function(prune, expr)
			symmath = symmath or require 'symmath'
			local pow = symmath.op.pow
			local Constant = symmath.Constant
			for i=1,#expr-1 do
				if pow:isa(expr[i])
				-- only for constants (I guess?). if I do non-constants then it interferes with other rules
				and Constant:isa(expr[i][1])
				then
					for j=i+1,#expr do
						if pow:isa(expr[j])
						and Constant:isa(expr[j][1])
						then
							-- if the powers match
							if expr[i][2] == expr[j][2] then
								-- powers match, combine
								local repl = prune:apply(expr[i][1] * expr[j][1]) ^ expr[i][2]
								expr = expr:clone()
								table.remove(expr, j)
								expr[i] = repl
								if #expr == 1 then expr = expr[1] end
								return expr
							--[=[ if the powers are fractions and the denominator matches
							local div = symmath.op.div
							elseif div:isa(expr[i][2])
							and div:isa(expr[j][2])
							and expr[i][2][1] == expr[j][2][1]
							then
								local repl = prune:apply(expr[i][1]^expr[i][2][1] * expr[j][1]^expr[j][2][1]) ^ (1/expr[i][2][2])
								expr = expr:clone()
								table.remove(expr, j)
								expr[i] = repl
								if #expr == 1 then expr = expr[1] end
								return expr
							--]=]
							end
						end
					end
				end
			end
		end},
--]]

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

		--[[ move expand rule to prune ...
		-- without this, (a^2 * x^2 - a^2):simplify() has :factor() turn it into (a^2 (x + 1) (x - 1))
		--  and subsequent :prune() leaves it in this state
		-- with this, (1 + 1/x + 2/x) fails to simplify to (1 + 3/x) and we get some infinite loops somewhere
		{expand = function(prune, expr)
			local dstr = expr:distribute()
			if dstr then
				-- and don't simplify or you'll get an infinite loop ...
				return prune:apply(dstr)
			end
		end},
		--]]
	},

	Tidy = {
		{apply = function(tidy, expr)
			symmath = symmath or require 'symmath'
			local unm = symmath.op.unm
			local Constant = symmath.Constant

			-- TODO where was in-place modification allowed?
			-- I think I was moving away from it in visitors
			expr = expr:clone()

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
			if Constant.isValue(first, 1) then
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
			-- [[
			return expr:flatten()	-- flatten() is in-place
			--]]
		end},

	},
}
-- ExpandPolynomial inherits from Expand
mul.rules.ExpandPolynomial = mul.rules.Expand

return mul
