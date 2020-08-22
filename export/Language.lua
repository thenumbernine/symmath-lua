--[[
parent class of all language-specific Export child classes
--]]

local class = require 'ext.class'
local table = require 'ext.table'
local Export = require 'symmath.export.Export'


local Language = class(Export)

--[[
args:
	input = {var1, var2, {name3=var3}, ...}
	output = {expr1, expr2, {name3=expr3}, ...}
--]]
function Language:toCode(args)
	local input = args.input	-- does it matter if there are explicitly specified inputs?  maybe only if we want a function prototype?
	local output = assert(args.output)
	local output, input = self:prepareToCodeArgs(output, input)
	assert(input)
	return self:toCodeInternal(output, input)
end

--[[
converts the flexible-yet-confusing input of parameters into a format that the language serializer can use
inputs: {var1, var2, {name3=expr3}, ...}

replaces all non-Variable expressions with Variables of matching names
then generates the code
--]]
function Language:prepareToCodeArgs(outputs, inputs)
	local Variable = require 'symmath.Variable'
	local Expression = require 'symmath.Expression'
	inputs = inputs or {}
	
	assert(not Expression.is(outputs), "prepareToCodeArgs() expects arg 1 to be a non-Expression")
	local fixedOutputs = table()
	for i,output in ipairs(outputs) do
		if type(output) == 'table' then
			if Expression.is(output) then
				fixedOutputs:insert{name='out'..i, expr=output}
			else
				-- TODO maybe, make sure this is only one entry?
				local name, expr = next(output)
				local name2, expr2 = next(output, name)
				assert(name2 == nil and expr2 == nil, "expected output elements to be single-entry tables of {[name] = Expression}")
				fixedOutputs:insert{name=name, expr=expr}
			end
		else
			error("output table entries should be either expr or {name=expr}")
		end
	end
	
	local fixedInputs = table()
	for _,input in ipairs(inputs) do
		if type(input) == 'table' then
			if Expression.is(input) then
				assert(Variable.is(input), "can only implicitly use Variables for compile function parameters.  For non-variables, use {parameter_name = expression}")
				fixedInputs:insert(input)
			else 
				-- if it's a table and not an Expression (the root of our class tree)
				-- then assume it's a key/value pair
				local found = false
				for key,value in pairs(input) do
					if not found then	-- only allow one key/value pair per list
						found = true
						assert(Expression.is(value), "expected parameter pair value to be an Expression")
						local tmpvar = Variable(tostring(key))
						fixedInputs:insert(tmpvar)
						for _,output in ipairs(fixedOutputs) do
							output.expr = output.expr:replace(value, tmpvar)
						end
					else
						error("for multiple key/value pairs use multiple tables.  i.e. instead of {var1=expr1, var2=expr2} use {var1=expr1}, {var2=expr2}.  This way parameter order is preserved.")
					end
				end
			end
		else
			error("compile parameters can only be Expression or {parameter_name = Expression} ... got type "..type(paramInput))
		end
	end

	return fixedOutputs, fixedInputs
end


function Language:toCodeInternal(outputs, vars)
	local exprs = table.mapi(outputs, function(output)
		return output.expr:clone()
	end)

	local symmath = require 'symmath'
	local Expression = symmath.Expression
	local SingleLine = symmath.export.SingleLine
	local Variable = symmath.Variable
	local Constant = symmath.Constant

-- [=[ replace x^n for integer 1 <= n < 100 with (x * x * ... * ) x n
	-- represent integers as expanded multiplication
	exprs = exprs:mapi(function(expr)
		return expr:map(function(x)
			if symmath.op.pow.is(x) then
				if Constant.is(x[2]) then
					local n = x[2].value
					if n == math.floor(n) and n >= 0 and n < 100 then
						if n == 0 then return Constant(1) end
						if n == 1 then return x end
						return setmetatable(table.rep({x[1]}, n), symmath.op.mul)
					end
				end
			end
		end)
	end)
--]=]

-- [=[
	local allsubexprinfos = table()	
	local function recurse(expr)
		local totalCount = 1
		for _,x in ipairs(expr) do
			if Expression.is(x) 
			and not Constant.is(x)
			then
				local count = recurse(x)
				totalCount = totalCount + count
				if count > 1 then
					allsubexprinfos:insert{expr=x, count=count}
				end
			else
				totalCount = totalCount + 1
			end
		end
		return totalCount
	end
	for _,expr in ipairs(exprs) do
		recurse(expr)
	end

	-- sort by size, largest to smallest
	allsubexprinfos:sort(function(a,b)
		return a.count > b.count
	end)
	-- remove duplicates
	for i=#allsubexprinfos-1,1,-1 do
		if allsubexprinfos[i].expr == allsubexprinfos[i+1].expr then
			allsubexprinfos:remove(i)
		end
	end

--[[
print('FOR EXPR '..SingleLine(expr))
print'BEGIN ALL SUBEXPRS'
for _,s in ipairs(allsubexprinfos) do
	print(s.count, SingleLine(s.expr))
end
print'END ALL SUBEXPRS'
print()
--]]

	local varindex = 0
	-- TODO assert that this variable name doesn't exist in the expression
	local function newvarname()
		varindex = varindex + 1
		return 'tmp'..varindex
	end
	
	local tmpvardefs = table()
	for _,subexprinfo in ipairs(allsubexprinfos) do
		local subexpr = subexprinfo.expr
--[[
print('CHECKING SUBEXPR '..SingleLine(subexpr))
--]]
		-- first see how many occurences there are
		-- only replace the sub-expression if there are more than 1 occurrences of it
		local found
		local count = 0
		local function recurse(expr)
			for i=1,#expr do
				local x = expr[i]
				if Expression.is(x)
				and not Constant.is(x)
				then
					if x == subexpr then
						count = count + 1
						if count >= 2 then 
							found = true
							return
						end
					end
					recurse(x)
					if found then return end
				end
			end
		end
		for j=1,#tmpvardefs do
			recurse(tmpvardefs[j][2])
		end
		for _,expr in ipairs(exprs) do
			recurse(expr)
		end

		if found then
			local tmpvar
			local function recurse(expr)
				for i=1,#expr do
					local x = expr[i]
					if Expression.is(x) 
					and not Constant.is(x)
					then
						if x == subexpr then
							if not tmpvar then
								tmpvar = Variable(newvarname())
								local tmpvardef = tmpvar:eq(subexpr)
--[[
print('REPLACING TMPVAR DEF '..SingleLine(tmpvardef))								
--]]
								tmpvardefs:insert(tmpvardef)
							end
							expr[i] = tmpvar
						end
						recurse(x)
					end
				end
			end
			for j=1,#tmpvardefs do
				recurse(tmpvardefs[j][2])
			end
			for _,expr in ipairs(exprs) do
				recurse(expr)
			end
		end
	end
--[[
print('RESULTING EXPR '..SingleLine(expr))
--]]
--]=]

	-- TODO parameter
	local genParams = self.generateParams or {}
	
	local localType = genParams.localType
	localType = localType and #localType > 0 and localType..' ' or ''
	
	local lineEnd = genParams.lineEnd or ''
	
	local lines = table()
	-- TODO keep track of what vars are used, and compare it to the vars in the compile, to ensure correct code is generated...?

	for i=#tmpvardefs,1,-1 do
		local tmpvardef = tmpvardefs[i]
		local subname,subexpr = table.unpack(tmpvardef)
		lines:insert(localType..subname.name..' = '..(self:apply(subexpr))..lineEnd)
	end

	for i,expr in ipairs(exprs) do
		local body, predefs = self:apply(expr, vars)
-- [=[ TODO what to do with predefs...  it was a first attempt at the subtree multi-expr generation 
		if predefs then
			lines:append(table.keys(predefs))
		end
--]=]
		lines:insert(localType..outputs[i].name..' = '..body..lineEnd)
	end
	
	return lines:concat'\n'
end

--[[
args:
	input = ...
	output = ...
	func = name of function to generate
--]]
function Language:toFuncCode(args)
	local genParams = self.generateParams or {}
	
	local argType = genParams.funcArgType
	argType = argType and #argType > 0 and (argType..' ') or ''
	
	local outputs, inputs = self:prepareToCodeArgs(args.output, args.input)

	local lineEnd = genParams.lineEnd or ''

	local funcHeader
	if genParams.funcHeader then
		funcHeader = genParams.funcHeader(name, inputs)
	else
		funcHeader = 
			(genParams.funcHeaderStart and genParams.funcHeaderStart(args.func or 'f', inputs) or '')
			..inputs:mapi(function(input)
				return argType..input.name
			end):concat', '
			..(genParams.funcHeaderEnd or '')
	end

	return table{
		funcHeader,
		'\t'..self:toCodeInternal(outputs, inputs):gsub('\n', '\n\t'),
	}:append{
		genParams.prepareOutputs and genParams.prepareOutputs(outputs) or nil,
	}:append{	
		(function()
			local ret = genParams.returnCode
			if ret then return ret(outputs) end
			return '\treturn '..outputs:mapi(function(output) return output.name end):concat', '..lineEnd
		end)()
	}:append{
		genParams.funcFooter or nil,
	}:concat'\n'
end

return Language
