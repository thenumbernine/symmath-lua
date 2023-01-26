return function(expr)
	local chart = require 'symmath.tensor.Manifold':findChartForSymbol()

	-- TODO look up signatures and coords
	print'FINISHME'
end

-- TODO TODO
-- expr:diff()
-- right now it is a partial diff wrt a variable
-- make a exterior diff and use that as the volume element: dx wedge dy wedge dz etc
-- use this with the dual
