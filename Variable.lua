local class = require 'ext.class'
local table = require 'ext.table'
local complex = require 'symmath.complex'
local Expression = require 'symmath.Expression'

--[[
fields:
	name = variable name
	dependentVars = table of vars that this var depends on
	value = (optional) value of this var ... as a Lua number
	set = what set does this variable belong to?

dependentVars = table of...
	table containing...
		src =
			= self	for dx/dy
			= TensorRef(self, ...) for dx^I/dy
		
		wrt =
			= var	for dx/dy
			= TensorRef(var, ...) for dx/dy^J

	So I am going to consider TensorRef(Variable) different from Variable
	But for now I'm not going to consider variance of TensorRef
--]]
local Variable = class(Expression)

Variable.precedence = 10	-- high since it will never have nested members 

Variable.name = 'Variable'

--[[
args:
	name = name of variable
	dependentVars = variables this var is dependent on
	value = numerical value of this variable
--]]
function Variable:init(name, dependentVars, value, set)
	self.name = name
	self.value = value
	if not set then
		if complex:isa(value) then 
			set = require 'symmath.set.sets'.complex
		elseif type(value) == 'number' then
			set = require 'symmath.set.sets'.real
		else
			-- default set ... Real or Universal?
			set = require 'symmath.set.sets'.real	
		end
	end
	self.set = set 
	if dependentVars then
		self:setDependentVars(table.unpack(dependentVars))
	end
end

-- return variable references ... so if the original gets modified, the rest will be updated as well
function Variable:clone()
	return self
end

-- same
function Variable:shallowCopy()
	return self
end

-- used for comma derivatives
-- override this to override for anholonomic basis
function Variable:applyDiff(x)
	return x:diff(self)
end

--[[ this is the same as Derivative.visitors.Prune.self
-- either is interoperable (right?)
-- (TODO double check this with the non-coordinate derivatives that are used to create commutation coefficients)
function Variable:evaluateDerivative(deriv, ...)
	local derivs = {...}
	if #derivs == 1 and derivs[1] == self then
		return require 'symmath.Constant'(1)
	end
	for i=1,#derivs do
		if derivs[i] == self then
			return require 'symmath.Constant'(0)
		end
	end
end
--]]

-- Variable equality is by name and value at the moment
-- this way log(e) fails to simplify, but log(symmath.e) simplifies to 1 
function Variable.match(a, b, matches)
	-- same as in Expression.match
	matches = matches or table()
	if b.wildcardMatches then
		if not b:wildcardMatches(a, matches) then return false end
		return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
	end
	if getmetatable(a) ~= getmetatable(b) then return false end

	-- what if it is a subclass?
	if a.name ~= b.name then return false end

	-- same as return true in Expression.match
	return (matches[1] or true), table.unpack(matches, 2, table.maxn(matches))
end

-- ok for performance's sake, since :match() is so slow, I'm overriding __eq
function Variable.__eq(a,b)
	return getmetatable(a) == getmetatable(b)
		and a.name == b.name
end

--[[
assign or concatenate?
Maxima would concatenate 
but that'd leave us no room to remove
so I'll assign
but I'll only assign for unique TensorRefs of self, so x'^i':setDependentVars(...) will clear all the other x'^i" setDependentVars but leave the x, x'^ij', etc setDependentVars based on # of tensor indexes
--]]
function Variable:setDependentVars(...)
	-- filter out setDependentVars() of matching # of tensorref indexes
	-- this way x:setDependentVars(y) and x'^i':setDependentVars(y) are separate
	if self.dependentVars then
		self.dependentVars = self.dependentVars:filter(function(depvar)
			return depvar.src ~= self
		end)
	else
		self.dependentVars = table()
	end
	self.dependentVars:append(table{...}:mapi(function(wrt)
		return {src=self, wrt=wrt}
	end))
	self:removeDuplicateDepends()
end

function Variable:removeDuplicateDepends()
	if self.dependentVars then
		for i=#self.dependentVars-2,1,-1 do
			local da = self.dependentVars[i]
			local db = self.dependentVars[i+1]
			if da.src == db.src
			and da.wrt == db.wrt
			then
				self.dependentVars:remove(i)
			end
		end
	end
end

-- only return true for the dependentVars entries with src==self
-- that match x (either Variable equals, or TensorRef with matching Variable and # of indexes)
function Variable:dependsOn(x)
	if x == self then return true end
	local TensorRef = require 'symmath.tensor.TensorRef'
	if self.dependentVars then
		for _,depvar in ipairs(self.dependentVars) do
			if depvar.src == self then
				local wrt = depvar.wrt
				
				if Variable:isa(x) and wrt == x then return true end
				
				if TensorRef:isa(x) 
				and TensorRef:isa(wrt)
				and x[1] == wrt[1]
				and #x == #wrt
				then
					return true
				end
			end
		end
	end
	return false
end

local RealDomain
function Variable:getRealDomain()
	if not rawequal(self.set, self.cachedSet) then self.cachedSet = nil end
	if self.cachedSet then return self.cachedSet end
	
	RealDomain = RealDomain or require 'symmath.set.RealDomain'
	if self.value then 
		if type(self.value) == 'number' then
			self.cachedSet = RealDomain(self.value, self.value, true, true)
			return self.cachedSet
		elseif complex:isa(self.value) and self.value.im == 0 then
			self.cachedSet = RealDomain(self.value.re, self.value.re, true, true)
			return self.cachedSet
		end
	end
	
	-- TODO why test this?  when won't it be true?
	if RealDomain:isa(self.set) then
		self.cachedSet = self.set
		return self.cachedSet
	end
	
	-- assuming start and finish are defined in all Real's subclasses
	-- what about Integer?  Integer's RealInterval is discontinuous ...
end

Variable.rules = {
	Eval = {
		{apply = function(eval, expr)
			if expr.value then 
				assert(type(expr.value) == 'number')
				return expr.value
			end
			error("Eval: Variable "..tostring(expr).." wasn't given a value, or replace()'d with a Constant")
		end},
	},
}

return Variable
