local class = require 'ext.class'
local Expression = require 'symmath.Expression'

local Wildcard = class(Expression)

function Wildcard:init(args)
	if type(args) == 'number' then
		self.index = args
	elseif type(args) == 'table' then
		self.index = args.index or 1
		-- use some field names that don't overlap with Expression methods like 'dependsOn'
		self.wildcardDependsOn = args.dependsOn
		self.wildcardCannotDependOn = args.cannotDependOn
		self.atLeast = args.atLeast
	elseif type(args) == 'nil' then
		self.index = 1
	end
end

function Wildcard:wildcardMatches(expr)
	-- if we said 'it must depend on var x' and it doesn't, then fail
	if self.wildcardDependsOn 
	and not expr:dependsOn(self.wildcardDependsOn)
	then
		return false
	end

	-- if we said 'it must not depend on var x' and it does, then fail
	if self.wildcardCannotDependOn
	and expr:dependsOn(self.wildcardCannotDependOn)
	then
		return false
	end

	return true
end

return Wildcard
