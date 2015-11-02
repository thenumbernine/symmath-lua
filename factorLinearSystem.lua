--[[
accepts a list of equations and a list of factors x_i
returns matrices A and b:

[a11 ... a1m][x1]   [b1]
[..       ..][..] + [..]
[an1 ... anm][xm]   [bn]

--]]
return function(exprs, factors)
	local table = require 'ext.table'
	local clone = require 'symmath.clone'
	local Matrix = require 'symmath.Matrix'
	local addOp = require 'symmath.addOp'
	local mulOp = require 'symmath.mulOp'

	local A = Matrix(exprs:map(function()
		return factors:map(function() return 0 end)
	end):unpack())

	local S = Matrix(table.map(exprs, function()
		return {0}
	end):unpack())

	for i=1,#exprs do
		local expr = exprs[i]:factorDivision()
		
		-- if not add op then just consider the one expression
		if not expr:isa(addOp) then expr = addOp(expr) end
		-- find factors
		for k=#expr,1,-1 do
			local found = false
			for j=1,#factors do
				if expr[k] == factors[j] then
					assert(not found)
					A[i][j] = (A[i][j] + 1):simplify()
					table.remove(expr,k)
					found = true
				elseif expr[k]:isa(mulOp) then
					for l=#expr[k],1,-1 do
						
						-- factorDivision() should prevent this
						if expr[k][l]:isa(mulOp) then error"needs flattening" end
						
						if expr[k][l] == factors[j] then
							assert(not found)
							table.remove(expr[k],l)
							A[i][j] = (expr[k] + A[i][j]):simplify()
							found = true
						end
					end
					if found then
						table.remove(expr,k)
					end
				end
				if found then break end
			end
		end
		-- if there is anything left then put it in the rhs side
		if #expr ~= 0 then
			if #expr == 1 then expr = expr[1] end
			S[i][1] = (S[i][1] + expr):simplify()
		end
	end
	
	return A, S
end
