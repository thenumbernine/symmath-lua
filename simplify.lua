--[[
histogram of number of iterations it takes to reach a steady state:
1	982
2	3547
3	425
4	19
--]]
return function(x, ...)
--print('=========================')
--print('beginning simplification!')
--print('=========================')
	local expand = require 'symmath.expand'
	local prune = require 'symmath.prune'
	local factor = require 'symmath.factor'
	local tidy = require 'symmath.tidy'
	local Invalid = require 'symmath.Invalid'
	local lastx
	-- [[ with stack trace on loop  
	local clone = require 'symmath.clone'
	local simplifyStack = table()
	simplifyStack:insert(clone(x))
	--]]
	local i = 0
	repeat
		lastx = x	-- lastx = x invokes the simplification loop.  that means one of the next few commands operates in-place.
		x = expand(x, ...)	-- TODO only expand powers of sums if they are summed themselves  (i.e. only expand add -> power -> add)
		x = prune(x, ...)
		x = factor(x)
		x = prune(x)
		--do break end -- calling expand() again after this breaks things ...
	-- [[ with stack trace 
		simplifyStack:insert(clone(x))
	--]]
		i = i + 1
	until i == 10 or x == lastx or getmetatable(x) == Invalid
	-- [[ debugging simplify loop stack trace
	if i == 10 then
		local Verbose = require 'symmath.tostring.Verbose'
		for i,x in ipairs(simplifyStack) do
			io.stderr:write('simplify stack #'..i..'\n'..Verbose(x)..'\n')
		end
		error("simplification loop")
	end
	--]]
	x = tidy(x, ...)
	return x
end

