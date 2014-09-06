--[[

    File: symmath.lua 

    Copyright (C) 2000-2013 Christopher Moore (christopher.e.moore@gmail.com)
	  
    This software is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
  
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
  
    You should have received a copy of the GNU General Public License along
    with this program; if not, write the Free Software Foundation, Inc., 51
    Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--]]

module('symmath', package.seeall)

require 'ext'

verbose = false
simplifyConstantPowers = false	-- whether 1/3 stays or becomes .33333...
usePowerSymbol = true			-- whether to use a^b or pow(a,b).  This is a dirty trick to get around some dirtier regex converting compiled functions from one language to another.  A more proper fix would be to allow different backends to compile to.
simplifyDivisionByPower = false	-- whether to treat a/b as a*b^-1

function diff(y, ...)
	return Derivative(y, ...)
end

function prune(x)
	if type(x) ~= 'table' then return x end
	if x.prune then x = x:prune() or x end
	return x
end

function expand(x)
	if type(x) ~= 'table' then return x end
	if x.expand then x = x:expand() or x end
	return x
end

function factor(x, ...)
	if type(x) ~= 'table' then return x end
	if x.factor then x = x:factor(...) or x end
	return x
end

function simplify(x)
	local lastx
	for iter=1,10 do	
		lastx = x
		x = expand(x)
		x = prune(x)
		x = factor(x)
		x = prune(x)
		do break end -- calling expand() again after this breaks things ...
		--if x == lastx then break end
	end
	return x
end

--[[
expr = expression to change
find = sub-expression to find
repl = sub-expression to replace
callback(node) = callback per node, returns 'true' if we don't want to find/replace this tree
--]]
function replace(expr,find,repl,callback)
	if callback and callback(expr) then return expr:clone() end
	if expr.xs then
		local xs = table()
		for i=1,#expr.xs do
			local ch = replace(expr.xs[i],find,repl,callback)
			if ch == find then
				xs:insert(repl:clone())
			else
				xs:insert(ch)
			end
		end
		return getmetatable(expr)(unpack(xs))
	else
		return expr:clone()
	end
end

--[[
expr = expression to change
callback(node) = callback that returns nil if it leaves the tree untouched, returns a value if it wishes to change the tree
--]]
function map(expr, callback)
	local newexpr = callback(expr)
	if not newexpr then newexpr = expr:clone() end
	if newexpr.xs then
		for i=1,#newexpr.xs do
			newexpr.xs[i] = map(newexpr.xs[i], callback)
		end
	end
	return newexpr
end

--[[
replace variables with names as keys in evalmap with constants of the associated values
--]]
function evaluate(expr, evalmap)
	if evalmap then
		expr = map(expr, function(node)
			if node == nil then
				error("found a nil node in expression "..tostring(expr))
			end
			if not node:isa(Variable) then return end
			local newval = evalmap[node.name]
			if newval == nil then return end
			if type(newval) ~= 'number' then
				error("expected the values of the evaluation map to be numbers, but found "..node.name.." = ("..type(newval)..").."..tostring(newval))
			end
			return symmath.Constant(newval)
		end)
	end
	expr = simplify(expr)
	return expr:eval()
end

--[[
builds a lua function out of the expression
vars - specifies the list of variables that will associate with function input parameters
if there are any Derivatives or variables (other those listed) then compiling will produce an error
so if you have any derivs you want as function parameters, use map() or replace() to replace them for new variables
	and then put them in the vars list
--]]
function compile(expr, vars)
	return ToLuaCode:compile(expr, vars)
end

--[[ potential new system based on breadth-first search ... not finished yet

local rules = {
	function(expr)
		
	end,
}


function applyRuleAtNode(expr, node, rule)
	expr = expr:clone()
	
	-- find 'node' in 'expr'
	-- replace it with 'prune(node)'
	if node == expr then
		return rule:apply(expr)
	end

	local parent, index = expr:findChild(node)
	parent.xs[index] = rule(parent.xs[index])
	return expr
end

function applyRulesAtNode(expr, node)
	for _,rule in ipairs(rules) do
		applyRuleAtNode(expr, node, rule)
	end
end

function simplify(firstExpr)
	local allExprs = table{firstExpr:clone()}
	local currentExprs = table{firstExpr:clone()}
	local tries = 0
	while #currentExprs > 0 do
		local expr = currentExprs:remove(1)
		local nodes = expr:getAllNodes()
		for i=1,#nodes do
			local newExprs = applyRulesAtNode(expr, nodes[i])
			for _,newExpr in ipairs(newExprs) do
				if not allExprs:find(newExpr) then
					allExprs:insert(newExpr)
					currentExprs:insert(newExpr)
				end
			end
		end
		tries = tries + 1
		if tries > 10 then break end
	end
	local smallestNodes
	local smallestExpr
	for _,expr in ipairs(currentExpr) do
		local numNodes = #expr:getAllNodes()
		if not smallestNodes or numNodes < smallestNodes then
			smallestNodes = numNodes
			smallestExpr = expr
		end
	end
	return smallestExpr
end

--]]

function precedence(x)
	if x.precedence then return x.precedence end
	return 10
end

Expression = class()

Expression.precedence = 1
Expression.name = 'Expression'

function Expression:init(...)
	self.xs = table()
	self:setChildren(...)
end

function Expression:clone()
	if self.xs then
		local xs = table()
		for i=1,#self.xs do
			xs:insert(self.xs[i]:clone())
		end
		return getmetatable(self)(unpack(xs))
	else
		return getmetatable(self)()
	end
end

function Expression:getAllNodes()
	-- add current nodes
	local nodes = table{self}
	-- add child nodes
	if self.xs then
		for _,x in ipairs(self.xs) do
			nodes:append(x:getAllNodes())
		end
	end
	-- done
	return nodes
end

function Expression:findChild(node)
	-- how should I distinguish between find saying "not in our tree" and "it is ourself!"
	if node == self then error("looking for self") end
	for i,x in ipairs(self.xs) do
		-- if it's this node then return its info
		if x == node then return self, i end
		-- check children recursively
		local parent, index = x:findChild(node)
		if parent then return parent, index end
	end
end

-- currently an in-place optimization 
-- returns self if it didn't change
function Expression:prune() return self end
function Expression:expand() return self end
function Expression:factor() return self end

function Expression:setChildren(...)
	local ch = {...}
	for i=1,#ch do
		local x = ch[i]
		if type(x) == 'number' then
			self:setChild(i, Constant(x))
		elseif type(x) == 'nil' then
			error("can't set a nil child")
		else
			self:setChild(i, x)
		end
	end
end

function Expression:setChild(index, child)
	if child then child.parent = self end
	self.xs[index] = child
end

-- notice: table.insert uses the lua C api whic can count nil args, but lua script can't ...
function Expression:insertChild(...)
	local index, child = ...
	if not child then child = index end
	child.parent = self
	self.xs:insert(...)
end

function Expression:removeChild(index)
	local n = self.xs:remove(index)
	if n then n.parent = nil end
	return n
end

function Expression.__concat(a,b)
	return tostring(a) .. tostring(b)
end

function Expression:__tostring()
	return toStringMethod(self)
end

-- TODO
-- this is a boolean comparison
-- make a separate function for that
-- and use __eq for an equivalence expression (to subsequently solve for variables)
function Expression.__eq(a,b)
	if getmetatable(a) ~= getmetatable(b) then return false end
	if a.xs == nil ~= b.xs == nil then return false end
	if a.xs and b.xs then
		if #a.xs ~= #b.xs then return false end
		for i=1,#a.xs do
			if a.xs[i] ~= b.xs[i] then return false end
		end
		return true
	end
	error("tried to use generic compare on two objects without child nodes: "..a.." and "..b)
end

--[[ with simplification upon assignment ... some aren't working properly
function Expression.__unm(a) return simplify(unmOp(a)) end
function Expression.__add(a,b) return simplify(addOp(a,b)) end
function Expression.__sub(a,b) return simplify(subOp(a,b)) end
function Expression.__mul(a,b) return simplify(mulOp(a,b)) end
function Expression.__div(a,b) return simplify(divOp(a,b)) end
function Expression.__pow(a,b) return simplify(powOp(a,b)) end
function Expression.__mod(a,b) return simplify(modOp(a,b)) end
--]]
-- [[ without
function Expression.__unm(a) return unmOp(a) end
function Expression.__add(a,b) return addOp(a,b) end
function Expression.__sub(a,b) return subOp(a,b) end
function Expression.__mul(a,b) return mulOp(a,b) end
function Expression.__div(a,b) return divOp(a,b) end
function Expression.__pow(a,b) return powOp(a,b) end
function Expression.__mod(a,b) return modOp(a,b) end
--]]

local function tableCommutativeEqual(ac,bc)
	-- order-independent
	ac = table(ac)
	bc = table(bc)
	for ai=#ac,1,-1 do
		local bi = bc:find(ac[ai])
		if bi then
			ac:remove(ai)
			bc:remove(bi)
		end
	end
	return #ac == 0 and #bc == 0
end

local function nodeCommutativeEqual(a,b)
	return tableCommutativeEqual(a.xs, b.xs)
end



Constant = class(Expression)
Constant.precedence = 10	-- high since it can't have child nodes 
Constant.name = 'Constant'


function Constant:init(value)
	if type(value) ~= 'number' then
		error('tried to init constant with non-number type '..type(value)..debug.traceback())
	end
	self.value = value
end

function Constant:clone()
	return Constant(self.value)
end

-- this won't be called if a prim is used ...
function Constant.__eq(a,b)
	local va, vb
	if getmetatable(a) == Constant then va = a.value else va = tonumber(a) end
	if getmetatable(b) == Constant then vb = b.value else vb = tonumber(b) end
	return va == vb
end

function Constant:toVerboseStr()
	return 'Constant['..tostring(self.value)..']'
end

function Constant:diff(...)
	return Constant(0)
end

function Constant:eval()
	return self.value
end


Invalid = class(Expression)

Invalid.name = 'Invalid'

-- true to NaNs
function Invalid.__eq(a,b)
	return false
end

function Invalid:diff(...)
	return self
end

function Invalid:eval()
	return 0/0	--nan
end


Function = class(Expression)
Function.precedence = 10	-- high since it will always show parenthesis
Function.name = 'Function'

--[[ evaluate functions?
function Function:prune()
	self.xs[1] = prune(self.xs[1])
	if self.xs[1]:isa(Constant) then
		return Constant(self.func(self.xs[1].value))
	end
	return func.super.prune(self)
end
--]]

function Function:eval()
	return self.func(unpack(self.xs:map(function(node) return node:eval() end)))
end

function Function:toVerboseStr()
	return 'Function{'..self.name..'}[' .. self.xs:map(tostring):concat(', ') .. ']'
end

function Function:prune()
	local f = self:clone()
	f.xs = f.xs:map(function(x) return simplify(x) end)
	return f
end

sqrt = class(Function)
sqrt.name = 'sqrt'
sqrt.func = math.sqrt
function sqrt:diff(...)
	local x = unpack(self.xs)
	return Constant(.5) * diff(x,...) / sqrt(x)
end

log = class(Function)
log.name = 'log'
log.func = math.log
function log:diff(...)
	local x = unpack(self.xs)
	return diff(x,...) / x
end

exp = class(Function)
exp.name = 'exp'
exp.func = math.exp
function exp:diff(...)
	local x = unpack(self.xs)
	return diff(x,...) * x
end

cos = class(Function)
cos.name = 'cos'
cos.func = math.cos
function cos:diff(...)
	local x = unpack(self.xs)
	return -diff(x,...) * sin(x)
end

sin = class(Function)
sin.name = 'sin'
sin.func = math.sin
function sin:diff(...)
	local x = unpack(self.xs)
	return diff(x,...) * cos(x)
end

tan = class(Function)
tan.name = 'tan'
tan.func = math.tan
function tan:diff(...)
	local x = unpack(self.xs)
	return diff(x,...) / (cos(x)^2)
end

asin = class(Function)
asin.name = 'asin'
asin.func = math.asin
function asin:diff(...)
	local x = unpack(self.xs)
	return diff(x,...) / sqrt(1 - x^2)
end

acos = class(Function)
acos.name = 'acos'
acos.func = math.acos
function acos:diff(...)
	local x = unpack(self.xs)
	return -diff(x,...) / sqrt(1 - x^2)
end

atan = class(Function)
atan.name = 'atan'
atan.func = math.atan
function atan:diff(...)
	local x = unpack(self.xs)
	return diff(x,...) / (1 + x^2)
end

atan2 = class(Function)
atan2.name = 'atan2'
atan2.func = math.atan2
function atan2:diff(...)
	local y, x = unpack(self.xs)
	return diff(y/x, ...) / (1 + (y/x)^2)
end


-- could be a function?
unmOp = class(Expression)
unmOp.precedence = 4

function unmOp:diff(...)
	local x = unpack(self.xs)
	x = prune(x)
	return -diff(x,...)
end

function unmOp:eval()
	return -self.xs[1]:eval()
end

--[[
function unmOp:prune()
	self.xs[1] = prune(self.xs[1])
	
	if self.xs[1]:isa(Constant) then
		return Constant(-self.xs[1].value)
	end

	-- -(-a) = a
	if self.xs[1]:isa(unmOp) then
		return prune(self.xs[1].xs[1])
	end

	return self
end
--]]
function unmOp:prune()
	return prune(Constant(-1) * self.xs[1])
end

function unmOp:expand()
	return expand(Constant(-1) * self.xs[1])
end

function unmOp:toVerboseStr()
	return 'unm('..self.xs[1]:toSingleLineStr()..')'
end


BinaryOp = class(Expression)

function BinaryOp:prune()
	for i=1,#self.xs do
		self.xs[i] = prune(self.xs[i])
	end
	return BinaryOp.super.prune(self)
end

function BinaryOp:expand()
	for i=1,#self.xs do
		self.xs[i] = expand(self.xs[i])
	end
	return BinaryOp.super.expand(self)
end

function BinaryOp:toVerboseStr()
	return 'BinaryOp{'..self.name..'}['..self.xs:map(tostring):concat(', ')..']'
end

function BinaryOp:getSepStr()
	local sep = self.name
	if self.implicitName then 
		sep = ' '
	elseif not self.omitSpace then 
		sep = ' ' .. sep .. ' ' 
	end
	return sep
end


addOp = class(BinaryOp)
addOp.precedence = 2
addOp.name = '+'

function addOp:diff(...)
	local result = addOp()
	for i=1,#self.xs do
		result:setChild(i, diff(self.xs[i], ...))
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
				self:setChild(i, mulOp(Constant(constI.value + constJ.value), unpack(commonTerms)))
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
	do
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
							self:setChild(sinIndex, Constant(1))
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
							self:setChild(cosIndex, Constant(1))
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

addOp.__eq = nodeCommutativeEqual


subOp = class(BinaryOp)
subOp.precedence = 2
subOp.name = '-'

function subOp:diff(...)
	local a, b = unpack(self.xs)
	local x = diff(a,...) - diff(b,...)
--	x = prune(x)
	return x
end

function subOp:eval()
	local result = self.xs[1]:eval()
	for i=2,#self.xs do
		result = result - self.xs[i]:eval()
	end
	return result
end

function subOp:prune()
	for i=1,#self.xs do
		self.xs[i] = prune(self.xs[i])
	end
	
	return prune(self.xs[1] + (-self.xs[2]))
end


mulOp = class(BinaryOp)
mulOp.implicitName = true
mulOp.precedence = 3
mulOp.name = '*'

function mulOp:diff(...)
	local sumRes = addOp()
	for i=1,#self.xs do
		local termRes = mulOp()
		for j=1,#self.xs do
			if i == j then
				termRes:insertChild(diff(self.xs[j], ...))
			else
				termRes:insertChild(self.xs[j])
			end
		end
		sumRes:insertChild(termRes)
	end
--	sumRes = prune(sumRes)
	return sumRes
end

function mulOp:eval()
	local result = 1
	for _,x in ipairs(self.xs) do
		result = result * x:eval()
	end
	return result
end

function mulOp:expand()
	local res = self:applyDistribute()
	if res then return res end
	return self
end

function mulOp:prune()
	assert(#self.xs > 0)
	if #self.xs == 1 then return prune(self.xs[1]) end

	-- prune children
	for i=1,#self.xs do
		self.xs[i] = prune(self.xs[i])
	end
	
	-- flatten multiplications
	for i=#self.xs,1,-1 do
		local ch = self.xs[i]
		if ch:isa(mulOp) then
			-- this looks like a job for splice ...
			self:removeChild(i)
			for _,chch in ipairs(ch.xs) do
				self:insertChild(i, chch)
			end
		end
	end

	-- move unary minuses up
	do
		local unmOpCount = 0
		for i=1,#self.xs do
			local ch = self.xs[i]
			if ch:isa(unmOp) then
				unmOpCount = unmOpCount + 1
				self:setChild(i, ch.xs[1])
			end
		end
		if unmOpCount % 2 == 1 then
			return prune(-self)
		elseif unmOpCount ~= 0 then
			return prune(self)
		end
	end

	-- push all Constants to the lhs, sum as we go
	local cval = 1
	for i=#self.xs,1,-1 do
		if self.xs[i]:isa(Constant) then
			cval = cval * self:removeChild(i).value
		end
	end

	-- if it's all constants then return what we got
	if #self.xs == 0 then return Constant(cval) end
	
	if cval == 0 then return Constant(0) end
	
	if cval ~= 1 then
		self:insertChild(1, Constant(cval))
	else
		if #self.xs == 1 then return prune(self.xs[1]) end
	end
	
	-- [[ a^m * a^n => a^(m + n)
	do
		local modified = false
		local i = 1
		while i <= #self.xs do
			local x = self.xs[i]
			local base
			local power
			if x:isa(powOp) then
				base = x.xs[1]
				power = x.xs[2]
			else
				base = x
				power = Constant(1)
			end
			
			if base then
				local j = i + 1
				while j <= #self.xs do
					local x2 = self.xs[j]
					local base2
					local power2
					if x2:isa(powOp) then
						base2 = x2.xs[1]
						power2 = x2.xs[2]
					else
						base2 = x2
						power2 = Constant(1)
					end
					if base2 == base then
						modified = true
						self:removeChild(j)
						j = j - 1
						power = power + power2
					end
					j = j + 1
				end
				if modified then
					self:setChild(i, base ^ power)
				end
			end
			i = i + 1
		end
		if modified then
			return prune(self)
		end
	end
	--]]
	
	-- [[ factor out denominators: a * b * (c / d) => (a * b * c) / d
	local denoms = table()
	for i=#self.xs,1,-1 do
		local x = self.xs[i]
		if x:isa(divOp) then
			self:setChild(i, x.xs[1])
			denoms:insert(x.xs[2])
		end
	end
	if #denoms > 0 then
		return prune(self / mulOp(unpack(denoms)))
	end
	--]]
	
	--[[ moved to expand()
	do
		local res = self:applyDistribute()
		if res then return res end
	end
	--]]
		
	return self
end

function mulOp:expand()
	local res = self:applyDistribute()
	if res then return res end
	return self
end

--[[
a * (b + c) * d * e becomes
(a * b * d * e) + (a * c * d * e)
--]]
function mulOp:applyDistribute()
	for i,x in ipairs(self.xs) do
		if x:isa(addOp) or x:isa(subOp) then
			local terms = table()
			for j,xch in ipairs(x.xs) do
				local term = self:clone()
				term.xs[i] = xch:clone()
				terms:insert(term)
			end
			return getmetatable(x)(unpack(terms))
		
			--[[
			local newSelf = getmetatable(x)(unpack(self.xs:filter(function(cx) 
				return cx ~= x
			end):map(function(cx)
				return mulOp(x:clone(), cx)
			end))
			--]]
			--[[
			local removedTerm = newSelf.xs:remove(i)
			print('removed ',removedTerm)
			local newe = expand(addOp(unpack(
				x.xs:map(function(addX)
					return mulOp(addX, unpack(newSelf))
				end)
			)))
			print('new expand',newe)
			return newe
			--]]
		end
	end
	
	--[[
	--do return self end

	-- distribute: a * (m + n) => a * m + a * n
	-- I have the opposite rule in addOp:prune, commented out
	-- to combine them both ...
	-- (a * (b + c * (d + e)) => (a * b + a * c * d + a * c * e)
	-- how about my canonical form is div, mul-non-const, add, mul-const
	-- ... such that if we have an add, mul-non-const then we know to perform the addOp:prune() on it
	-- however trig laws would need add, mul-non-const to optimize out correctly
	for i,x in ipairs(self.xs) do
		if x:isa(addOp) then
			self:removeChild(i)
		
			local result = addOp()
			for j,ch in ipairs(x.xs) do
				result:setChild(j, self * ch)
			end
			--result = prune(result)
			return result
		end
	end
	--]]
end

mulOp.__eq = nodeCommutativeEqual


divOp = class(BinaryOp)
divOp.precedence = 3
divOp.name = '/'

function divOp:diff(...)
	local a, b = unpack(self.xs)
	local x = (diff(a, ...) * b - a * diff(b, ...)) / (b * b)
--	x = prune(x)
	return x
end

function divOp:eval()
	local a, b = unpack(self.xs)
	return a:eval() / b:eval()
end

-- [==[
function divOp:prune()
	if simplifyDivisionByPower then
		return simplify(mulOp(self.xs[1], powOp(self.xs[2], Constant(-1))))
	end

	-- prune children
	for i=1,#self.xs do
		self.xs[i] = prune(self.xs[i])
	end

	-- move unary minuses up
	do
		local unmOpCount = 0
		for i=1,#self.xs do
			local ch = self.xs[i]
			if ch:isa(unmOp) then
				unmOpCount = unmOpCount + 1
				self:setChild(i, ch.xs[1])
			end
		end
		if unmOpCount % 2 == 1 then
			return prune(-self)
		elseif unmOpCount ~= 0 then
			return prune(self)
		end
	end
	
	-- x / 0 => Invalid
	if self.xs[2] == Constant(0) then
		return Invalid()
	end
	
	-- Constant / Constant => Constant
	if simplifyConstantPowers  then
		if self.xs[1]:isa(Constant) and self.xs[2]:isa(Constant) then
			return Constant(self.xs[1].value / self.xs[2].value)
		end
	end
	
	-- 0 / x => 0
	if self.xs[1]:isa(Constant) then
		if self.xs[1].value == 0 then
			return Constant(0)
		end
	end
	
	-- (a / b) / c => a / (b * c)
	if self.xs[1]:isa(divOp) then
		return prune(self.xs[1].xs[1] / (self.xs[1].xs[2] * self.xs[2]))
	end
	
	-- a / (b / c) => (a * c) / b
	if self.xs[2]:isa(divOp) then
		return prune((self.xs[1] * self.xs[2].xs[1]) / self.xs[2].xs[2])
	end
	
--[[
	-- (r^m * a * b * ...) / (r^n * x * y * ...) => (r^(m-n) * a * b * ...) / (x * y * ...)
	do
		local modified
		local nums, denoms
		if self.xs[1]:isa(mulOp) then
			nums = table(self.xs[1].xs)
		else
			nums = table{self.xs[1]}
		end
		if self.xs[2]:isa(mulOp) then
			denoms = table(self.xs[2].xs)
		else
			denoms = table{self.xs[2]}
		end
		local function listToBasesAndPowers(list)
			local bases = table()
			local powers = table()
			for i=1,#list do
				local x = list[i]
				local base, power
				if x:isa(powOp) then
					base, power = unpack(x.xs)
				else
					base, power = x, Constant(1)
				end
				bases[i] = base
				powers[i] = power
			end
			return bases, powers
		end
		local numBases, numPowers = listToBasesAndPowers(nums)
		local denomBases, denomPowers = listToBasesAndPowers(denoms)
		for i=1,#nums do
			local j = 1
			while j <= #denoms do
				if numBases[i] == denomBases[j] then
					modified = true
					local resultPower = numPowers[i] - denomPowers[j]
					numPowers[i] = resultPower
					denoms:remove(j)
					denomBases:remove(j)
					denomPowers:remove(j)
					j=j-1
				end
				j=j+1
			end
		end
		if modified then
			if #numBases == 0 and #denomBases == 0 then return Constant(1) end

			-- can I construct these even if they have no terms?
			local num
			if #numBases > 0 then
				num = mulOp(unpack(numBases:map(function(v,i) return v ^ numPowers[i] end)))
			end
			local denom
			if #denomBases > 0 then
				denom = mulOp(unpack(denomBases:map(function(v,i) return v ^ numPowers[i] end)))
			end
			
			local result
			if #numBases == 0 then
				result = Constant(1) / denom
			elseif #denomBases == 0 then
				result = num
			else
				result = num / denom
			end
			
			return prune(result)
		end
	end
--]]

--[[
	-- x / x => 1
	if self.xs[1] == self.xs[2] then
		if self.xs[1] == Constant(0) then
			-- undefined...
		else
			return Constant(1)
		end
	end
	
	-- x / x^a => x^(1-a)
	if self.xs[2]:isa(powOp) and self.xs[1] == self.xs[2].xs[1] then
		return prune(self.xs[1] ^ (1 - self.xs[2].xs[2]))
	end
	
	-- x^a / x => x^(a-1)
	if self.xs[1]:isa(powOp) and self.xs[1].xs[1] == self.xs[2] then
		return prune(self.xs[1].xs[1] ^ (self.xs[1].xs[2] - 1))
	end
	
	-- x^a / x^b => x^(a-b)
	if self.xs[1]:isa(powOp)
	and self.xs[2]:isa(powOp)
	and self.xs[1].xs[1] == self.xs[2].xs[1]
	then
		return prune(self.xs[1].xs[1] ^ (self.xs[1].xs[2] - self.xs[2].xs[2]))
	end
--]]

	return self
--]=]
end

powOp = class(BinaryOp)
powOp.omitSpace = true
powOp.precedence = 5
powOp.name = '^'

--[[
d/dx(a^b)
d/dx(exp(log(a^b)))
d/dx(exp(b*log(a)))
exp(b*log(a)) * d/dx[b*log(a)]
a^b * (db/dx * log(a) + b * d/dx[log(a)])
a^b * (db/dx * log(a) + da/dx * b / a)
--]]
function powOp:diff(...)
	local a, b = unpack(self.xs)
	local x = a ^ b * (diff(b, ...) * log(a) + diff(a, ...) * b / a)
--	x = prune(x)
	return x
end

function powOp:eval()
	local a, b = unpack(self.xs)
	return a:eval() ^ b:eval()
end

function powOp:prune()
	for i=1,#self.xs do
		self.xs[i] = prune(self.xs[i])
	end

	if simplifyConstantPowers then
		if self.xs[1]:isa(Constant) and self.xs[2]:isa(Constant) then
			return Constant(self.xs[1].value ^ self.xs[2].value)
		end
	end
	
	-- 1^a => 1
	if self.xs[1] == Constant(1) then return Constant(1) end
	
	-- (-1)^odd = -1, (-1)^even = 1
	if self.xs[1] == Constant(-1) and self.xs[2]:isa(Constant) then
		local powModTwo = self.xs[2].value % 2
		if powModTwo == 0 then return Constant(1) end
		if powModTwo == 1 then return Constant(-1) end
	end
	
	-- a^1 => a
	if self.xs[2] == Constant(1) then return prune(self.xs[1]) end
	
	-- a^0 => 1
	if self.xs[2] == Constant(0) then return Constant(1) end
	
	-- (a ^ b) ^ c => a ^ (b * c)
	if self.xs[1]:isa(powOp) then
		return prune(self.xs[1].xs[1] ^ (self.xs[1].xs[2] * self.xs[2]))
	end
	
	-- (a * b) ^ c => a^c * b^c
	if self.xs[1]:isa(mulOp) then
		return prune(mulOp(unpack(self.xs[1].xs:map(function(v) return v ^ self.xs[2] end))))
	end
	
	--[[ for simplification's sake ... (like -a => -1 * a)
	-- x^c => x*x*...*x (c times)
	if self.xs[2]:isa(Constant)
	and self.xs[2].value > 0 
	and self.xs[2].value == math.floor(self.xs[2].value)
	then
		local m = mulOp()
		for i=1,self.xs[2].value do
			m:insertChild( self.xs[1]:clone())
		end
		
		return prune(m)
	end
	--]]

	return self
end

function powOp:expand()
	local maxPowerExpand = 10
	if self.xs[2]:isa(Constant) then
		local value = self.xs[2].value
		local absValue = math.abs(value)
		if absValue < maxPowerExpand then
			local num, frac, div
			if value < 0 then
				div = true
				frac = math.ceil(value) - value
				num = -math.ceil(value)
			elseif value > 0 then
				frac = value - math.floor(value)
				num = math.floor(value)
			else
				return Constant(1)
			end
			local terms = table()
			for i=1,num do
				terms:insert(self.xs[1]:clone())
			end
			if frac ~= 0 then
				terms:insert(self.xs[1]:clone()^frac)
			end
			if div then
				return Constant(1)/mulOp(unpack(terms))
			else
				return mulOp(unpack(terms))
			end
		end
	end
	return self
end

modOp = class(BinaryOp)
modOp.precedence = 3
modOp.name = '%'

--[[
d/dx[a%b] is da/dx, except when a = b * k for some integer k
--]]
function modOp:diff(...)
	local a, b = unpack(self.xs)
	local x = diff(a, ...)
--	x = prune(x)
	return x
end

function modOp:eval()
	local a, b = unpack(self.xs)
	return a:eval() % b:eval()
end


Variable = class(Expression)
Variable.precedence = 10	-- high since it will never have nested members 
Variable.name = 'Variable'
variable = Variable	-- shorthand / case convention

function Variable:init(name, value, deferDiff)
	self.name = name
	if not (type(value) == 'number' or type(value) == 'nil') then
		error("got a bad value "..tostring(value))
	end
	self.value = value
	self.deferDiff = deferDiff
end

function Variable:clone()
	return Variable(self.name, self.value, self.deferDiff)
end

function Variable:diff(...)
	local diffs = table{...}
	if #diffs == 1 and diffs[1] == self then
		return Constant(1)
	end
	if self.deferDiff then
		-- deferDiff is set
		-- we know we have more than one diffs
		-- and one of them is 1 ... so d/danything[1] = 0
		if diffs:find(self) then return Constant(0) end
		return Derivative(self, ...)	-- preserve
	end
	return Constant(0)
end

function Variable:eval()
	local v = tonumber(self.value)
	if not v then
		error("tried to evaluate a variable "..self.." without a value set")
	end
	return v
end

function Variable:toVerboseStr()
	local s = 'Variable['..self.name..']'
	if self.value then
		s = s .. '|' .. self.value
	end
	return s
end

function Variable.__eq(a,b)
	if getmetatable(a) ~= getmetatable(b) then return false end
	return a.name == b.name
end

--[[
xs[1] is the expression
all subsequent xs's are variables
--]]
Derivative = class(Expression)
Derivative.precedence = 5

function Derivative:init(...)
	local ch = table{...}
	local y = ch:remove(1)
	for _,x in ipairs(ch) do
		assert(x and type(x) == 'table' and x.isa and x:isa(Variable), "diff() expected wrt expressions to be a variable")
	end
	ch:sort(function(a,b) return a.name < b.name end)
	Derivative.super.init(self, y, unpack(ch))
end

function Derivative:eval()
	error("cannot evaluate derivatives.  try calling prune() first")
end

function Derivative:prune()
	if self.xs[1]:isa(Constant) then
		return Constant(0)
	end

	for i=1,#self.xs do
		self.xs[i] = simplify(self.xs[i])
	end

	if self.xs[1]:isa(Derivative) then
		return simplify(Derivative(self.xs[1].xs[1], unpack(
			table.append({unpack(self.xs, 2)}, {unpack(self.xs[1].xs, 2)})
		)))
	end

	if not (self.xs[1]:isa(Variable) and self.xs[1].deferDiff) then
	-- ... and if we're not lazy-evaluating the derivative of this with respect to other variables ...
		assert(self.xs[1].diff, "failed to differentiate "..tostring(self.xs[1]).." with type "..type(self.xs[1]))
		local result = self.xs[1]:diff(unpack(self.xs, 2))
		result = simplify(result)
		return result
	else
		if self.xs[1]:isa(Variable) then
			-- deferred diff ... at least optimize out the dx/dx = 1
			if #self.xs == 2 
			and self.xs[1] == self.xs[2]
			then
				return Constant(1)
			end
		end
	end

	return self
end

function Derivative:toVerboseStr()
	return self:toSingleLineStr()
end

-- equality
-- I would use binary operators for this, but Lua's overloading requires the return value be a boolean

EquationOp = class(BinaryOp)
EquationOp.__eq = nodeCommutativeEqual

function EquationOp:diff(...)
	local result = getmetatable(self)()
	for i=1,#self.xs do
		result:setChild(i, diff(self.xs[i], ...))
	end
	return result
end

equals = class(EquationOp)
equals.name = '='

lessThan = class(EquationOp)
lessThan.name = '<'

greaterThan = class(EquationOp)
greaterThan.name = '>'

lessThanOrEquals = class(EquationOp)
lessThanOrEquals.name = '<='

greaterThanOrEquals = class(EquationOp)
greaterThanOrEquals.name = '>='


-- always need this
-- but need to define all the above operations first
require 'symmath.tostring'

