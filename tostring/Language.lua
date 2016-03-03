--[[
parent class of all language-specific ToString child classes
--]]

local class = require 'ext.class'
local ToString = require 'symmath.tostring.ToString'
local Language = class(ToString)

--[[
converts the flexible-yet-confusing input of parameters into a format that the language serializer can use
paramInputs: {var1, var2, {[expr3] = 'name3'}, ...}

replaces all non-Variable expressions with Variables of matching names
then generates the code
--]]
function Language:prepareForCompile(expr, paramInputs)
	local Variable = require 'symmath.Variable'
	local Expression = require 'symmath.Expression'
	
	assert(paramInputs)
	local vars = table()
	for _,paramInput in pairs(paramInputs) do
		if type(paramInput) == 'table' then
			if Expression.is(paramInput) then
				assert(Variable.is(paramInput), "can only implicitly use Variables for compile function parameters.  For non-variables, use {[expression] = 'parameter_name'}")
				vars:insert(paramInput)
			else 
				-- if it's a table and not an Expression (the root of our class tree)
				-- then assume it's a key/value pair
				local found = false
				for key,value in pairs(paramInput) do
					if not found then	-- only allow one key/value pair per list
						found = true
						assert(Expression.is(key), "expected key to be an Expression")
						local tmpvar = Variable(tostring(value))
						vars:insert(tmpvar)
						expr = expr:replace(key, tmpvar)
					else
						error("for multiple key/value pairs use multiple tables.  i.e. instead of {[expr1]='var1', [expr2]='var2'} use {[expr1]='var1'}, {[expr2]='var2'}.  This way parameter order is preserved.")
					end
				end
			end
		else
			error("compile parameters can only be Expression or {[Expression] = 'parameter_name'}")
		end
	end
	return expr, vars
end

return Language

