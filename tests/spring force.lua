#!/usr/bin/env luajit
--[[
Hooke's spring law:
hamiltonian = (|x_1 - x_2| - restLength)

x'' = -(k/m)(x-s) = 
--]]

require 'ext'
require 'symmath'.setup()
require 'symmath.tostring.MathJax'.setup()

local dim = 1	-- or 2 or 3 or whatever
local numParticlesToCreate = 3
local dt = .1
local numberOfSteps = 10000

local vec
if dim >= 2 and dim <= 4 then
	vec = require('vec.vec'..dim)	-- ... includes special case stuff per dimension
else
	local createVectorClass = require 'vec.create'
	vec = createVectorClass(dim)	-- nothing extra
end

local Particle = class()

-- underscores mean symmath variable, no-underscore means 'number' variable

-- index = index in EnergySystem.particles
function Particle:init(index)
	self.index = index
	self.qVar = vec()	-- position symbolic
	self.pVar = vec()	-- momentum symbolic
	for i=1,dim do
		self.qVar[i] = var('q_{'..self.index..','..i..'}', {t})
		self.pVar[i] = var('p_{'..self.index..','..i..'}', {t})
	end
	self.q = vec()	-- position numeric
	self.p = vec()	-- momentum numeric
	self.m = 1	-- constant, so might as well use a number  
end

local EnergySystem = class()

function EnergySystem:init()
	self.particles = table()
end

function EnergySystem:createParticle()
	local v = Particle(#self.particles+1)
	self.particles:insert(v)
	return v
end

function EnergySystem:buildSymbolicParams()
	local symbolicParams = table()
	for i,v in ipairs(self.particles) do
		for k=1,dim do
			symbolicParams:insert{[v.qVar[k]] = 'q_'..i..'_'..k}	-- position
			symbolicParams:insert{[v.pVar[k]] = 'p_'..i..'_'..k}	-- velocity
		end
	end
	return symbolicParams
end

-- matches the order above
function EnergySystem:buildNumericParams()
	local numericParams = table()
	for i,v in ipairs(self.particles) do
		for k=1,dim do
			numericParams:insert(v.q[k])	-- position
			numericParams:insert(v.p[k])	-- velocity
		end
	end
	return numericParams
end

-- define particles in the system
local system = EnergySystem()

for i=1,numParticlesToCreate do
	system:createParticle()
end

-- kinetic energy
local K = Constant(0)
for _,v in ipairs(system.particles) do
	K = K + v.pVar:lenSq() / (2 * v.m)
end
--K = K:simplify()
-- kinetic terms are all linear, so don't mess with it

-- potential energy
local restLength = 1
local k = .1	-- spring constant
local U = Constant(0) 

-- ... and then, upon evaluation, I'll calculate them and evaluate the system 
for i,v1 in ipairs(system.particles) do
	for j,v2 in ipairs(system.particles) do
		if v1 ~= v2 then
			U = U + (sqrt((v1.qVar - v2.qVar):lenSq()) - restLength)^2
		end
	end
end
U = k / 2 * U
--U = U:simplify()

-- Hamiltonian
local H = K + U

--[[
... if K is a function of of p alone ... and U is a function of q alone ... 
then there really isn't a need to add them together and say ...
	p' = -dH/dq, q' = dH/dp
because dH/dq is only dU/dq and dH/dp = dK/dp
so the system simplifies one step into
	p' = -dU/dq, q' = dK/dp
--]]
--system:setHamiltonian(H)

-- save params for later.
-- the upside to this is no math required -- the CAS does it all for you
-- the downside is, well, at the moment you have to recompile every time a new particle is added.
-- considering how linear an oscillator is, I'm sure this could be eliminated 
-- (esp if I was storing spring edges somewhere, rather than making all particles share)
local symbolicParams = system:buildSymbolicParams()
print('symbolic params',table.unpack(symbolicParams:map(function(v)
	local k = table.unpack(table.keys(v))
	return tostring(k)..'='..v[k]
end)))
print('<br>')

-- and now each particle has its evolution equations
print('Hamiltonian','<br>')
print(var'H':eq(H),'<br>')
-- compile evolution equations
print('Evolution Equations:','<br>')
local tVar = var't'
local dq_dt_vector = Matrix()
local dq_dt_vector_eqn_rhs = Matrix()
local q_vector = Matrix()
for i,v in ipairs(system.particles) do	
	-- dq/dt = dH/dp is a function of p1..pn ... and maybe q1..qn
	v.dq_dt = vec()
	v.dp_dt = vec()
	v.dq_dt_expr = vec()
	v.dp_dt_expr = vec()
	for k=1,dim do
		-- notice: each of these ends up with d[distance]/dq variables
		-- the best way to deal with them is substituting them for the linear components of their value 

		local dH_dp = H:diff(v.pVar[k]):simplify()
		v.dq_dt_expr[k] = dH_dp
		local dq_dt_var = v.qVar[k]:diff(tVar)
print(dq_dt_var:eq(dH_dp),'<br>')
		v.dq_dt[k] = dH_dp:compile(symbolicParams)
		table.insert(dq_dt_vector, Array(dq_dt_var))
		table.insert(dq_dt_vector_eqn_rhs, Array(dH_dp))
		table.insert(q_vector, Array(v.qVar[k]))
	
		local _dH_dq = (-H):diff(v.qVar[k]):simplify()
		v.dp_dt_expr[k] = _dH_dq
		local dp_dt_var = v.pVar[k]:diff(tVar)
print(dp_dt_var:eq(_dH_dq),'<br>')
		v.dp_dt[k] = _dH_dq:compile(symbolicParams)
		table.insert(dq_dt_vector, Array(dp_dt_var))
		table.insert(dq_dt_vector_eqn_rhs, Array(_dH_dq))
		table.insert(q_vector, Array(v.pVar[k]))
	end
end

print('...in a vector:','<br>')
print(dq_dt_vector:eq(dq_dt_vector_eqn_rhs),'<br>')
-- TODO factor matrix function

local dtVar = var('\\Delta t')
local A_matrix = Matrix()
do
	local function coeff(expr, var)
		return expr:polyCoeffs(var)[1] 
			--or error("failed to find coefficient of "..var.." in expression "..expr)
			or Constant(0)
	end
	local n = #dq_dt_vector
	for i=1,n do
		A_matrix[i] = Array()
		for j=1,n do
			A_matrix[i][j] = coeff(dq_dt_vector_eqn_rhs[i][1], q_vector[j][1])
		end
		-- TODO b_vector[i][1] = whatever is left
	end
end

print('...linearized:','<br>')
print(dq_dt_vector:eq(A_matrix * q_vector),'<br>')

local q_t_vector = Matrix()
local q_t_dt_vector = Matrix()
for i=1,#q_vector do
	q_t_vector[i] = Array(var(q_vector[i][1].name..'(t)'))
	q_t_dt_vector[i] = Array(var(q_vector[i][1].name..'(t+\\Delta t)'))
end

local discrete_dq_dt_vector = ((q_t_dt_vector - q_t_vector) / dtVar):simplify()

do
	print('1st order approximate derivative for Forward Euler','<br>')
	local eqn = (discrete_dq_dt_vector):eq(A_matrix * q_t_vector)
	print(eqn,'<br>')
	-- now I need something to convert the a/b's to a*(1/b)'s, so I can use a to-be-made function for extracting matrix coefficients ...
	-- until then, I'll just start with the non-simplified equation:
	local eqn = (q_t_dt_vector):eq(q_t_vector + dtVar * A_matrix * q_t_vector)
	print(eqn,'<br>')
	-- hmm, todo, factoring out matrices (by introducing identity)
	-- until then, redo the equation
	local eqn = (q_t_dt_vector):eq((Matrix.identity(#q_vector) + dtVar * A_matrix) * q_t_vector)
	print(eqn,'<br>')
	-- simplify matrix muls only
	local eqn = (q_t_dt_vector):eq((Matrix.identity(#q_vector) + dtVar * A_matrix):simplify() * q_t_vector)
	print(eqn,'<br>')
	-- simplify matrix muls only
	local eqn = (q_t_dt_vector):eq((Matrix.identity(#q_vector) + dt * A_matrix):simplify() * q_t_vector)
	print(eqn,'<br>')
end

local backwardsEulerMatrix
do
	print('1st order approximate derivative for Backwards Euler','<br>')
	local eqn = (discrete_dq_dt_vector):eq(A_matrix * q_t_dt_vector)
	print(eqn,'<br>')
	-- TODO expand() on lhs then matrix factor ...
	eqn = (q_t_dt_vector - dtVar * A_matrix * q_t_dt_vector):eq(q_t_vector)
	print(eqn,'<br>')
	-- TODO vector factor
	backwardsEulerMatrix = (Matrix.identity(#q_vector) - dtVar * A_matrix)
	eqn = (backwardsEulerMatrix * q_t_dt_vector):eq(q_t_vector)
	print(eqn,'<br>')
	backwardsEulerMatrix = backwardsEulerMatrix:simplify()
	eqn = (backwardsEulerMatrix * q_t_dt_vector):eq(q_t_vector)
	print(eqn,'<br>')
	backwardsEulerMatrix = backwardsEulerMatrix:replace(dtVar, dt):simplify()
	eqn = q_t_dt_vector:eq(backwardsEulerMatrix^(-1) * q_t_vector)
	print(eqn,'<br>')
end

-- and integrate ... forward Euler

local ts = table()
local columns = table()
for i,v in ipairs(system.particles) do 
	for j=1,dim do
		columns[v.qVar[j].name] = table()		-- graph for position
		columns[v.pVar[j].name] = table()		-- graph for velocity
	end
end

-- initialize the numeric side of things
system.particles[1].q[1] = 1
system.particles[2].q[1] = -1
system.particles[3].q[1] = 0

--[[

ODE:
dx/dt = f(t,x)

forward Euler integrator:
( x(t+dt) - x(t) ) / dt = f(t,x)
x(t+dt) = x(t) + dt * f(t,x)

backward Euler integrator:
x(t+dt) - dt * f(t+dt, x(t+dt)) = x(t)

...for multiple variables...
x_i(t+dt) - dt * f_i(t+dt, x_j(t+dt)) = x_i(t)
... makes a nonlinear system ...
... assume I - dt * f_i(x_j) (specifically f_i(x_j)) can be linearized as a_ij x_j + b_i 
x_i(t+dt) - dt * a_ij * x_j(t+dt) - dt * b_i = x_i(t)
x_j(t+dt) = (I_ij - dt * a_ij)^-1 (x_i(t) + dt * b_i)

--]]

local t = 0
for i=1,numberOfSteps do
	for _,v in ipairs(system.particles) do
		-- forward Euler integration
		for j=1,dim do
			v.q[j] = v.q[j] + dt * v.dq_dt[j](table.unpack(system:buildNumericParams()))
			v.p[j] = v.p[j] + dt * v.dp_dt[j](table.unpack(system:buildNumericParams()))
			columns[v.qVar[j].name]:insert(v.q[j])
			columns[v.pVar[j].name]:insert(v.p[j])
		end
		-- TODO backward Euler via numeric inverse of the backwards Euler matrix calculated above ... or symbolic inverse?
	end
	t = t + dt
	ts:insert(t)
end

local args = {
	style = 'data lines',
	data = {ts},
}
for k,v in pairs(columns) do
	table.insert(args.data, v)
	table.insert(args, {using='1:'..#args.data, title=k})
end
GnuPlot:plot(args)
