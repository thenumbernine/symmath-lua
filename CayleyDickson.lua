local string = require 'ext.string'
local table = require 'ext.table'
local assert = require 'ext.assert'
-- my old library, I might phase out and merge fully into here, cuz there's a lot of random scripts in there...
local CayleyDickson = require 'cayley-dickson'

local Expression = require 'symmath.Expression'

local CayleyDicksonBasis = Expression:subclass()

CayleyDicksonBasis.name = 'CayleyDicksonBasis'
CayleyDicksonBasis.precedence = 10

function CayleyDicksonBasis:init(cayleyDicksonBasisList, index)
	self.cayleyDicksonBasisList = cayleyDicksonBasisList
	self.index = assert.type(index, 'number')

	-- maybe deduce this from the mul table itself? or nah, it will just tell us what we know here already:
	local n = #cayleyDicksonBasisList.impl	-- dimension of underlying multiplication table
	self.mulNonCommutative = n >= 4	-- quaternions lose commutativity
	self.mulNonAssociative = n >= 8	-- octonions lose associativity
end

function CayleyDicksonBasis:clone()
	return CayleyDicksonBasis(self.cayleyDicksonBasisList, self.index)
end

function CayleyDicksonBasis.__eq(a,b)
	return getmetatable(a) == getmetatable(b)
	and a.index == b.index
end

CayleyDicksonBasis.__concat = string.concat

function CayleyDicksonBasis:__tostring()
	return 'e'..self.index
end


--[[
create a tuple of Cayley-Dickson constructions
n = such that 2^n is how many basis elements
--]]
-- TODO maybe subclass-and-cache different dimensions of n, and generate their mulNonCommutative/mulNonAssociative accordingly (instead of storing as a member element)
local function makeCayleyDickson(n)
	local cd = CayleyDickson(n)
	local cayleyDicksonBasisList = table{impl=cd}
	for i=1,#cd do
		cayleyDicksonBasisList:insert(CayleyDicksonBasis(cayleyDicksonBasisList, i-1))
	end
	return cayleyDicksonBasisList
end

local CayleyDickson = setmetatable({}, {
	__call=function(mt, ...)
		return makeCayleyDickson(...)
	end,
})

CayleyDickson.Basis = CayleyDicksonBasis

return CayleyDickson
