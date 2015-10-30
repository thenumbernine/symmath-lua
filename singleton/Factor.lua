local addOp = require 'symmath.addOp'
local mulOp = require 'symmath.mulOp'
local powOp = require 'symmath.powOp'
local Constant = require 'symmath.Constant'
local Visitor = require 'symmath.singleton.Visitor'

local Factor = class(Visitor)

Factor.lookupTable = {
	[addOp] = function(factor, expr, factors)

		-- [[ x*a + x*b => x * (a + b)
		-- the opposite of this is in mulOp:prune's applyDistribute
		-- don't leave both of them uncommented or you'll get deadlock
		if #expr <= 1 then return end
		
		local function nodeToProdList(x)
			local prodList
			
			-- get products or individual terms
			if x:isa(mulOp) then
				prodList = table(x)
			else
				prodList = table{x}
			end
			
			-- pick out any exponents in any of the products
			prodList = prodList:map(function(ch)
				if ch:isa(powOp) then
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
				if x.term:isa(Constant) then
					if x.term.value == 1 then
						-- do nothing -- remove any 1's
					-- TODO if there's any negative constants, add -1^2 to all other terms
					elseif x.term.value < 0 then
						-- if it's a negative constant then split out the minus
						newProdList:insert{
							term = Constant(-1),
							power = x.power:clone(),
						}
						newProdList:insert{
							term = Constant(-x.term.value),
							power = x.power:clone(),
						}	-- add the new term
					else
						newProdList:insert(x)
					end
				else
					newProdList:insert(x)	-- add the new term
				end
			end
			prodList = newProdList

			return prodList
		end
				
		local function pruneProdList(listToPrune, listToFind)
			-- prods is our total list to be factored out
			-- checkProds is the list for the current child
			for _,prodFind in ipairs(listToFind) do
				local i = listToPrune:find(nil, function(prod)
					return prod.term == prodFind.term
				end)
				if i then
					local prodPrune = listToPrune[i]
					prodPrune.power = prodPrune.power - prodFind.power
					local prune = require 'symmath.prune'
					prodPrune.power = prune(prodPrune.power) or prodPrune.power
					
					if prodPrune.power:isa(Constant)
					and prodPrune.power.value <= 0	-- no factoring negatives ... for now ?
					then
						listToPrune:remove(i)
					end
				end
			end
		end

		-- 1) get all terms and powers
		local prodsList = table()
		for i=1,#expr do
			prodsList[i] = nodeToProdList(expr[i])
		end
	
-- without this (1-x)/(x-1) doesn't simplify to -1
-- [[
		-- instead of only factoring the -1 out of the constant
		-- also add double the -1 to the rest of the terms (which should equate to being positive)
		-- so that signs don't mess with simplifying division
		-- ex: -1+x => (-1)*1+(-1)*(-1)*x => -1*(1+(-1)*x) => -1*(1-x)
		-- TODO don't just use constants, use lowest polynomial or some method
		-- TODO fix both by just sorting the expr above ... assuming it uses commutative multiplications
		for i=1,#expr do
			if expr[i]:isa(Constant) and expr[i].value < 0 then
				for j=1,#expr do
					if not expr[j]:isa(Constant) then
						local index = prodsList[j]:find(nil, function(factor)
							return factor.term == Constant(-1)
						end)
						if index then
							prodsList[j][index].power = (prodsList[j][index].power + 2):simplify()
						else
							-- insert two copies so that one can be factored out
							-- TODO, instead of squaring it, raise it to 2x the power of the constant's separated -1^x
							prodsList[j]:insert{
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
		
		local minProds = prodsList[1]:map(function(prod) return prod.term end)
		for i=2,#prodsList do
			local otherProds = prodsList[i]:map(function(prod) return prod.term end)
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
		
		local prune = require 'symmath.prune'
		
		local minPowers = {}
		for i,minProd in ipairs(minProds) do
			-- 3) find abs min power of all terms
			local minPower
			local foundNonConstMinPower
			for i=1,#prodsList do
				for j=1,#prodsList[i] do
					if prodsList[i][j].term == minProd then
						if prodsList[i][j].power:isa(Constant) then
							if minPower == nil then
								minPower = prodsList[i][j].power.value
							else
								minPower = math.min(minPower, prodsList[i][j].power.value)
							end
						else	-- if it is variable then ... just use the ... first?
							minPower = prodsList[i][j].power
							foundNonConstMinPower = true
							break
						end
					end
				end
				if foundNonConstMinPower then break end
			end
			minPowers[i] = minPower
			-- 4) factor them out
			for i=1,#prodsList do
				for j=1,#prodsList[i] do
					if prodsList[i][j].term == minProd then
						prodsList[i][j].power = prodsList[i][j].power - minPower
						prodsList[i][j].power = prune(prodsList[i][j].power) or prodsList[i][j].power
					end
				end
			end
		end

		-- start with all the factored-out terms
		local terms = minProds:map(function(minProd,i) return minProd ^ minPowers[i] end)
		-- then add what's left of the original sum
		local lastTerm = addOp(prodsList:map(
			function(list)
				return mulOp(list:map(function(x)
					if x.power == Constant(1) then
						return x.term
					else
						return x.term ^ x.power
					end
				end):unpack())
			end):unpack())

		terms:insert(lastTerm)
		local result = mulOp(terms:unpack())
		
		return prune(result)
	end,
}

return Factor

