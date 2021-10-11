#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'tests/unit/index_construction')

timer(nil, function()

env.a = var'a'

for _,line in ipairs(string.split(string.trim([=[
local x=a'i' 	print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false})	-- upper by default
local x=a'^i' 	print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false})
local x=a'_i' 	print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true})
local x=a'ij' 	print(x)	assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=false})
local x=a'i_j' 	print(x)	assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=true})
local x=a'^ij' 	print(x)	assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=false})
local x=a'^i_j'	print(x)	assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false} and x[3]==Tensor.Index{symbol='j', lower=true})
local x=a'_i^j'	print(x)	assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true} and x[3]==Tensor.Index{symbol='j', lower=false})
local x=a'_ij' 	print(x)	assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true} and x[3]==Tensor.Index{symbol='j', lower=true})

-- multi-char
local x=a' i' 			print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false})	-- upper by default
local x=a' \\mu' 		print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='\\mu', lower=false})	-- upper by default
local x=a' ^\\mu' 		print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='\\mu', lower=false})
local x=a' _\\mu' 		print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='\\mu', lower=true})
local x=a' \\mu \\nu' print(x)	assert(#x==3 and x[1]==a and x[2]==Tensor.Index{symbol='\\mu', lower=false} and x[3]==Tensor.Index{symbol='\\nu', lower=false})

local x=a',i'	print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true, derivative=','})	-- commas are lower by default
local x=a',^i'	print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false, derivative=','})
local x=a',_i'	print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true, derivative=','})
local x=a'^,i'	print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=false, derivative=','})
local x=a'_,i'	print(x)	assert(#x==2 and x[1]==a and x[2]==Tensor.Index{symbol='i', lower=true, derivative=','})

-- TODO multiple indexes with commas mixed
-- TODO multiple indexes with commas mixed with multiple chars

simplifyAssertNe(a'^,i', a'_,i')

]=]), '\n')) do
	env.exec(line)
end

end)
