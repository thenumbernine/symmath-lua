--[[
parent class of all language-specific Export child classes
--]]

local class = require 'ext.class'
local table = require 'ext.table'
local Export = require 'symmath.export.Export'


local Language = class(Export)

Language.name = 'Language'

--[[
args:
	input = these are input parameters.  honestly they aren't used in 'toCode' anymore, only 'toFuncCode'.
			it's in the form:
			{var1, var2, {name3=var3}, ...}
	output = this is what expressions are converted to code.
			it's in the form:
			{expr1, expr2, {name3=expr3}, ...}		
	other arguments are forwarded on to toCodeInternal
--]]
function Language:toCode(args)
	local input = args.input	-- does it matter if there are explicitly specified inputs?  maybe only if we want a function prototype?
	local output = assert(args.output)
	local output, input = self:prepareToCodeArgs(output, input)
-- TODO seems to be an error, if you use {name=expr} instead of just expr then the order of tmps is backwards	
	assert(input)
	return self:toCodeInternal(table(args, {
		output = output, 
		input = input, 
	}))
end

--[[
converts the flexible-yet-confusing input of parameters into a format that the language serializer can use
inputs: {var1, var2, {name3=expr3}, ...}

replaces all non-Variable expressions with Variables of matching names
then generates the code

returns fixedInputs, fixedOutputs
fixedInputs is a list of variables
fixedOutputs is a list of {name=string, expr=Expression}
--]]
function Language:prepareToCodeArgs(outputs, inputs)
	local Variable = require 'symmath.Variable'
	local Expression = require 'symmath.Expression'
	inputs = inputs or {}
	
	assert(not Expression:isa(outputs), "prepareToCodeArgs() expects arg 1 to be a non-Expression")
	local fixedOutputs = table()
	for i,output in ipairs(outputs) do
		if type(output) == 'table' then
			if Expression:isa(output) then
				fixedOutputs:insert{name='out'..i, expr=output}
			else
				-- TODO maybe, make sure this is only one entry?
				local name, expr = next(output)
				local name2, expr2 = next(output, name)
				assert(name2 == nil and expr2 == nil, "expected output elements to be single-entry tables of {[name] = Expression}, but found more than one entry")
				assert(Expression:isa(expr), "expected output elements to be a table of {[name] = Expression}, but didn't find an expression")
				fixedOutputs:insert{name=name, expr=expr}
			end
		else
			error("output table entries should be either expr or {name=expr}")
		end
	end
	
	local fixedInputs = table()
	for _,input in ipairs(inputs) do
		if type(input) == 'table' then
			if Expression:isa(input) then
				assert(Variable:isa(input), "can only implicitly use Variables for compile function parameters.  For non-variables, use {parameter_name = expression}")
				fixedInputs:insert(input)
			else 
				-- if it's a table and not an Expression (the root of our class tree)
				-- then assume it's a key/value pair
				local found = false
				for key,value in pairs(input) do
					if not found then	-- only allow one key/value pair per list
						found = true
						assert(Expression:isa(value), "expected parameter pair value to be an Expression")
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


--[[
args:
	input = list of variables to use
	output = list of expressions to generate
	notmp = don't produce tmpvars to cache reused expression trees
	dontExpandIntegerPowers = don't do this
--]]
function Language:toCodeInternal(args)
	local vars = assert(args.input)
	local disableTmpVars = args.notmp

	-- here is the last time that outputs[i].expr is used, though outputs[i].name is used later
	local outputs = assert(args.output)
	local exprs = table.mapi(outputs, function(output)
		return output.expr:clone()
	end)

	local symmath = require 'symmath'
	local Expression = symmath.Expression
	local SingleLine = symmath.export.SingleLine
	local Variable = symmath.Variable
	local Constant = symmath.Constant

	-- replace x^n for integer 1 <= n < 100 with (x * x * ... * ) x n
	-- represent integers as expanded multiplication
	if not args.dontExpandIntegerPowers then
		exprs = exprs:mapi(function(expr)
			return expr:map(function(x)
				if symmath.op.pow:isa(x) then
					if Constant:isa(x[2]) then
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
	end

	--[[
	from this point on, there's no operations on the exprs except traversal and replacement
	so for the sake of the tmpvar generation, I have an issue...
	the tmpvars cache subtrees
	but the * and + operators are flattened tree nodes
	so even if a+b is found inside of a+b+c and a+b+d, it will not match in this algorithm because the trees are exact.
	how to get around this?
	
	exhaustive: when counting trees, count all permutations of + and * subtrees, and then when replacing them later, chop them up
	
	combined: when chopping them up, count which subtree is most often used, and then chop up now accordingly.  
		the challenge is whatever counts go towards copies of the + or * permutation subtrees that match elsewhere will have to be thrown away if that particular chop scheme isn't used
		because, depending on what subtree partition choices you use, the counts of other trees will be affected.

	lazy: just chop them up arbitrarily now
	
	of course for now I'm doing the lazy method.
	--]]
	-- [[
	do
		local function recurse(x)
			for i=1,#x do
				recurse(x[i])
			end
			if symmath.op.add:isa(x) or symmath.op.mul:isa(x) then
				local mt = getmetatable(x)
				-- manually construct/modify, don't use constructor, or it will auto-flatten
				local n = #x
				assert(n >= 2)
				while n > 2 do
					local nn = n - 1
					x[nn] = setmetatable({x[nn], x[n]}, mt)
					x[n] = nil
					n = nn
				end
			end
		end
		recurse(exprs)
	end
	--]]

	local tmpvardefs = table()
	if not disableTmpVars then
	
		local varindex = 0
		-- TODO assert that this variable name doesn't exist in the expression
		local function newvarname()
			varindex = varindex + 1
			return 'tmp'..varindex
		end


		--[=[ exhaustively enumerate all subtrees, then replace duplicates with temp vars

		local allsubexprinfos = table()	
		local function recurse(expr)
			local totalCount = 1
			for _,x in ipairs(expr) do
				totalCount = totalCount + recurse(x)
			end
			
			if Expression:isa(expr) 
			and not Constant:isa(expr)
			and totalCount > 1
			then
				allsubexprinfos:insert{expr=expr, count=totalCount}
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

-- [[
print('FOR EXPR '..SingleLine(expr))
print'ALL SUBEXPRS, SORTED BY SIZE:'
print'BEGIN ALL SUBEXPRS'
for _,s in ipairs(allsubexprinfos) do
	print(s.count, SingleLine(s.expr))
end
print'END ALL SUBEXPRS'
print()
--]]

		-- remove duplicates
		for i=#allsubexprinfos-1,1,-1 do
			if allsubexprinfos[i].expr == allsubexprinfos[i+1].expr then
print('REMOVING DUPLICATE '..SingleLine(allsubexprinfos[i].expr))
				allsubexprinfos:remove(i)
			end
		end

-- [[
print'AFTER REMOVE:'
print'BEGIN ALL SUBEXPRS'
for _,s in ipairs(allsubexprinfos) do
	print(s.count, SingleLine(s.expr))
end
print'END ALL SUBEXPRS'
print()
--]]

		for _,subexprinfo in ipairs(allsubexprinfos) do
			local subexpr = subexprinfo.expr
-- [[
print('CHECKING SUBEXPR '..SingleLine(subexpr))
--]]
			-- first see how many occurences there are
			-- only replace the sub-expression if there are more than 1 occurrences of it
			local found
			local count = 0
			local function recurse(expr)
				for i=1,#expr do
					local x = expr[i]
					if Expression:isa(x)
					and not Constant:isa(x)
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
			
			-- don't allow entire tmpvars[i] to be replaced with other tmpvars, (that would be redundant), only tmpvars[i][j] etc
			for j=1,#tmpvardefs do
				recurse(tmpvardefs[j][2])
			end
			
			-- allow exprs[i] to be replaced with tmpvars
			recurse(exprs)

			if found then
				local tmpvar
				local function recurse(expr)
					for i=1,#expr do
						local x = expr[i]
						if Expression:isa(x) 
						and not Constant:isa(x)
						then
							if x == subexpr then
								if not tmpvar then
									tmpvar = Variable(newvarname())
									local tmpvardef = tmpvar:eq(subexpr)
-- [[
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
				recurse(exprs)
			end
		end
-- [[
print('RESULTING EXPR '..SingleLine(expr))
--]]
--]=]

-- [=[
-- ok here's another option ...
-- instead of enumerating all subtrees, counting frequency of usage, etc
-- how about assigning temp vars to all subtrees irrespective of their redundancy?
-- and sort them by the tree height
-- and last, remove redundant tmp vars ... that will still require a tree compare, which is slow ...

		local function recurse(expr)
			for i=1,#expr do
				recurse(expr[i])
			end

			for i=1,#expr do
				local x = expr[i]
				if Expression:isa(x)
				and not Constant:isa(x)
				and #x > 0
				then				
					local tmpvar = Variable(newvarname())
					local tmpvardef = tmpvar:eq(x)
--[[
print('REPLACING TMPVAR DEF '..SingleLine(tmpvardef))
--]]
					tmpvardefs:insert(1, tmpvardef)
					expr[i] = tmpvar
				end
			end
		end
		recurse(exprs)

		-- combine repeated temp vars
		tmpvardefs = tmpvardefs:reverse()
		local i = 2
		local used = tmpvardefs:mapi(function(def) 
			return 1, def[1].name 
		end)
		while i <= #tmpvardefs do
			for j=1,i-1 do
				if tmpvardefs[i][2] == tmpvardefs[j][2] then
--[[
print('MERGING TMPVARS '..tmpvardefs[i][1]..' AND '..tmpvardefs[j][1])
--]]
					for k=1,#tmpvardefs do
						tmpvardefs[k][2] = tmpvardefs[k][2]:replace(tmpvardefs[i][1], tmpvardefs[j][1])
					end
					for k=1,#exprs do
						exprs[k] = exprs[k]:replace(tmpvardefs[i][1], tmpvardefs[j][1])
					end
					used[tmpvardefs[j][1].name] = used[tmpvardefs[j][1].name] + used[tmpvardefs[i][1].name]
					used[tmpvardefs[i][1].name] = nil
					tmpvardefs:remove(i)
					i = i - 1
					break
				end
			end
			i = i + 1
		end
--print(require'ext.tolua'(used))	
		-- [[ reinsert temp vars used only once
		for i=#tmpvardefs,1,-1 do
			local def = tmpvardefs[i]
			if used[def[1].name] == 1 then
				for j=i+1,#tmpvardefs do
					tmpvardefs[j][2] = tmpvardefs[j][2]:subst(def)
				end
				for j=1,#exprs do
					exprs[j] = exprs[j]:subst(def)
				end
				tmpvardefs:remove(i)
				used[def[1].name] = nil
			end
		end
		--]]
		-- now if used[j] is not set then you can substitute it into whoever is using it
		tmpvardefs = tmpvardefs:reverse()
--]=]
	end

	-- TODO parameter
	local genParams = self.generateParams or {}
	
	local localType = genParams.localType
	if type(localType) == 'function' then localType = localType(self) end
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
	input = {var1, var2, {name3=var3}, ...}
	output = {expr1, expr2, {name3=expr3}, ...}
	func = name of function to generate
	other arguments are forwarded on to toCodeInternal
--]]
function Language:toFuncCode(args)
	local genParams = self.generateParams or {}
	
	local argType = genParams.funcArgType
	if type(argType) == 'function' then argType = argType(self) end
	argType = argType and #argType > 0 and (argType..' ') or ''
	
	local outputs, inputs = self:prepareToCodeArgs(args.output, args.input)

	local lineEnd = genParams.lineEnd or ''

	local funcHeader
	if genParams.funcHeader then
		funcHeader = genParams.funcHeader(name, inputs)
	else
		funcHeader = 
			(genParams.funcHeaderStart and genParams.funcHeaderStart(self, args.func or 'f', inputs) or '')
			..inputs:mapi(function(input)
				return argType..input:nameForExporter(self)
			end):concat', '
			..(genParams.funcHeaderEnd or '')
	end

	return table{
		funcHeader,
		'\t'..self:toCodeInternal(
			table(args, {
				output = outputs,
				input = inputs,
			})
		):gsub('\n', '\n\t'),
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

-- helper for subclasses.  TODO make this a rule here, and have subclasses copy rules from parent class.
function Language:varNameForTensorRef(expr)
	return table.mapi(expr, function(x)
		return self:apply(x)
	end):concat()
end

return Language
