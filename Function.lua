local Expression = require 'symmath.Expression'

local Function = Expression:subclass()
Function.precedence = 10	-- high since it will always show parenthesis
Function.name = 'Function'

-- What if someone wants to print(symmath.sin) without a parameter print(symmath.sin(x)) ?
-- Should I override the function's metatable here to print the function names out?

return Function
