#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup()
require 'symmath.tostring.MathJax'.setup{usePartialLHSForDerivative = true}

local function sum(t)
	if #t == 1 then return t[1] end
	return op.add(table.unpack(t))
end

-- dimension variables
local t, x, y, z = vars('t', 'x', 'y', 'z')
local coords = {t, x, y, z}

-- primitive variables
local rho = var('\\rho', coords)	-- density

local ux = var('u_x', coords)	-- velocity
local uy = var('u_y', coords)
local uz = var('u_z', coords)

local e_int = var('e_{int}', coords)		-- total specific energy 

--local usePrims = true

-- dimension related
for dim=1,1 do
	print('<h3>'..dim..'D case:</h3>')
	
	local us = table{ux, uy, uz} 
	us = us:sub(1,dim)
	local xs = table{x,y,z}
	xs = xs:sub(1,dim)
	local uSq = sum(us:map(function(u) return u^2 end))

	-- state variable
	local qs = range(dim+2):map(function(i) return var('q_'..i, coords) end)
	local q1, q2, q3, q4, q5 = table.unpack(qs)

	-- other variables
	local gamma = var('\\gamma')
	local e_kin = uSq/2					-- specific kinetic energy
	local e_total = e_int + e_kin					-- specific internal energy
	local P = (gamma - 1) * rho * e_int	-- pressure
	local E_total = rho * e_total					-- total energy
	
	-- primitives
	local ws
	if usePrims then
		P = var('P', coords)
		ws = table{rho}:append(us):append{P}
	end

	-- equations 
	printbr('original equations:')

	local continuityEqn = (rho:diff(t) + 
		sum(range(dim):map(function(j)
			return (rho * us[j]):diff(xs[j])
		end))):eq(0)

	local momentumEqns = range(dim):map(function(i)
		return ((rho * us[i]):diff(t) + sum(range(dim):map(function(j)
			return (rho * us[i] * us[j] + (i==j and P or 0)):diff(xs[j])
		end))):eq(0)
	end)

	local energyEqn = ((rho * e_total):diff(t) +
		sum(range(dim):map(function(j)
			return ((E_total + P) * us[j]):diff(xs[j])
		end))):eq(0)

	local eqns = table{continuityEqn}:append(momentumEqns):append{energyEqn}

	eqns:map(function(eqn) printbr(eqn) end)

	if usePrims then
	else
		printbr('substituting state variables:')
		eqns = eqns:map(function(eqn)
			eqn = eqn:replace(rho, qs[1])
			eqn = eqn:replace(e_int, qs[dim+2] / qs[1] - e_kin)
			for j=1,dim do
				eqn = eqn:replace(us[j], qs[j+1] / qs[1])
			end
			
			return eqn
		end)
		eqns:map(function(eqn) printbr(eqn) end)
	end

	printbr'distribute'

	eqns = eqns:map(function(eqn) return eqn:distributeDivision() end)
	eqns:map(function(eqn) printbr(eqn) end)

	printbr'factor matrix'

	local remainingTerms = Matrix(eqns:map(function(eqn)
		return {eqn:lhs()}
	end):unpack())

	local matrixLHS

	local dFk_dqs = table()
	for j=1,dim do
		local dq_dxk = (usePrims and ws or qs):map(function(q) return q:diff(xs[j]) end)

		local dFk_dq
		dFk_dq, remainingTerms = factorLinearSystem(
			table.map(remainingTerms, function(row) return row[1] end), dq_dxk)
		dFk_dqs:insert(dFk_dq)

		local dq_dxk = Matrix(dq_dxk:map(function(dq_dx)
			return {dq_dx}
		end):unpack())

		local dFk_dxk = dFk_dq * dq_dxk
		matrixLHS = matrixLHS and (matrixLHS + dFk_dxk) or dFk_dxk
	end

	local matrixRHS = -remainingTerms

	-- convert from table to matrix
	local dq_dts = Matrix((usePrims and ws or qs):map(function(q)
		return {q:diff(t)}
	end):unpack())

	-- remove the dq_dts from the source term (and add them to the right-hand side)
	matrixLHS = dq_dts + matrixLHS
	matrixRHS = dq_dts + matrixRHS

	matrixRHS = matrixRHS() 	-- simplify the rhs only -- keep the dts and dxs separate
	local matrixEqn = matrixLHS:eq(matrixRHS)
	printbr(matrixEqn)

	printbr'factor matrix in primitive variables'

	local primMatrixEqn = matrixEqn:replace(qs[1], rho)
	for j=1,dim do
		primMatrixEqn = primMatrixEqn:replace(qs[j+1], rho * us[j])
	end
	primMatrixEqn = primMatrixEqn:replace(qs[dim+2], rho * e_total)
	-- only simplify matrix contents.  TODO skip the d/dx q matrices
	primMatrixEqn = primMatrixEqn:map(function(expr)
		if Matrix.is(expr) then return expr() end
	end)
	printbr(primMatrixEqn)

	printbr('eigenvalues of ${{\\partial F_x}\\over{\\partial q}}$')
	local lambda = var'\\lambda'
	local det = (dFk_dqs[1] - Matrix.identity(#qs) * lambda):determinant():eq(0)
	printbr(det)
	printbr(det:solve(lambda))
end
