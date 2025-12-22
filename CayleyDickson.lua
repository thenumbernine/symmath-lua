local string = require 'ext.string'
local table = require 'ext.table'
local assert = require 'ext.assert'
-- my old library, I might phase out and merge fully into here, cuz there's a lot of random scripts in there...
local CayleyDickson = require 'cayley-dickson'

local Expression = require 'symmath.Expression'

local CayleyDicksonBasis = Expression:subclass()

CayleyDicksonBasis.name = 'CayleyDicksonBasis'
CayleyDicksonBasis.precedence = 10
CayleyDicksonBasis.mulNonCommutative = true
CayleyDicksonBasis.mulNonAssociative = true

function CayleyDicksonBasis:init(cayleyDicksonBasisList, index)
	self.cayleyDicksonBasisList = cayleyDicksonBasisList
	self.index = assert.type(index, 'number')
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
local function makeCayleyDickson(n)
	local cd = CayleyDickson(n)
	local cayleyDicksonBasisList = table{impl=cd}
	for i=1,#cd do
		local e = CayleyDicksonBasis(cayleyDicksonBasisList, i-1)
		cayleyDicksonBasisList:insert(e)
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
