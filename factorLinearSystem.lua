--[[
accepts a list of equations and a list of factors x_i
returns matrices A and b:

[a11 ... a1m][x1]   [b1]
[..       ..][..] + [..]
[an1 ... anm][xm]   [bn]

--]]
local table = require 'ext.table'
return function(exprs, factors)
	local symmath = require 'symmath'
	local clone = symmath.clone
	local Matrix = symmath.Matrix
	local add = symmath.add
	local mul = symmath.mul

	local A = Matrix(table.map(exprs, function()
		return table.map(factors, function() return 0 end)
	end):unpack())

	local S = Matrix(table.map(exprs, function()
		return {0}
	end):unpack())

	for i=1,#exprs do
		local expr = exprs[i]:factorDivision()
		
		-- just consider expr as its terms (since I no longer support single-term binary ops)
		expr = add.is(expr) and {table.unpack(expr)} or {expr}
		-- find factors
		for k=#expr,1,-1 do
			local found = false
			for j=1,#factors do
				if expr[k] == factors[j] then
					assert(not found)
					A[i][j] = (A[i][j] + 1):simplify()
					table.remove(expr,k)
					found = true
				elseif mul.is(expr[k]) then
					for l=#expr[k],1,-1 do
						
						-- factorDivision() should prevent this
						if mul.is(expr[k][l]) then error"needs flattening" end
					
						-- TODO what if factors[j] is a product?
						-- in that case we need to make sure it's a common subset
						if expr[k][l] == factors[j] then
							assert(not found)
							table.remove(expr[k],l)
							if #expr[k] == 1 then
								A[i][j] = (expr[k][1] + A[i][j]):simplify()
							else
								A[i][j] = (expr[k] + A[i][j]):simplify()
							end
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
		if #expr > 1 then expr = add(table.unpack(expr)) end
		-- if there is anything left then put it in the rhs side
		if #expr ~= 0 then
			if #expr == 1 then expr = expr[1] end
			S[i][1] = (S[i][1] + expr):simplify()
		end
	end
	
	return A, S
end
