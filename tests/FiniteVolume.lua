#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Finite Volume', usePartialLHSForDerivative=true}}
local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local matrix = require 'matrix'

local Function = require 'symmath.Function'

local function makefunc(name)
	local cl = class(Function)
	cl.name = name
	return cl
end

local function funcFromExpr(expr)
	local str = tostring(expr)
	local name = str:match'%$(.*)%$'
	return makefunc(name)
end

local function Nabla(i, expr)
	return makefunc('\\nabla'..i)(expr)
end

local function partial(i, expr)
	return makefunc('\\partial'..i)(expr)
end

local dots = var'...'


-- TODO .... how to do indexes of {} latex ...
local TensorRef = require 'symmath.tensor.Ref'
local TensorIndex = require 'symmath.tensor.Index'

local function index(expr, ...)
	return TensorRef(expr, 
		table{...}:map(function(s)
			local lower 
			if s:sub(1,1) == '^' then s = s:sub(2) end
			if s:sub(1,1) == '_' then s = s:sub(2) lower = true end
			return TensorIndex{symbol=s, lower=lower}
		end):unpack()
	)
end

local function addIhatJhat(x)
	return index(x,
		'^\\hat{i}_1',
		'^...',
		'^\\hat{i}_p',
		'_\\hat{j}_1',
		'_...',
		'_\\hat{j}_q'
	)
end


local t = var't'
local tL = var't_L'
local tR = var't_R'

local u0 = var'u_0'
local u0L = var'u_{0,L}'
local u0R = var'u_{0,R}'

local u1 = var'u_1'
local u1L = var'u_{1,L}'
local u1R = var'u_{1,R}'

local un = var'u_n'
local unL = var'u_{n,L}'
local unR = var'u_{n,R}'

local uk = var'u_k'
local ukL = var'u_{k,L}'
local ukR = var'u_{k,R}'

local V = var'V'
printbr'Let $g_{ab} = \\partial_a \\cdot \\partial_b$ be the spacetime grid metric.  Let it be diagonal.'
printbr'Let the $\\hat{i}$ indexes be coefficients of a non-coordinate normalized basis.'
printbr'Let $e_\\hat{i} = {e^i}_\\hat{i} \\partial_i$ be the non-coordinate normalized basis.'
printbr'Let ${e^i}_\\hat{i}$ be the linear transform from the coordinate basis to the normalized non-coordinate basis, also diagonal.'
printbr'Let ${e_i}^\\hat{i}$ be the transform from the normalized non-coordinate basis to the coordinate basis, such that $[{e_i}^\\hat{i}] = [{e^i}_\\hat{i}]^{-1}$.'
printbr'Let $V = det([{e_i}^\\hat{i}])$ be the grid metric volume.'
printbr'Let $\\nabla$ be Levi-Civita tensor of the coordinate basis.'
local F = var'F'
local FIJ = addIhatJhat(F)

local expr
expr = Integral(
	Integral(
		dots * Integral(
			Nabla('_a', FIJ'^a') * V,
			un, unL, unR),
		u1, u1L, u1R),
	u0, u0L, u0R):eq(0)
printbr(expr)

printbr'Can we integrate non-coordinate values across an integral of a coordinate?'
printbr'Or do we need to factor in the rescaling values as well?'
--[=[
printbr"If you don't rescale each flux index now then you will need to add in rescaling derivatives when calculating the covariant derivative of the flux."
printbr"...But can we rescale it?  This changes the integral.  Does the integral still retain the same meaning?"
local e = var'e'
expr = Integral(
	Integral(
		dots * Integral(
			Nabla('_a', 
--[[				
				index(e, '_i_1', '^\\hat{i}_1')
				* dots
				* index(e, '_i_p', '^\\hat{i}_p')
				* index(e, '^j_1', '_\\hat{j}_1')
				* dots
				* index(e, '^j_q', '_\\hat{j}_q')
				*--]] index(F,
					'^i_1',
					'^...',
					'^i_p',
					'_j_1',
					'_...',
					'_j_q',
				
					'^a')
			) * V,
			un, unL, unR),
		u1, u1L, u1R),
	u0, u0L, u0R):eq(0)
printbr(expr)
printbr'<hr>'
--]=]

local e_k_hatk = index(e, '^k', '_\\hat{k}')
local FIJhatK = index(FIJ, '^\\hat{k}')

printbr'Separate space and time, assume extrinsic curvature is zero.'
expr = Integral(
	Integral(
		dots * Integral(
			((index(e, '^0', '_\\hat{0}') * index(FIJ, '^\\hat{0}')):diff(u0) + Nabla('_k', e_k_hatk * FIJhatK)) * V,
			un, unL, unR),
		u1, u1L, u1R),
	u0, u0L, u0R):eq(0)
printbr(expr)

printbr'Let $U = F^\\hat{0} = F^0$, i.e. the state is the flux through time.'
printbr'Let $t = u_0$.'
printbr'Let ${e^0}_\\hat{0}$ = 1.'

local U = var'U'
local UIJ = addIhatJhat(U)

expr = Integral(
	Integral(
		dots * Integral(
			(UIJ:diff(t) + Nabla('_k', e_k_hatk * FIJhatK)) * V,
			un, unL, unR),
		u1, u1L, u1R),
	u0, u0L, u0R):eq(0)
printbr(expr)

printbr'Separate the integrals.'
printbr'Rearrange time integral to be first next to $U$.'
expr = (
	Integral(
		dots * Integral(
			Integral(
				UIJ:diff(t) * V,
				t, tL, tR),
			un, unL, unR),
		u1, u1L, u1R)
	+ Integral(
		Integral(
			dots * Integral(
				Nabla('_k', e_k_hatk * FIJhatK) * V,
				un, unL, unR),
			u1, u1L, u1R),
		t, tL, tR)
):eq(0)
printbr(expr)


local UIJ_ = funcFromExpr(UIJ)
printbr'Apply FTC to $U$, separate $\\partial_t$ from $F$.'
expr = (
	Integral(
		dots * Integral(
			(UIJ_(t:eq(tR)) - UIJ_(t:eq(tL))) * V,
			un, unL, unR),
		u1, u1L, u1R)
	+ Integral(1, t, tL, tR)
	* Integral(
		dots * Integral(
			Nabla('_k', e_k_hatk * FIJhatK) * V,
			un, unL, unR),
		u1, u1L, u1R)
):eq(0)
printbr(expr)

local DeltaT = var'\\Delta t'
printbr'Factor out $U(t=t_R) - U(t=t_L)$, substitute $t_R - t_L = \\Delta t$.'
expr = (
	(UIJ_(t:eq(tR)) - UIJ_(t:eq(tL)))
	* Integral(
		dots * Integral(
			V,
			un, unL, unR),
		u1, u1L, u1R)
	+ DeltaT
	* Integral(
		dots * Integral(
			Nabla('_k', e_k_hatk * FIJhatK) * V,
			un, unL, unR),
		u1, u1L, u1R)
):eq(0)
printbr(expr)

printbr'Move $U(t=t_R)$ to the other side of the equation.'
expr = 
UIJ_(t:eq(tR))
:eq(
	UIJ_(t:eq(tL))
	- DeltaT 
	* (
		Integral(
			dots * Integral(
				Nabla('_k', e_k_hatk * FIJhatK) * V,
				un, unL, unR),
			u1, u1L, u1R)
		/ Integral(
			dots * Integral(
				V,
				un, unL, unR),
			u1, u1L, u1R)
	)
)
printbr(expr)

local Gamma = var'\\Gamma'
printbr"Expand $\\nabla_i$.  Don't forget that you will need to rescale the indexes associated with the connection pseudotensor that you are multiplying with the F tensor."
expr = 
UIJ_(t:eq(tR))
:eq(
	UIJ_(t:eq(tL))
	- DeltaT 
	/ Integral(
		dots * Integral(
			V,
			un, unL, unR),
		u1, u1L, u1R)

	* (
		Integral(
			dots * Integral(
				
				(
					partial('_k', e_k_hatk * index(
						F, 
						'^\\hat{i}_1',
						'^...',
						'^\\hat{i}_p',
						'_\\hat{j}_1',
						'_...',
						'_\\hat{j}_q',
					
						'^\\hat{k}'
					))

					+
						e_k_hatk 
						* index(e
							'_i_l',
							'^\\hat{i}_l'
						)
						* index(
							F, 
							'^\\hat{i}_1',
							'^...',
							'^\\hat{i}_{l-1}',
							'^m',
							'^\\hat{i}_{l+1}',
							'^...',
							'^\\hat{i}_p',
							'_\\hat{j}_1',
							'_...',
							'_\\hat{j}_q',
						
							'^\\hat{k}'
						) * index(
							Gamma,
							'^i_l',
							'_k',
							'_m'
						)
					
					- (e_k_hatk 
					* index(e
						'^j_l',
						'_\\hat{j}_l'
					)
					* index(
						F,
						'^\\hat{i}_1',
						'^...',
						'^\\hat{i}_p',
						'_\\hat{j}_1',
						'_...',
						'_\\hat{j}_{l-1}',
						'_m',
						'_\\hat{j}_{l-+}',
						'_...',
						'_\\hat{j}_q',
						
						'^\\hat{k}'
					)) * index(
						Gamma,
						'^m',
						'_k',
						'_j_l'
					)
			
					+
						index(
							F, 
							'^\\hat{i}_1',
							'^...',
							'^\\hat{i}_p',
							'_\\hat{j}_1',
							'_...',
							'_\\hat{j}_q',
						
							'^m'
						) * index(
							Gamma,
							'^k',
							'_k',
							'_m'
						)

					
				) * V,
				
				un, unL, unR),
			u1, u1L, u1R)
	)
)
printbr(expr)

printbr[[Let ${\Gamma^k}_{km} = ln(\sqrt{det(g_{ij})})$, so $\partial_k (\cdot) + (\cdot) {\Gamma^k}_{km} = \frac{1}{V} \partial_k(V (\cdot) )$]]

expr = 
UIJ_(t:eq(tR))
:eq(
	UIJ_(t:eq(tL))
	- DeltaT 
	/ Integral(
		dots * Integral(
			V,
			un, unL, unR),
		u1, u1L, u1R)

	* (
		Integral(
			dots * Integral(
				
				partial('_k', V * e_k_hatk * index(
					F, 
					'^\\hat{i}_1',
					'^...',
					'^\\hat{i}_p',
					'_\\hat{j}_1',
					'_...',
					'_\\hat{j}_q',
				
					'^\\hat{k}'
				))

				+
					(
						e_k_hatk 
						* index(e
							'_i_l',
							'^\\hat{i}_l'
						)
						* index(
							F, 
							'^\\hat{i}_1',
							'^...',
							'^\\hat{i}_{l-1}',
							'^m',
							'^\\hat{i}_{l+1}',
							'^...',
							'^\\hat{i}_p',
							'_\\hat{j}_1',
							'_...',
							'_\\hat{j}_q',
						
							'^\\hat{k}'
						) * index(
							Gamma,
							'^i_l',
							'_k',
							'_m'
						)
					
					- e_k_hatk 
					* index(e
						'^j_l',
						'_\\hat{j}_l'
					)
					* index(
						F,
						'^\\hat{i}_1',
						'^...',
						'^\\hat{i}_p',
						'_\\hat{j}_1',
						'_...',
						'_\\hat{j}_{l-1}',
						'_m',
						'_\\hat{j}_{l-+}',
						'_...',
						'_\\hat{j}_q',
						
						'^\\hat{k}'
					) * index(
						Gamma,
						'^m',
						'_k',
						'_j_l'
					)
								
				) * V,
				
				un, unL, unR),
			u1, u1L, u1R)
	)
)
printbr(expr)

printbr'Separate the integrals of the flux.  Rearrange integrals next to the partial so $u_k$ is inner-most.'
expr = 
UIJ_(t:eq(tR))
:eq(
	UIJ_(t:eq(tL))
	- DeltaT 
	/ Integral(
		dots * Integral(
			V,
			un, unL, unR),
		u1, u1L, u1R)

	* (
		Integral(
			var'\\overset{- \\{k\\}}{...}' * Integral(
				Integral(
					partial('_k', V * e_k_hatk * index(
						F, 
						'^\\hat{i}_1',
						'^...',
						'^\\hat{i}_p',
						'_\\hat{j}_1',
						'_...',
						'_\\hat{j}_q',
					
						'^\\hat{k}'
					)),
					uk, ukL, ukR),
				un, unL, unR),
			u1, u1L, u1R)

		+ Integral(
			dots * Integral(
					(
						e_k_hatk 
						* index(e
							'_i_l',
							'^\\hat{i}_l'
						)
						* index(
							F, 
							'^\\hat{i}_1',
							'^...',
							'^\\hat{i}_{l-1}',
							'^m',
							'^\\hat{i}_{l+1}',
							'^...',
							'^\\hat{i}_p',
							'_\\hat{j}_1',
							'_...',
							'_\\hat{j}_q',
						
							'^\\hat{k}'
						) * index(
							Gamma,
							'^i_l',
							'_k',
							'_m'
						)
					
					- e_k_hatk 
					* index(e
						'^j_l',
						'_\\hat{j}_l'
					)
					* index(
						F,
						'^\\hat{i}_1',
						'^...',
						'^\\hat{i}_p',
						'_\\hat{j}_1',
						'_...',
						'_\\hat{j}_{l-1}',
						'_m',
						'_\\hat{j}_{l-+}',
						'_...',
						'_\\hat{j}_q',
						
						'^\\hat{k}'
					) * index(
						Gamma,
						'^m',
						'_k',
						'_j_l'
					)
								
				) * V,
				
				un, unL, unR),
			u1, u1L, u1R)
	)
)
printbr(expr)

local V_e_FIJ = makefunc('('..tostring(V * e_k_hatk * FIJhatK):match'%$(.*)%$'..')')
printbr'Apply FTC to $u_k$.'
expr = 
UIJ_(t:eq(tR))
:eq(
	UIJ_(t:eq(tL))
	- DeltaT 
	/ Integral(
		dots * Integral(
			V,
			un, unL, unR),
		u1, u1L, u1R)

	* (
		Integral(
			var'\\overset{- \\{k\\}}{...}' * Integral(
				V_e_FIJ(uk:eq(ukR)) - V_e_FIJ(uk:eq(ukL)),
				un, unL, unR),
			u1, u1L, u1R)

		+ Integral(
			dots * Integral(
					(
						e_k_hatk 
						* index(e
							'_i_l',
							'^\\hat{i}_l'
						)
						* index(
							F, 
							'^\\hat{i}_1',
							'^...',
							'^\\hat{i}_{l-1}',
							'^m',
							'^\\hat{i}_{l+1}',
							'^...',
							'^\\hat{i}_p',
							'_\\hat{j}_1',
							'_...',
							'_\\hat{j}_q',
						
							'^\\hat{k}'
						) * index(
							Gamma,
							'^i_l',
							'_k',
							'_m'
						)
					
					- e_k_hatk 
					* index(e
						'^j_l',
						'_\\hat{j}_l'
					)
					* index(
						F,
						'^\\hat{i}_1',
						'^...',
						'^\\hat{i}_p',
						'_\\hat{j}_1',
						'_...',
						'_\\hat{j}_{l-1}',
						'_m',
						'_\\hat{j}_{l-+}',
						'_...',
						'_\\hat{j}_q',
						
						'^\\hat{k}'
					) * index(
						Gamma,
						'^m',
						'_k',
						'_j_l'
					)
								
				) * V,
				
				un, unL, unR),
			u1, u1L, u1R)
	)
)
printbr(expr)

printbr'<hr>'
printbr'<h2>Specific Examples</h2>'

local function example(args)
	print'<hr>'
	printbr('<h3>'..args.name..'</h3>')
	
	local us = table(args.vars)
	local lengths = table(args.lengths)
	assert(#lengths == #us)
	
	local Vval = table.product(lengths)()

	local Ls = us:mapi(function(u) return var(u.name..'_L') end)
	local Rs = us:mapi(function(u) return var(u.name..'_R') end)
	local hats = us:mapi(function(u) return var('\\hat{'..u.name..'}') end)

	printbr(var'n':eq(#us))
	local sep = ''
	for i,u in ipairs(us) do	
		print(sep, var('u_'..i):eq(u))
		sep = ','
	end
	printbr()

	sep = ''
	for i,l in ipairs(lengths) do
		print(sep, index(var'e', '_'..us[i].name, '^'..hats[i].name):eq(l))
		sep = ','
	end
	printbr()

	sep = ''
	for i,l in ipairs(lengths) do
		print(sep, index(var'e', '^'..us[i].name, '_'..hats[i].name):eq(1/l))
		sep = ','
	end
	printbr()
	
	printbr(var'V':eq(Vval))

	for p=0,1 do
		for q=0,0 do

			
			printbr('<h4>degree ', Matrix{p, q}:T(), 'case</h4>')

			-- n x ... x n, p+q times
			local sizes = matrix(range(p+1):mapi(function() return n end))
			
			
			for is in sizes:iter() do
				local pqindexes = is:map(function(i,j)
					return (j <= p and '^' or '_')..hats[i].name
				end)
				
				local UIJ = index(U, pqindexes:unpack())
				local UIJ_ = funcFromExpr(UIJ)

				local function wrapints(expr, excluding)
					for i,u in ipairs(us) do
						if i ~= excluding then
							expr = Integral(expr, u, Ls[i], Rs[i])
						end
					end
					return expr
				end

				local Fsum
				for i,u in ipairs(us) do
					local hat, L, R = hats[i], Ls[i], Rs[i]
					local FIJ = index(F,
						table(pqindexes):append{'^'..hats[i].name}:unpack()
					)
					local V_e_F_i = makefunc('('..tostring(Vval / lengths[i] * FIJ):match'%$(.*)%$'..')')
					local term = wrapints(V_e_F_i(u:eq(R)) - V_e_F_i(u:eq(L)), i)
					Fsum = Fsum and (Fsum + term) or term
				end
				Fsum = Fsum or 0

				local expr = UIJ_(t:eq(tR)):eq( UIJ_(t:eq(tL)) - DeltaT / wrapints(Vval) * Fsum )
				printbr(expr)

				-- now to simplify...
				-- TODO simplify() shouldn't expand. only factor.
				local expr = UIJ_(t:eq(tR)):eq( UIJ_(t:eq(tL)) - DeltaT / wrapints(Vval)() * Fsum )
				printbr(expr)
			end
		end
	end
end



printbr'<h3>Polar, Anholonomic, Normalized</h3>'
printbr'$n = 2, u_1 = r, u_2 = \\phi$'
printbr'${e_r}^\\hat{r} = 1, {e^r}_\\hat{r} = 1$'
printbr'${e_\\phi}^\\hat{\\phi} = r, {e^\\phi}_\\hat{\\phi} = \\frac{1}{r}$'
printbr'$V = r$'

local r = var'r'
local rL = var'r_L'
local rR = var'r_R'

local phi = var'\\phi'
local phiL = var'\\phi_L'
local phiR = var'\\phi_R'

local vars = {r, phi}
local lengths = {1, r}
local Vval = table.product(lengths)

printbr'<h4>scalar case</h4>'

local U_ = funcFromExpr(U)
local V_e_F_r = makefunc('('..tostring(Vval / lengths[1] * index(F, '^\\hat{r}')):match'%$(.*)%$'..')')
local V_e_F_phi = makefunc('('..tostring(Vval / lengths[2] * index(F, '^\\hat{\\phi}')):match'%$(.*)%$'..')')
local F_rHat_ = funcFromExpr(index(F, '^\\hat{r}'))
local F_phiHat_ = funcFromExpr(index(F, '^\\hat{\\phi}'))

expr = 
U_(t:eq(tR))
:eq(
	U_(t:eq(tL))
	- DeltaT 
		/ Integral(
			Integral(
				Vval,
				phi, phiL, phiR),
			r, rL, rR)
	* (
		Integral(
			V_e_F_r(r:eq(rR)) - V_e_F_r(r:eq(rL)),
			phi, phiL, phiR)
		+ Integral(
			V_e_F_phi(phi:eq(phiR)) - V_e_F_phi(phi:eq(phiL)),
			r, rL, rR)
	)
)
printbr(expr)

printbr'evaluate...'

expr = 
U_(t:eq(tR))
:eq(
	U_(t:eq(tL))
	- DeltaT 
		/ ((phiR - phiL) * (rR^2 / 2 - rL^2 / 2))
	* (
		(phiR - phiL) * (rR * F_rHat_(rR) - rL * F_rHat_(rL))
		+ (F_phiHat_(phiR) - F_phiHat_(phiL)) * (rR - rL)
	)
)
printbr(expr)

expr = 
U_(t:eq(tR))
:eq(
	U_(t:eq(tL))
	- DeltaT 
	* (
		(rR * F_rHat_(rR) - rL * F_rHat_(rL))
			/ (rR^2 / 2 - rL^2 / 2)
		+ (F_phiHat_(phiR) - F_phiHat_(phiL)) * (rR - rL)
			/ ((phiR - phiL) * (rR^2 / 2 - rL^2 / 2))
	)
)
printbr(expr)



local r = var'r'
local phi = var'\\phi'
local theta = var'\\theta'
local z = var'z'

example{
	name = 'Polar',
	vars = {r, phi},
	lengths = {1, r},
}

example{
	name = 'Cylindrical',
	vars = {r, phi, z},
	lengths = {1, r, 1},
}

example{
	name = 'Spherical',
	vars = {r, theta, phi},
	lengths = {1, r, r*sin(theta)},
}
