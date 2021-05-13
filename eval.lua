--[[
numerically evaluate the expression
vars = {
	{[variable/name] = [value/constant]},
	...
}
--]]
return function(expr, vars)
	local symmath = require 'symmath'

	for k,v in pairs(vars) do
		local k = k
		if type(k) == 'string' then k = var(k) end
		-- clone so we can handle numbers and variable constants
		expr = expr:replace(k, symmath.clone(v))
	end
	
	-- final simplify in case a variable constant was substituted,
	--  and we have a simplify() rule for it
	expr = expr()

	local f = expr:compile()
	return f()
end
