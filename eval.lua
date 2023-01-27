--[[
numerically evaluate the expression
vars = {
	{[variable/name] = [value/constant]},
	...
}
--]]
return function(expr, vars)
	local symmath = require 'symmath'

	if vars then
		for k,v in pairs(vars) do
			if type(k) == 'string' then k = symmath.var(k) end
			-- clone so we can handle numbers and variable constants
			expr = expr:replace(k, symmath.clone(v))
		end
	end

	-- final simplify in case a variable constant was substituted,
	--  and we have a simplify() rule for it
	expr = expr()

	local f = expr:compile()
	return f()
end
