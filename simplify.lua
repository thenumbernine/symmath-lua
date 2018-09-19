local table = require 'ext.table'

local simplifyObj = {}

local function simplify(x, ...)
	-- I'm suspicious that arrays are getting into simplify loops because of them simplifying all expressions simultaneously ... 
	-- this doesn't make sense, but maybe it's true
	local Array = require 'symmath.Array'
	if Array.is(x) then
		x = x:clone()
		for i in x:iter() do
			x[i] = simplify(x[i])
		end
		return x
	end
	
	local symmath = require 'symmath'
	local debugSimplifyLoops = symmath.debugSimplifyLoops
	local simplifyMaxIter = symmath.simplifyMaxIter or 10

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
	until i == simplifyMaxIter or x == lastx or getmetatable(x) == Invalid
	-- [[ debugging simplify loop stack trace
	if i == simplifyMaxIter then
		local Verbose = require 'symmath.tostring.Verbose'
Verbose = require 'symmath'.tostring		
		if stack then 
			for i,xi in ipairs(stack) do
				io.stderr:write('simplify stack #'..i..'\n'..Verbose(xi)..'\n')
			end
		end
		io.stderr:write("simplification loop\n")
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
