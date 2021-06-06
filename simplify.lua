local table = require 'ext.table'

local symmath

local simplifyObj = {}
	
simplifyObj.simplifyMaxIter = 10

simplifyObj.useTrigSimplify = true

--[[
whether to debug simplification loops
set this to true for default behavior
set this to "rules" to also insert each rule applied during each visitor phase of simplify() 
 but this goes much slower(?)
--]]
simplifyObj.debugLoops = false

local function simplifyCall(simplifyObj, x, ...)
	symmath = symmath or require 'symmath'
--return timer('simplify', function(...)
--print('start', require 'symmath.export.SingleLine'(x))	
	-- I'm suspicious that arrays are getting into simplify loops because of them simplifying all expressions simultaneously ... 
	-- this doesn't make sense, but maybe it's true
	if symmath.Array:isa(x) then
		x = x:clone()
		for i in x:iter() do
			x[i] = simplifyCall(x[i])
		end
		return x
	end

	local simplifyMaxIter = simplifyObj.simplifyMaxIter

	local expand = symmath.expand
	local prune = symmath.prune
	local factor = symmath.factor
	local tidy = symmath.tidy
	local Invalid = symmath.Invalid
	local lastx
	
	local clone, stack
	if simplifyObj.debugLoops then
		-- [[ with stack trace on loop  
		clone = symmath.clone
		stack = table()
	end
	
	-- TODO if we get nested calls then this gets overwritten and we lose the ability for Visitor to store extra rules ... 
	-- unless instead we return this object, so we don't rely on globals
	simplifyObj.stack = stack
	
	if stack then stack:insert{'Init', clone(x)} end
		
	x = prune(x, ...)
	if stack then stack:insert{'Prune', clone(x)} end
	
	local i = 0
	repeat
		lastx = x	-- lastx = x invokes the simplification loop.  that means one of the next few commands operates in-place.
	
		x = expand(x, ...)	-- TODO only expand powers of sums if they are summed themselves  (i.e. only expand add -> power -> add)
		if stack then stack:insert{'Expand', clone(x)} end

		x = prune(x, ...)
		if stack then stack:insert{'Prune', clone(x)} end
		
		x = factor(x)
		if stack then stack:insert{'Factor', clone(x)} end
		
		x = prune(x)
		if stack then stack:insert{'Prune', clone(x)} end

-- [==[ goes horribly slow
if simplifyObj.useTrigSimplify then
--timer('trigsimp', function(...)
		
		-- trigonometric
		-- where to put this, since doing one or the other means the other or the one missing out on div etc simplifications
		
		if x.map then
--printbr('testing for trig squares:', x)				
			local sin = symmath.sin
			local cos = symmath.cos
			local Constant = symmath.Constant
			local found
			-- cos(x)^n => (1 - sin(x)^2) cos(x)^(n-2)
			x = x:map(function(expr)
				if cos:isa(expr[1])
				and Constant:isa(expr[2])
				then
					local n = expr[2].value
					if n >= 2
					and n <= 10
					and n == math.floor(n)
					then
						local th = expr[1][1]
						found = true
--printbr'here cos->sin'
						if n==2 then
							return 1 - sin(th:clone())^2
						elseif n==3 then
							return (1 - sin(th:clone())^2) * cos(th:clone())
						else
							return (1 - sin(th:clone())^2) * cos(th:clone())^(n-2)
						end
					end
				end
			end)
			if found then
--printbr(x)
				x = expand(x, ...)
--printbr(x)
				x = prune(x, ...)
--printbr(x)
				x = factor(x, ...)
--printbr(x)
				x = prune(x, ...)
--printbr(x)
			end

			found = false
			x = x:map(function(expr)
				-- TODO this isn't being called
				-- where to put sin^2(theta) -> 1 - cos^2(theta) ...
				if sin:isa(expr[1])
				and Constant:isa(expr[2])
				then
					local n = expr[2].value
					if n >= 2
					and n <= 10
					and n == math.floor(n)
					then
						local th = expr[1][1]
						found = true
--printbr'here sin->cos'
						if n==2 then
							return 1 - cos(th:clone())^2
						elseif n==3 then
							return (1 - cos(th:clone())^2) * sin(th:clone())
						else
							return (1 - cos(th:clone())^2) * sin(th:clone())^(n-2)
						end
					end
				end		
			end)
			if found then
--printbr(x)
				x = expand(x, ...)
--printbr(x)
				x = prune(x, ...)
--printbr(x)
				x = factor(x, ...)
--printbr(x)
				x = prune(x, ...)
--printbr(x)
			end
		end
--print('trigsimp size', x:countNodes())
--end, ...)
end
--]==]
	
		--do break end -- calling expand() again after this breaks things ...
		i = i + 1
	until i == simplifyMaxIter or x == lastx or getmetatable(x) == Invalid
-- [[ debugging simplify loop stack trace
	if i == simplifyMaxIter then
local print = printbr or print
print('reached maxiter', simplifyMaxIter)
		if stack then 
			local SingleLine = symmath.export.SingleLine
			for i,kv in ipairs(stack) do
				local op, xi = table.unpack(kv)
				io.stderr:write('simplify stack #'..i..':\t'..op..'\t'..SingleLine(xi)..'\n')
				print('simplify stack #'..i..':\t'..op..'\t'..SingleLine(xi))
			end
		end
		io.stderr:write("simplification loop\n")
		print("simplification loop")
		io.stderr:write(debug.traceback()..'\n')
		print(debug.traceback())
	end
--]]
		
	x = tidy(x, ...)
	if stack then stack:insert{'Tidy', clone(x)} end

	simplifyObj.stack = stack

--print('end', require 'symmath.export.SingleLine'(x))	
	return x
--end, ...)
end

setmetatable(simplifyObj, {
	__call = simplifyCall,
})

return simplifyObj
