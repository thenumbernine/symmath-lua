--[[
local self = require 'symmath.self'
x = self(x)

traverses x, child first, maps the nodes if they appear in the lookup table

the table can be expanded by adding an entry self.lookupTable[class] to perform the necessary transformation

I'm having second thoughts about putting all this here ...
maybe it should be member functions?
maybe all Expressions should have member functions that all visitors default to?
maybe all Expressions should have .visit = {[Prune] = function() ...} ?
this way these files don't explode in size as the number of objects do
and this way extensions don't have to modify the original symmath package
--]]
local Visitor = require 'symmath.visitor.Visitor'
local Prune = Visitor:subclass()
Prune.name = 'Prune'
return Prune
