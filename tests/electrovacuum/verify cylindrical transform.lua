#! /usr/bin/env luajit
require 'ext'
require 'symmath'.setup{MathJax={title='verify cylindrical transform', usePartialLHSForDerivative=true, pathToTryToFindMathJax='..'}}

local t,x,y,z = vars('t', 'x', 'y', 'z')
local r = var('r', {x,y})
local phi = var('\\phi', {x,y})

local chart_t_r_phi_z = Tensor.Chart{coords={t,r,phi,z}}
local chart_t_x_y_z = Tensor.Chart{symbols='ABCDEF', coords={t,x,y,z}}
-- does this work yet?
--local chart_x_y_z = Tensor.Chart{symbols='IJKLMN', coords={x,y,z}}
--local chart_r_phi_z = Tensor.Chart{symbols='ijklmn', coords={r,phi,z}}
local chart_t = Tensor.Chart{symbols='t', coords={t}}
local chart_x = Tensor.Chart{symbols='x', coords={x}}
local chart_y = Tensor.Chart{symbols='y', coords={y}}
local chart_z = Tensor.Chart{symbols='z', coords={z}}
local chart_r = Tensor.Chart{symbols='r', coords={r}}
local chart_phi = Tensor.Chart{symbols='p', coords={phi}}
local chart_z = Tensor.Chart{symbols='z', coords={z}}


local u = Tensor('^A', t, r * cos(phi), r * sin(phi), z)
printbr'coordinate chart'
u:print'u'
printbr()

printbr(var'u''^A_,a':eq(u'^A_,a'()))

local e = Tensor'_a^A'
e['_a^A'] = u'^A_,a'()

printbr'cartesian to cylindrical'
e:print'e'
printbr()

local eU = Tensor('^a_A', table.unpack(Matrix(table.unpack(e)):inverse():transpose()))
	:replace( (1 - sin(phi)^2) / cos(phi), cos(phi) )	-- TODO this automatically, either in :simplify() or make a new :trigSimp()
printbr'cylindrical to cartesian'
eU:print'e'
printbr()

printbr((var'e''_a^A' * var'e''^b_A'):eq((e'_a^A' * eU'^b_A')()))
printbr((var'e''_a^A' * var'e''^a_B'):eq((e'_a^A' * eU'^a_B')()))

local E = var'E'
local Ricci_flat = Tensor('_AB', table.unpack(Matrix.diagonal(E^2, E^2, E^2, -E^2))) 
printbr'cartesian Ricci tensor'
Ricci_flat:print'R' 
printbr()

local Ricci_cyl = (Ricci_flat'_AB' * e'_a^A' * e'_b^B')()
printbr'cartesian Ricci tensor transformed to cylindrical'
Ricci_cyl:print'R' 
printbr()

local Conn_flat = Tensor'^A_BC'
Conn_flat[4][1][1] = -E	-- only scales R_tt
Conn_flat[1][4][1] = E	-- scales R_xx and affects terms of R_tt
Conn_flat[1][1][4] = E	-- affects terms of R_tt
Conn_flat[4][2][2] = E	-- scales R_yy
Conn_flat[4][3][3] = E	-- scales R_zz
printbr'cartesian connection that gives rise to cartesian Ricci of EM stress-energy tensor:'
Conn_flat:printElem'\\Gamma'
printbr()

local Riemann_flat = Tensor'^A_BCD'
Riemann_flat['^A_BCD'] = (Conn_flat'^A_BD,C' - Conn_flat'^A_BC,D' 
	+ Conn_flat'^A_EC' * Conn_flat'^E_BD' - Conn_flat'^A_ED' * Conn_flat'^E_BC'
	- Conn_flat'^A_BE' * (Conn_flat'^E_DC' - Conn_flat'^E_CD'))()
--printbr'cartesian Riemann'
--Riemann_flat:print'R'
--printbr()

local Ricci_flat = Riemann_flat'^C_ACB'() 
printbr'Ricci from Riemann from cartesian connection'
Ricci_flat:print'R'
printbr()

local Conn_cyl = Tensor'^a_bc'
Conn_cyl['^a_bc'] = (Conn_flat'^A_BC' * eU'^a_A' * e'_b^B' * e'_c^C' + eU'^a_A' * e'_b^A_,c')()
printbr'cartesian connection transformed to cylindrical'
Conn_cyl:printElem'\\Gamma'
printbr()

local Riemann_cyl_from_xform_conn = Tensor'^a_bcd'
Riemann_cyl_from_xform_conn['^a_bcd'] =  (Conn_cyl'^a_bd,c' - Conn_cyl'^a_bc,d' 
	+ Conn_cyl'^a_ec' * Conn_cyl'^e_bd' - Conn_cyl'^a_ed' * Conn_cyl'^e_bc'
	- Conn_cyl'^a_be' * (Conn_cyl'^e_dc' - Conn_cyl'^e_cd'))()
--printbr'cylindrical Riemann'
--Riemann_cyl_from_xform_conn:print'R'
--printbr()

local Ricci_cyl_from_xform_conn = Riemann_cyl_from_xform_conn'^c_acb'()
printbr'Ricci from connections transformed from cartesian to cylindrical'
Ricci_cyl_from_xform_conn:print'R'
printbr'...matches the Ricci transformed to cylindrical'
printbr()
