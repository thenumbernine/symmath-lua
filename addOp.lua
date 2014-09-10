require 'ext'
local BinaryOp = require 'symmath.BinaryOp'
local Function = require 'symmath.Function'
local Constant = require 'symmath.Constant'
local diff = require 'symmath.diff'
local tableCommutativeEqual = require 'symmath.tableCommutativeEqual'

local addOp = class(BinaryOp)
addOp.precedence = 2
addOp.name = '+'

function addOp:diff(...)
	local result = addOp()
	for i=1,#self.xs do
		result.xs[i] = diff(self.xs[i], ...)
	end
--	result = prune(result)
	return result
end

function addOp:eval()
	local result = 0
	for _,x in ipairs(self.xs) do
		result = result + x:eval()
	end
	return result
end

-- (TODO
-- factors is optional
--  without it, best fit
--  with it, use the requested factors)
function addOp:factor(factors)
	local powOp = require 'symmath.powOp'
	-- [[ x*a + x*b => x * (a + b)
	-- the opposite of this is in mulOp:prune's applyDistribute
	-- don't leave both of them uncommented or you'll get deadlock
	-- TODO this is factoring wrong
	if #self.xs <= 1 then return end
		
	local function nodeToProdList(x)
		local prodList
		
		-- get products or individual terms
		if x:isa(mulOp) then
			prodList = table(x.xs)
		else
			prodList = table{x}
		end
		
		-- pick out any exponents in any of the products
		prodList = prodList:map(function(ch)
			if ch:isa(powOp) then
				return {
					term = ch.xs[1],
					power = ch.xs[2],
				}
			else
				return {
					term = ch,
					power = Constant(1),
				}
			end
		end)
		
		prodList = prodList:filter(function(x)
			return not (x.term:isa(Constant) and x.term.value == 1)
		end)
		
		return prodList
	end
			
	local function prodListToString(list)
		return '['..table(list):map(function(x)
			return '{term='..tostring(x.term)..', power='..tostring(x.power)..'}'
		end):concat(', ')..']'
	end

	local function pruneProdList(listToPrune, listToFind)
		-- prods is our total list to be factored out
		-- checkProds is the list for the current child
		for _,prodFind in ipairs(listToFind) do
			local i = listToPrune:find(nil, function(prod)
				return prod.term == prodFind.term
			end)
			if i then
--print('looking for prune, found '..listToPrune[i].term)
				local prodPrune = listToPrune[i]
				prodPrune.power = prune(prodPrune.power - prodFind.power)
				if prodPrune.power:isa(Constant)
				and prodPrune.power.value <= 0	-- no factoring negatives ... for now ?
				then
					listToPrune:remove(i)
				end
			end
		end
	end
	
	local function prodListElemToNode(x)
		if x.power == Constant(1) then
			return x.term
		else
			return x.term ^ x.power
		end
	end
	
	local function prodListToNode(list)
		return mulOp(unpack(list:map(prodListElemToNode)))
	end

	-- 1) get all terms and powers
	local prodsList = self.xs:map(nodeToProdList)
	-- 2) find smallest set of common terms
	
	local minProds = prodsList[1]:map(function(prod) return prod.term end)
--print('first min prods',minProds:map(tostring):concat(', '))
	for i=2,#prodsList do
		local otherProds = prodsList[i]:map(function(prod) return prod.term end)
--print('filtering out other prods',otherProds:map(tostring):concat(', '))
		for j=#minProds,1,-1 do
			local found = false
			for k=1,#otherProds do
--print('comparing',tostring(minProds[j]),'and',tostring(otherProds[k]),'got',minProds[j] == otherProds[k])
				if minProds[j] == otherProds[k] then
					found = true
					break
				end
			end
--print('found?',found)
			if not found then
				minProds:remove(j)
			end
		end
	end
--print('min set count',#minProds,'contains',minProds:map(tostring):concat(', '))
	
	if #minProds == 0 then 
--print('no min prods')
		return 
	end

	local minPowers = {}
	for i,minProd in ipairs(minProds) do
		-- 3) find abs min power of all terms
		local minPower
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
					end
				end
			end
		end
		minPowers[i] = minPower
--print('min power of',tostring(minProd),'is',minPower)
		-- 4) factor them out
		for i=1,#prodsList do
--print("before simplification, prod:",prodListToString(prodsList[i]))
			for j=1,#prodsList[i] do
				if prodsList[i][j].term == minProd then
					prodsList[i][j].power = prodsList[i][j].power - minPower
				end
			end
--print("after simplification, prod:",prodListToString(prodsList[i]))
		end
	end

	local terms = minProds:map(function(minProd,i) return minProd ^ minPowers[i] end)
--print('terms',terms:map(function(t) return tostring(t) end))
	local lastTerm = addOp(unpack(prodsList:map(prodListToNode)))
--print('lastTerm',lastTerm)
	terms:insert(lastTerm)
	local result = mulOp(unpack(terms))
--print('got',result)
	return result
end

addOp.__eq = require 'symmath.nodeCommutativeEqual'

return addOp

