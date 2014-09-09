require 'ext'
local BinaryOp = require 'symmath.BinaryOp'
local Function = require 'symmath.Function'
local Constant = require 'symmath.Constant'
local diff = require 'symmath.diff'
local prune = require 'symmath.prune'
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

function addOp:prune()
	local mulOp = require 'symmath.mulOp'
	
	assert(#self.xs > 0)
	if #self.xs == 1 then return prune(self.xs[1]) end

	-- prune children
	for i=1,#self.xs do
		self.xs[i] = prune(self.xs[i])
	end
	
	-- flatten additions
	for i=#self.xs,1,-1 do
		local ch = self.xs[i]
		if ch:isa(addOp) then
			-- this looks like a job for splice ...
			self:removeChild(i)
			for _,chch in ipairs(ch.xs) do
				self:insertChild(i, chch)
			end
		end
	end
	
	-- push all Constants to the lhs, sum as we go
	local cval = 0
	for i=#self.xs,1,-1 do
		if self.xs[i]:isa(Constant) then
			cval = cval + self:removeChild(i).value
		end
	end
	
	-- if it's all constants then return what we got
	if #self.xs == 0 then return Constant(cval) end
	
	-- re-insert if we have a Constant
	if cval ~= 0 then
		self:insertChild(1, Constant(cval))
	else
		-- if cval is zero and we're not re-inserting a constant
		-- then see if we have only one term ...
		if #self.xs == 1 then return prune(self.xs[1]) end
	end
	
	-- [[ x * c1 + x * c2 => x * (c1 + c2) ... for constants
	local muls = self.xs:filter(function(x) return x:isa(mulOp) end)
	if #muls > 1 then	-- we have more than one multiplication going on ... see if we can combine them
		local baseConst = 0
		local baseTerms
		local didntFind
		for _,mul in ipairs(muls) do
			local nonConstTerms = mul.xs:filter(function(x) return not x:isa(Constant) end)
			if not baseTerms then
				baseTerms = nonConstTerms
			else
				if not tableCommutativeEqual(baseTerms, nonConstTerms) then
					didntFind = true
					break
				end
			end
			local constTerms = mul.xs:filter(function(x) return x:isa(Constant) end)

			local thisConst = 1
			for _,const in ipairs(constTerms) do
				thisConst = thisConst * const.value
			end
			
			baseConst = baseConst + thisConst
		end
		if not didntFind then
			return prune(mulOp(baseConst, unpack(baseTerms)))
		end
	end
	--]]
	
	-- turn any a + (b * (c + d)) => a + (b * c) + (b * d)
	
	-- [[ if any two children are mulOps,
	--    and they have all children in common (with the exception of any constants)
	--  then combine them, and combine their constants
	-- x * c1 + x * c2 => x * (c1 + c2) (for c1,c2 constants)
	for i=1,#self.xs-1 do
		local xI = self.xs[i]
		local termsI
		if xI:isa(mulOp) then
			termsI = table(xI.xs)
		else
			termsI = table{xI}
		end
		for j=i+1,#self.xs do
			local xJ = self.xs[j]
			local termsJ
			if xJ:isa(mulOp) then
				termsJ = table(xJ.xs)
			else
				termsJ = table{xJ}
			end

			local fail
			
			local commonTerms = table()

			local constI
			for _,ch in ipairs(termsI) do
				if not termsJ:find(ch) then
					if ch:isa(Constant) then
						if not constI then
							constI = Constant(ch.value)
						else
							constI.value = constI.value + ch.value
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
						if ch:isa(Constant) then
							if not constJ then
								constJ = Constant(ch.value)
							else
								constJ.value = constJ.value + ch.value
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
				--print('optimizing from '..tostring(self))
				self:removeChild(j)
				self.xs[i] = mulOp(Constant(constI.value + constJ.value), unpack(commonTerms))
				--print('optimizing to '..tostring(prune(self)))
				return prune(self)
			end
		end
	end
	--]]
	
	--[[ factor out divs ...
	local denom
	local denomIndex
	for i,x in ipairs(self.xs) do
		if not x:isa(divOp) then
			denom = nil
			break
		else
			if not denom then
				denom = x.xs[2]
				denomIndex = i
			else
				if x.xs[2] ~= denom then
					denom = nil
					break
				end
			end
		end
	end
	if denom then
		self:removeChild(denomIndex)
		return prune(self / denom)
	end
	--]]
	
	-- trig identities

	-- cos(theta)^2 + sin(theta)^2 => 1
	-- TODO first get a working factor() function
	-- then replace all nodes of cos^2 + sin^2 with 1
	-- ... or of cos^2 with 1 - sin^2 and let the rest cancel out  (best to operate on one function rather than two)
	--  (that 2nd step possibly in a separate simplifyTrig() function of its own?)
	do
		local powOp = require 'symmath.powOp'
		local cos = require 'symmath.cos'
		local sin = require 'symmath.sin'
		local cosAngle, sinAngle
		local cosIndex, sinIndex
		for i=1,#self.xs do
			local x = self.xs[i]
			
			if x:isa(powOp)
			and x.xs[1]:isa(Function)
			and x.xs[2] == Constant(2)
			then
				if x.xs[1]:isa(cos) then
					if sinAngle then
						if sinAngle == x.xs[1].xs[1] then
							-- then remove sine and cosine and replace with a '1' and set modified
							self:removeChild(i)	-- remove largest index first
							self.xs[sinIndex] = Constant(1)
							return prune(self)
						end
					else
						cosIndex = i
						cosAngle = x.xs[1].xs[1]
					end
				elseif x.xs[1]:isa(sin) then
					if cosAngle then
						if cosAngle == x.xs[1].xs[1] then
							self:removeChild(i)
							self.xs[cosIndex] = Constant(1)
							return prune(self)
						end
					else
						sinIndex = i
						sinAngle = x.xs[1].xs[1]
					end
				end
			end
		end
	end
	
	return self
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

