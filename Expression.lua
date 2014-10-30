require 'ext'

local Expression = class()

Expression.precedence = 1
Expression.name = 'Expression'

function Expression:init(...)
	local ch = {...}
	self.xs = table()
	for i=1,#ch do
		local x = ch[i]
		if type(x) == 'number' then
			local Constant = require 'symmath.Constant'
			self.xs[i] = Constant(x)
		elseif type(x) == 'nil' then
			error("can't set a nil child")
		else
			self.xs[i] = x
		end
	end
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

-- get a flattened tree of all nodes
-- I don't know that I ever use this ...
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

function Expression.__concat(a,b)
	return tostring(a) .. tostring(b)
end

function Expression:__tostring()
	local symmath = require 'symmath'
	return symmath.toStringMethod(self)
end

--[[
compares metatable, children length, and children contents.
child order must match.  if your node type order doesn't matter then use nodeCommutativeEqual

this is used for comparing
for equality and solving, use .equals()
--]]
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

-- make sure to require Expression and then require the ops
function Expression.__unm(a) return (require 'symmath.unmOp')(a) end
function Expression.__add(a,b)
	local Constant = require 'symmath.Constant'
	if type(b) == 'number' then b = Constant(b) end
	local EquationOp = require 'symmath.EquationOp'
	if b:isa(EquationOp) then return b.__add(a,b) end
	return (require 'symmath.addOp')(a,b) 
end
function Expression.__sub(a,b) 
	local Constant = require 'symmath.Constant'
	if type(b) == 'number' then b = Constant(b) end
	local EquationOp = require 'symmath.EquationOp'
	if b:isa(EquationOp) then return b.__sub(a,b) end
	return (require 'symmath.subOp')(a,b) 
end
function Expression.__mul(a,b) 
	local Constant = require 'symmath.Constant'
	if type(b) == 'number' then b = Constant(b) end
	local EquationOp = require 'symmath.EquationOp'
	if b:isa(EquationOp) then return b.__mul(a,b) end
	return (require 'symmath.mulOp')(a,b) 
end
function Expression.__div(a,b) 
	local Constant = require 'symmath.Constant'
	if type(b) == 'number' then b = Constant(b) end
	local EquationOp = require 'symmath.EquationOp'
	if b:isa(EquationOp) then return b.__div(a,b) end
	return (require 'symmath.divOp')(a,b) 
end
function Expression.__pow(a,b) 
	local Constant = require 'symmath.Constant'
	if type(b) == 'number' then b = Constant(b) end
	local EquationOp = require 'symmath.EquationOp'
	if type(b) == 'table' and b.isa and b:isa(EquationOp) then return b.__pow(a,b) end
	return (require 'symmath.powOp')(a,b) 
end
function Expression.__mod(a,b) 
	local Constant = require 'symmath.Constant'
	if type(b) == 'number' then b = Constant(b) end
	local EquationOp = require 'symmath.EquationOp'
	if b:isa(EquationOp) then return b.__mod(a,b) end
	return (require 'symmath.modOp')(a,b) 
end

-- root-level functions that always apply to expressions
Expression.replace = require 'symmath.replace'
Expression.solve = require 'symmath.solve'
Expression.map = require 'symmath.map'
Expression.prune = function(...) return (require 'symmath.prune')(...) end
Expression.simplify = require 'symmath.simplify'
Expression.expand = function(...) return (require 'symmath.expand')(...) end
Expression.factor = function(...) return (require 'symmath.factor')(...) end
-- I have to buffer these by a function to prevent require loop
Expression.equals = function(...) return (require 'symmath.equals')(...) end
Expression.greaterThan = function(...) return (require 'symmath.greaterThan')(...) end
Expression.greaterThanOrEquals = function(...) return (require 'symmath.greaterThanOrEquals')(...) end
Expression.lessThan = function(...) return (require 'symmath.lessThan')(...) end
Expression.lessThanOrEquals = function(...) return (require 'symmath.lessThanOrEquals')(...) end

-- ... = list of equations
function Expression:subst(...)
	local self = self:clone()
	for _,eqn in ipairs{...} do
		self = self:replace(eqn:lhs(), eqn:rhs())
	end
	return self
end

return Expression
