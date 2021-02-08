local class = require 'ext.class'

local result, ffi = pcall(require, 'ffi')
ffi = result and ffi

-- used by ffi only
-- to work around this whole metatype knot
local newComplex

local complex
if not ffi then
	complex = class()

	-- can be called with any kind of #'s as parameters

	-- accepts (complex) or (re, im)
	function complex:init(re, im)
		if complex:isa(re) then
			self.re = re.re
			self.im = re.im
		elseif require 'symmath.Variable':isa(re) then
			self.init(re.value)
		else
			self.re = assert(tonumber(re))
			self.im = tonumber(im) or 0
		end
	end

	function complex:__tostring()
		if self.im == 0 then
			return tostring(self.re)
		elseif self.im > 0 then
			return tostring(self.re)..'+i'..tostring(self.im)
		elseif self.im < 0 then
			return tostring(self.re)..'-i'..tostring(math.abs(self.im))
		end
	end

else
	complex = {}
	complex.__index = complex
	setmetatable(complex, {
		__call = function(complex, ...)
			return newComplex(...)
		end,
	})

	-- called with class as 1st param
	function complex:isa(x)
		if type(x) ~= 'cdata' then return false end
		local xt = tostring(ffi.typeof(x))
		return xt == 'ctype<complex>'
			or xt == 'ctype<complex float>'
	end
end

function complex.__eq(a,b)
	if not complex:isa(a) or not complex:isa(b) then return false end
	a = complex(a)
	b = complex(b)
	return a.re == b.re and a.im == b.im
end

function complex.__concat(a,b)
	return tostring(a) .. tostring(b)
end

function complex.__unm(a)
	local re, im = complex.unpack(a)
	return complex(-re, -im)
end

function complex.__add(a,b)
	local are, aim = complex(a):unpack()
	local bre, bim = complex(b):unpack()
	return complex(are + bre, aim + bim) 
end

function complex.__sub(a,b)
	local are, aim = complex(a):unpack()
	local bre, bim = complex(b):unpack()
	return complex(are - bre, aim - bim) 
end

function complex.__mul(a,b)
	local are, aim = complex(a):unpack()
	local bre, bim = complex(b):unpack()
	return complex(
		are * bre - aim * bim,
		are * bim + aim * bre)
end

function complex.__div(a,b)
	return complex(a) * complex(b):inv()
end

-- a^b
-- exp(log(a^b))
-- exp(b log(a))
function complex.__pow(a,b)
	return (complex(b) * complex(a):log()):exp()
end

function complex.unpack(x)
	if type(x) == 'number' then return x, 0 end
	if complex:isa(x) then return x.re, x.im end
	error("can't complex-unpack a non-complex")
end

function complex:conj()
	return complex(self.re, -self.im)
end

function complex:norm()
	return self.re * self.re + self.im * self.im
end

function complex:inv()
	return self:conj() * (1/self:norm())
end

function complex.abs(a)
	local a = complex(a)
	return complex(math.sqrt(a:norm()), 0)
end

function complex:arg()
	return math.atan2(self.im, self.re)
end

function complex:log()
	return complex(math.log(self:abs().re), self:arg())
end

-- exp(a+ib) = exp(a) * exp(ib) = exp(a) (cos(b) + i sin(b))
function complex:exp()
	local re, im = complex.unpack(self)
	local expre = math.exp(re)
	return complex(
		expre * math.cos(im), 
		expre * math.sin(im))
end

function complex.sqrt(x)
	return complex(x)^.5
end

function complex.cbrt(x)
	return complex(x)^(1/3)
end

function complex.sin(x)
	local re, im = complex.unpack(x)
	return complex(
		math.sin(re) * math.cosh(im),
		math.cos(re) * math.sinh(im))
end

function complex.cos(x)
	local re, im = complex.unpack(x)
	return complex(
		math.cos(re) * math.cosh(im),
		-math.sin(re) * math.sinh(im))
end

function complex.tan(x)
	return complex.sin(x) / complex.cos(x)
end

function complex.asin(x)
	local i = complex(0,1)
	return -i * (
		i * x + (1 - x * x):sqrt()
	):log()
end

function complex.acos(x)
	local i = complex(0,1)
	return -i * (
		x + (x * x - 1):sqrt()
	):log()
end

function complex.atan(x)
	local i = complex(0,1)
	return .5 * i * (
		(1 - i * x):log() - (1 + i * x):log()
	)
end

function complex.atan2(y,x)
	local xre, xim = complex.unpack(x)
	local yre, yim = complex.unpack(y)
	if xre > 0 then return (y / x):atan() end
	if yre > 0 then return math.pi/2 - (x/y):atan() end
	if yre < 0 then return -math.pi/2 - (x/y):atan() end
	if xre < 0 then return (y/x):atan() + math.pi end
	return (y/x):atan()
end

function complex.sinh(x)
	local re, im = complex.unpack(x)
	return complex(
		math.sinh(re) * math.cos(im),
		math.cosh(re) * math.sin(im))
end

function complex.cosh(x)
	local re, im = complex.unpack(x)
	return complex(
		math.cosh(re) * math.cos(im),
		math.sinh(re) * math.sin(im))
end

function complex.tanh(x)
	return complex.sinh(x) / complex.cosh(x)
end

function complex.acosh(x)
	x = complex(x)
	return complex.log(x + complex.sqrt(x*x - 1))
end

function complex.asinh(x)
	x = complex(x)
	return complex.log(x + complex.sqrt(x*x + 1))
end

function complex.atanh(x)
	x = complex(x)
	return .5 * complex.log((1 + x) / (1 - x))
end

-- only after all the complex metatables and metatable.__index elements are set ...
-- (which means don't touch 'complex' after this)
if ffi then
	newComplex = ffi.metatype('complex', complex)
end

return complex
