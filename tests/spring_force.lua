#!/usr/bin/env luajit
--[[
Hooke's spring law:
hamiltonian = (|x_1 - x_2| - restLength)

x'' = -(k/m)(x-s) = 
--]]

local dim = 1	-- or 2 or 3 or whatever
local vec
if dim >= 2 and dim <= 4 then
	vec = require('vec.vec'..dim)	-- ... includes special case stuff per dimension
else
	local createVectorClass = require 'vec.create'
	vec = createVectorClass(dim)	-- nothing extra
end

local symmath = require 'symmath'
symmath.tostring = require 'symmath.tostring.MultiLine'

local Particle = class()

-- underscores mean symmath variable, no-underscore means 'number' variable

-- index = index in EnergySystem.particles
function Particle:init(index)
	self.index = index
	self.q_ = vec()	-- position symbolic
	self.p_ = vec()	-- momentum symbolic
	for i=1,dim do
		self.q_[i] = symmath.var('q'..self.index..'_'..i, {t})
		self.p_[i] = symmath.var('p'..self.index..'_'..i, {t})
	end
	self.q = vec()	-- position numeric
	self.p = vec()	-- momentum numeric
	self.m = 1	-- constant, so might as well use a number  
end

local EnergySystem = class()

function EnergySystem:init()
	self.particles = table()
end

function EnergySystem:createVertex()
	local v = Particle(#self.particles)
	self.particles:insert(v)
	return v
end

function EnergySystem:buildSymbolicParams()
	-- save params for later.
	-- the upside to this is no math required -- the CAS does it all for you
	-- the downside is, well, at the moment you have to recompile every time a new particle is added.
	-- considering how linear an oscillator is, I'm sure this could be eliminated 
	-- (esp if I was storing spring edges somewhere, rather than making all particles share)
	self.symbolicParams = table()
	-- build parameter list to compile against
	for _,v in ipairs(self.particles) do
		for j=1,dim do
			self.symbolicParams:insert(v.q_[j])	-- position
			self.symbolicParams:insert(v.p_[j])	-- velocity
		end
	end
end

function EnergySystem:buildNumericParams()
	local numericParams = table()
	-- build parameter list to compile against
	for _,v in ipairs(self.particles) do
		for j=1,dim do
			numericParams:insert(v.q[j])	-- position
			numericParams:insert(v.p[j])	-- velocity
		end
	end
	return numericParams
end

function EnergySystem:setHamiltonian(H)
--print('Hamiltonian')
--print(H)
	self:buildSymbolicParams()
	-- compile evolution equations
	for _,v in ipairs(self.particles) do
		-- dq/dt = dH/dp is a function of p1..pn ... and maybe q1..qn
		v.dq_dt = vec()
		v.dp_dt = vec()
		for j=1,dim do
			local dH_dp = H:diff(v.p_[j])
			dH_dp = dH_dp:simplify()
			v.dq_dt[j] = dH_dp:compile(self.symbolicParams)
		
			local _dH_dq = -H:diff(v.q_[j])
			_dH_dq = _dH_dq:simplify()
			v.dp_dt[j] = _dH_dq:compile(self.symbolicParams)
		end
	end
end

-- define particles in the system
local system = EnergySystem()
local v1 = system:createVertex()
local v2 = system:createVertex()

do
	-- kinetic energy
	local K = v1.p_:lenSq() / (2 * v1.m) + v2.p_:lenSq() / (2 * v2.m)

	-- potential energy
	local restLength = 1
	local k = .1	-- spring constant
	local U = symmath.fraction(1,2) * k * (symmath.sqrt((v1.q_ - v2.q_):lenSq()) - restLength)^2

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
	system:setHamiltonian(H)
	-- and now each particle has its evolution equations
end

-- and integrate ... forward Euler

ts = table()
local columns = table{ts = ts}
local graphs = table()
for i,v in ipairs(system.particles) do 
	for j=1,dim do
		-- graph for position
		columns[v.q_[j].name] = table()
		graphs[v.q_[j].name] = {
			enabled = true,
			ts,
			assert(columns[v.q_[j].name]),
		}
		-- graph for velocity
		columns[v.p_[j].name] = table()
		graphs[v.p_[j].name] = {
			enabled = true,
			ts,
			assert(columns[v.p_[j].name]),
		}
	end
end

do
	-- initialize the numeric side of things
	v1.q[1] = 1
	v2.q[1] = -1
	
	local dt = .1
	local n = 1000
	local t = 0

	for i=1,n do
		-- forward Euler integration
		for _,v in ipairs(system.particles) do
			for j=1,dim do
				v.q[j] = v.q[j] + dt * v.dq_dt[j](unpack(system:buildNumericParams()))
				v.p[j] = v.p[j] + dt * v.dp_dt[j](unpack(system:buildNumericParams()))
				columns[v.q_[j].name]:insert(v.q[j])
				columns[v.p_[j].name]:insert(v.p[j])
			end
		end
		t = t + dt
		ts:insert(t)
	end

	-- TODO replace with your own graphing output *here*, like pipe to a text file and render in gnuplot or something
	local plot2d = require 'plot2d'
	plot2d(graphs)
end

