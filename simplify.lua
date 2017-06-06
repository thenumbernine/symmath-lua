local table = require 'ext.table'

local simplifyObj = {}

local function simplify(x, ...)
	local debugSimplifyLoops = require 'symmath'.debugSimplifyLoops

	local expand = require 'symmath.expand'
	local prune = require 'symmath.prune'
	local factor = require 'symmath.factor'
	local tidy = require 'symmath.tidy'
	local Invalid = require 'symmath.Invalid'
	local lastx
	
	local clone, stack
	if debugSimplifyLoops then
		-- [[ with stack trace on loop  
		clone = require 'symmath.clone'
		stack = table()
	end
	if stack then stack:insert(clone(x)) end
	x = prune(x, ...)
	if stack then stack:insert(clone(x)) end
	local i = 0
	repeat
		lastx = x	-- lastx = x invokes the simplification loop.  that means one of the next few commands operates in-place.
		
		x = expand(x, ...)	-- TODO only expand powers of sums if they are summed themselves  (i.e. only expand add -> power -> add)
		if stack then stack:insert(clone(x)) end
		x = prune(x, ...)
		if stack then stack:insert(clone(x)) end
		x = factor(x)
		if stack then stack:insert(clone(x)) end
		x = prune(x)
		if stack then stack:insert(clone(x)) end
		
		--do break end -- calling expand() again after this breaks things ...
		i = i + 1
	until i == 10 or x == lastx or getmetatable(x) == Invalid
	-- [[ debugging simplify loop stack trace
	if i == 10 then
		local Verbose = require 'symmath.tostring.Verbose'
		if stack then 
			for i,x in ipairs(stack) do
				io.stderr:write('simplify stack #'..i..'\n'..Verbose(x)..'\n')
			end
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
