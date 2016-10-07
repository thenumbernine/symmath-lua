local table = require 'ext.table'

local simplifyObj = {}

local function simplify(x, ...)
	local expand = require 'symmath.expand'
	local prune = require 'symmath.prune'
	local factor = require 'symmath.factor'
	local tidy = require 'symmath.tidy'
	local Invalid = require 'symmath.Invalid'
	local lastx
	-- [[ with stack trace on loop  
	local clone = require 'symmath.clone'
	local stack = table()
	stack:insert(clone(x))
	--]]
	local i = 0
	repeat
		lastx = x	-- lastx = x invokes the simplification loop.  that means one of the next few commands operates in-place.
		
		x = expand(x, ...)	-- TODO only expand powers of sums if they are summed themselves  (i.e. only expand add -> power -> add)
		stack:insert(clone(x))
		x = prune(x, ...)
		stack:insert(clone(x))
		x = factor(x)
		stack:insert(clone(x))
		x = prune(x)
		stack:insert(clone(x))
		
		--do break end -- calling expand() again after this breaks things ...
		i = i + 1
	until i == 10 or x == lastx or getmetatable(x) == Invalid
	-- [[ debugging simplify loop stack trace
	if i == 10 then
		local Verbose = require 'symmath.tostring.Verbose'
		for i,x in ipairs(stack) do
			io.stderr:write('simplify stack #'..i..'\n'..Verbose(x)..'\n')
		end
		error("simplification loop")
	end
	--]]
	x = tidy(x, ...)

	simplifyObj.stack = stack

	return x
end

setmetatable(simplifyObj, {
	__call = function(_, ...)
		return simplify(...)
	end
})

return simplifyObj
