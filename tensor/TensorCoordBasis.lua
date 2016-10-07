--[[
TensorCoordBasis represents an entry in the coordSrcs
complete with
	variables - table of what variables are in this basis 
	symbols - what symbols are used to representing this basis 
			symbols == nil means all symbols
	(c) what metrics are used for raising/lowering
	[(d)] what linear transforms go between this and the other TensorCoordBasis's
--]]
local class = require 'ext.class'
local table = require 'ext.table'
local TensorCoordBasis = class()

function TensorCoordBasis:init(args)
	self.variables = assert(args.variables)
	if args.symbols and #args.symbols > 0 then
		self.symbols = table()
		for i=1,#args.symbols do
			self.symbols[i] = args.symbols:sub(i,i)
		end
	end
	local clone = require 'symmath.clone'
	local Matrix = require 'symmath.Matrix'
	if args.metric then
		self.metric = Matrix(table.unpack(args.metric))
	end
	if args.metricInverse then
		self.metricInverse = Matrix(table.unpack(args.metricInverse))
	else
		if self.metric then
			self.metricInverse = Matrix.inverse(self.metric)
		end
	end
	-- TODO inter-basis transforms as well?  i.e. vielbein would be the inter-transform from curved coords to Minkowski coords 
end

return TensorCoordBasis
