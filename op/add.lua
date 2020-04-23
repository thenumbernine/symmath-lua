local class = require 'ext.class'
local table = require 'ext.table'
local math = require 'ext.math'
local nodeCommutativeEqual = require 'symmath.nodeCommutativeEqual'
local Binary = require 'symmath.op.Binary'

local add = class(Binary)
add.precedence = 2
add.name = '+'

function add:evaluateDerivative(deriv, ...)
	local result = table()
	for i=1,#self do
		result[i] = deriv(self[i]:clone(), ...)
	end
	return add(result:unpack())
end

function add.__eq(a,b)
	if not add.is(a) or not add.is(b) then
		return add.super.__eq(a,b)
	end
	return nodeCommutativeEqual(a,b)
end

add.removeIfContains = require 'symmath.commutativeRemove'

function add:reverse(soln, index)
	-- y = a_1 + ... + a_j(x) + ... + a_n
	-- => a_j(x) = y - a_1 - ... - a_j-1 - a_j+1 - ... a_n
	for k=1,#self do
		if k ~= index then
			soln = soln - self[k]:clone()
		end
	end
	return soln
end

function add:getRealDomain()
	local I = self[1]:getRealDomain()
	if I == nil then return nil end
	for i=2,#self do
		local I2 = self[i]:getRealDomain()
		if I2 == nil then return nil end
		I = I + I2
	end
	return I
end

add.rules = {
	Eval = {
		{apply = function(eval, expr)
			local result = 0
			for _,x in ipairs(expr) do
				result = result + eval:apply(x)
			end
			return result
		end},
	},

	Factor = {
		{apply = function(factor, expr, factors)
			local symmath = require 'symmath'
			local mul = symmath.op.mul
			local pow = symmath.op.pow
			local Constant = symmath.Constant
			local Verbose = symmath.export.Verbose

			-- [[ x*a + x*b => x * (a + b)
			-- the opposite of this is in mul:prune's applyDistribute
			-- don't leave both of them uncommented or you'll get deadlock
			if #expr <= 1 then return end

			local function nodeToProdList(x)
				local prodList
				
				-- get products or individual terms
				if mul.is(x) then
					prodList = table(x)
				else
					prodList = table{x}
				end
				
				-- pick out any exponents in any of the products
				prodList = prodList:mapi(function(ch)
					if pow.is(ch) then
						return {
							term = ch[1],
							power = assert(ch[2]),
						}
					else
						return {
							term = ch,
							power = Constant(1),
						}
					end
				end)
		
				local newProdList = table()
				for k,x in ipairs(prodList) do
					if Constant.is(x.term) then
						local c = x.term.value
						if c == 1 then
							-- do nothing -- remove any 1's
						elseif c == 0 then
							newProdList:insert(x)
						else
							if c < 0 then
								-- if it's a negative constant then split out the minus
								newProdList:insert{
									term = Constant(-1),
									power = x.power,
								}
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
										newProdList:insert{
											term = Constant(p),
											power = x.power,
										}
									else
										newProdList:insert{
											term = Constant(p),
											power = x.power * power,
										}
									end
								end
							else
								newProdList:insert{
									term = Constant(c),
									power = x.power,
								}
							end
						end
					else
						newProdList:insert(x)	-- add the new term
					end
				end
				prodList = newProdList

				return prodList
			end
			
			local function prodListToNode(list)
				list = list:mapi(function(x)
					if Constant.isValue(x.power, 1) then
						return x.term
					else
						return x.term ^ x.power:simplify()
					end
				end)

				list = list:filter(function(x)
					return not Constant.isValue(x, 1)
				end)

				if #list == 0 then return Constant(1) end
				if #list == 1 then return list[1] end
				list = list:sort(function(a,b)
					local sa = Verbose(a)
					local sb = Verbose(b)
					if #sa ~= #sb then return #sa < #sb end
					return sa < sb 
				end)
				return setmetatable(list, mul)
			end


			-- 1) get all terms and powers
			local prodLists = table()
			for i=1,#expr do
				prodLists[i] = nodeToProdList(expr[i])
			end
			-- sort by prodLists[i].term, excluding all constants
			local function sortstr(list)
				if #list == 0 then return '' end
				if #list == 1 and Constant.is(list[1].term) then return '' end
				return table.mapi(list, function(x,_,t)
					if Constant.is(x.term) then return end
					return Verbose(x.term), #t+1
				end):concat(',')
			end
			-- sort the sum terms from shortest to longest
			prodLists:sort(function(a,b)
				local sa = sortstr(a)
				local sb = sortstr(b)
				return sa < sb 
			end)

			-- rebuild exprs accordingly
			assert(#prodLists == #expr)
			expr = setmetatable({}, symmath.op.add)
			for i=1,#prodLists do
				expr[i] = prodListToNode(prodLists[i])
			end
			assert(#expr > 1)


			--[[
			-- TODO where to put quadratic / polynomial division
			-- I should do this somewhere else, but I'll do it here for now
			-- a^2 - b^2 => (a+b) (a-b)
			if #expr == 2 then
				if symmath.op.pow.is(expr[1])
				and symmath.set.evenInteger:contains(expr[1][2])
				and symmath.op.mul.is(expr[2])
				and #expr[2] == 2
				and Constant.isValue(expr[2][1], -1)
				and symmath.op.pow.is(expr[2][2])
				and symmath.set.evenInteger:contains(expr[2][2][2])
				then
					local a = (expr[1][1] ^ (expr[1][2]/2))
					local b = (expr[2][2][1] ^ (expr[2][2][2]/2))
					return (a + b) * (a - b)
				end
			end
			-- TODO factoring higher polys ... this is just one specific case
			--]]

	
	-- without this (y-x)/(x-y) doesn't simplify to -1
	-- [[
			-- instead of only factoring the -1 out of the constant
			-- also add double the -1 to the rest of the terms (which should equate to being positive)
			-- so that signs don't mess with simplifying division
			-- ex: -1+x => (-1)*1+(-1)*(-1)*x => -1*(1+(-1)*x) => -1*(1-x)
			for i=1,#expr do
				--if expr[i] has a leading negative constant
				if #prodLists[i] > 0
				-- [[ old - expect a leading constant
				and Constant.is(prodLists[i][1].term) 
				and prodLists[i][1].term.value < 0 
				--]]
				--[[ new - look through all constants
				-- TODO enabling this breaks things, but the code above is inserting Constant(-1) not in front, so the old check would miss it?
				and prodLists[i]:find(nil, function(x) return Constant.isValue(x, -1) end)
				--]]
				then
					for j=1,#expr do
						--if j ~= i then	-- new ... fixing this? freezing?
						if j > i then	-- old ... why for 1..n instead of i+1..n?
							local index = prodLists[j]:find(nil, function(x)
								return Constant.isValue(x.term, -1)
							end)
							if index then
								prodLists[j][index].power = (prodLists[j][index].power + 2):simplify()
							else
								-- insert two copies so that one can be factored out
								-- TODO, instead of squaring it, raise it to 2x the power of the constant's separated -1^x
								prodLists[j]:insert{
									term = Constant(-1),
									power = Constant(2),
								}
							end
						end
					end
				end
			end
	--]]
			
			
			-- 2) find smallest set of common terms
			
			local minProds = prodLists[1]:mapi(function(prod) return prod.term end)
			for i=2,#prodLists do
				local otherProds = prodLists[i]:mapi(function(prod) return prod.term end)
				for j=#minProds,1,-1 do
					local found = false
					for k=1,#otherProds do
						if minProds[j] == otherProds[k] then
							found = true
							break
						end
					end
					if not found then
						minProds:remove(j)
					end
				end
			end


			if #minProds == 0 then return end
				
			local prune = symmath.prune

			local minPowers = {}
			for i,minProd in ipairs(minProds) do
				-- 3) find abs min power of all terms
				local minPower
				local foundNonConstMinPower
				for i=1,#prodLists do
					for j=1,#prodLists[i] do
						if prodLists[i][j].term == minProd then
							if Constant.is(prodLists[i][j].power) then
								if minPower == nil then
									minPower = prodLists[i][j].power.value
								else
									minPower = math.min(minPower, prodLists[i][j].power.value)
								end
							else	-- if it is variable then ... just use the ... first?
								minPower = prodLists[i][j].power
								foundNonConstMinPower = true
								break
							end
						end
					end
					if foundNonConstMinPower then break end
				end
				minPowers[i] = minPower
				-- 4) factor them out
				for i=1,#prodLists do
					for j=1,#prodLists[i] do
						if prodLists[i][j].term == minProd then
							prodLists[i][j].power = prodLists[i][j].power - minPower
							prodLists[i][j].power = prune(prodLists[i][j].power) or prodLists[i][j].power
						end
					end
				end
			end

			-- start with all the factored-out terms
			local terms = minProds:mapi(function(minProd,i) return minProd ^ minPowers[i] end)
			
			-- then add what's left of the original sum
			local lastTerm = prodLists:mapi(prodListToNode)
			lastTerm = #lastTerm == 1 and lastTerm[1] or add(lastTerm:unpack())

			terms:insert(lastTerm)
		
			local result = #terms == 1 and terms[1] or mul(terms:unpack())
			
			return prune(result)
		end},
	},

	Prune = {
		{apply = function(prune, expr, ...)
			local tableCommutativeEqual = require 'symmath.tableCommutativeEqual'
			local Constant = require 'symmath.Constant'
			local div = require 'symmath.op.div'
			local mul = require 'symmath.op.mul'
			local pow = require 'symmath.op.pow'
			
			-- flatten additions
			-- (x + y) + z => x + y + z
			for i=#expr,1,-1 do
				local ch = expr[i]
				if add.is(ch) then
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
			
			-- c1 + x1 + c2 + x2 => (c1+c2) + x1 + x2
			local cval = 0
			for i=#expr,1,-1 do
				if Constant.is(expr[i]) then
					cval = cval + table.remove(expr, i).value
				end
			end
			
			-- if it's all constants then return what we got
			if #expr == 0 then 
				return Constant(cval) 
			end
			
			-- re-insert if we have a Constant
			if cval ~= 0 then
				table.insert(expr, 1, Constant(cval))
			else
				-- if cval is zero and we're not re-inserting a constant
				-- then see if we have only one term ...
				if #expr == 1 then 
					return prune:apply(expr[1]) 
				end
			end

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

			-- [[ x * c1 + x * c2 => x * (c1 + c2) ... for constants
			do
				local muls = table()
				local nonMuls = table()
				for i,x in ipairs(expr) do
					if mul.is(x) then
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
							if type(k) ~= 'number' then return end
							return not Constant.is(x)
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
							if type(k) ~= 'number' then return end
							return Constant.is(x)
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

			-- TODO shouldn't this be regardless of the outer add ?
			-- turn any a + (b * (c + d)) => a + (b * c) + (b * d)
			-- [[ if any two children are muls,
			--    and they have all children in common (with the exception of any constants)
			--  then combine them, and combine their constants
			-- x * c1 + x * c2 => x * (c1 + c2) (for c1,c2 constants)
			for i=1,#expr-1 do
				local xI = expr[i]
				local termsI
				if mul.is(xI) then
					termsI = table(xI)
				else
					termsI = table{xI}
				end
				for j=i+1,#expr do
					local xJ = expr[j]
					local termsJ
					if mul.is(xJ) then
						termsJ = table(xJ)
					else
						termsJ = table{xJ}
					end

					local fail
					
					local commonTerms = table()

					local constI
					for _,ch in ipairs(termsI) do
						if not termsJ:find(ch) then
							if Constant.is(ch) then
								if not constI then
									constI = Constant(ch.value)
								else
									constI.value = constI.value * ch.value
								end
							else
								fail = true
								break
							end
						else
							commonTerms:insert(ch)
						end
					end
					if not constI then constI = Constant(1) end
					
					local constJ
					if not fail then
						for _,ch in ipairs(termsJ) do
							if not termsI:find(ch) then
								if Constant.is(ch) then
									if not constJ then
										constJ = Constant(ch.value)
									else
										constJ.value = constJ.value * ch.value
									end
								else
									fail = true
									break
								end
							end
						end
					end
					if not constJ then constJ = Constant(1) end
					
					if not fail then
						table.remove(expr, j)
						if #commonTerms == 0 then
							expr[i] = Constant(constI.value + constJ.value)
						else
							expr[i] = mul(Constant(constI.value + constJ.value), table.unpack(commonTerms))
						end
						if #expr == 1 then expr = expr[1] end
						return prune:apply(expr)
					end
				end
			end
			--]]
			
			--[[ factor out divs ...
			local denom
			local denomIndex
			for i,x in ipairs(expr) do
				if not div.is(x) then
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
				if div.is(x) then
					assert(#x == 2)
					local a,b = table.unpack(x)
					table.remove(expr, i)
					if #expr == 1 then expr = expr[1] end
					local expr = (expr * b + a) / b
					return prune:apply(expr)
				end
			end
			--]]
			--[[ divs all at once: a/b + c/d + e => (d*a + b*d + b*d*e) / (b*d)
			do
				local denom 
				for i,x in ipairs(expr) do
					if div.is(x) then
						denom = denom or table()
						denom:insert(x[2])
					end
				end
				if denom then
					denom = #denom == 1 and denom[1] or mul(denom:unpack())
					local nums = table()
					for i,x in ipairs(expr) do
						local num = table()
						for j,y in ipairs(expr) do
							if div.is(y) and i ~= j then num:insert(y[2]) end
						end				
						if div.is(x) then
							num:insert(1, x[1])
							num = #num == 1 and num[1] or mul(num:unpack()) 
							nums:insert(num)
						else
							num:insert(1, x)
							num = #num == 1 and num[1] or mul(num:unpack())
							nums:insert(num)
						end
					end
					nums = #nums == 1 and nums[1] or add(nums:unpack())
					return prune:apply(nums / denom)
				end
			end
			--]]


			-- [=[ trigonometry identities
			-- cos(theta)^2 + sin(theta)^2 => 1
			-- TODO first get a working factor() function
			-- then replace all nodes of cos^2 + sin^2 with 1
			-- ... or of cos^2 with 1 - sin^2 and let the rest cancel out  (best to operate on one function rather than two)
			--  (that 2nd step possibly in a separate simplifyTrig() function of its own?)
			do
				local cos = require 'symmath.cos'
				local sin = require 'symmath.sin'
				local Function = require 'symmath.Function'
			
				local function checkAdd(ch)
					local cosAngle, sinAngle
					local cosIndex, sinIndex
					for i,x in ipairs(ch) do
						
						if pow.is(x)
						and Function.is(x[1])
						and Constant.isValue(x[2], 2)
						then
							if cos.is(x[1]) then
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
							elseif sin.is(x[1]) then
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
						if cos.is(node) or sin.is(node) then
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
				if mul.is(f) then	-- should always be a mul unless there was nothing to factor
					for _,ch in ipairs(f) do
						if add.is(ch) then
							local result = checkAdd(ch)
							if result then 
								return prune:apply(result) 
							end
						end
					end
				end
				--]]
			end
			--]=]
		end},
	
		-- log(a) + log(b) = log(ab)
		{logMul = function(prune, expr)
			local symmath = require 'symmath'
			local found
			local log = symmath.log
			for i=#expr-1,1,-1 do
				local a = expr[i]
				for j=#expr,i+1,-1 do
					local b = expr[j]
					if log.is(a) and log.is(b) then
						if not found then
							expr = expr:clone()
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
		{apply = function(tidy, expr)
			local unm = require 'symmath.op.unm'
			for i=1,#expr-1 do
				-- x + -y => x - y
				if unm.is(expr[i+1]) then
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
				end
			end
		end},
	
		-- can't seem to catch this at the right place 
		--[[
		{trig = function(tidy, expr)
			local Constant = require 'symmath.Constant'
			local pow = require 'symmath.op.pow'
			local cos = require 'symmath.cos'
			if #self == 1
			and Constant.is(self[1]) 
			and self[1].value == 1
			and mul.is(self[2])
			and Constant.is(self[2][1])
			and self[2][1].value == -1
			and pow.is(self[2][2])
			and cos.is(self[2][2][1])
			and Constant.is(self[2][2][2])
			and self[2][2][2].value == 2
			then
				local sin = require 'symmath.sin'
				return sin(x[2][2][1][1])^2
			end
		end},
		--]]
	},
}

return add
