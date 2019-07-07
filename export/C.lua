local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Language = require 'symmath.export.Language'
local C = class(Language)

--[[
this is really being used for OpenCL
hence all the redundant real type casts
TODO provide the type instead of using 'real'
also TODO - merge common stuff between this and export.Lua into the Language class
also TODO - fix differences with compile() and generate()
--]]

function C:wrapStrOfChildWithParenthesis(parentNode, childIndex, ...)
	local node = parentNode[childIndex]
	local sx = self:apply(node, ...)
	if not sx then return false end
	local s, predef = table.unpack(sx)
	if self:testWrapStrOfChildWithParenthesis(parentNode, childIndex) then
		s = '(' .. s .. ')'
	end
	return {s, predef}
end


C.lookupTable = {
	[require 'symmath.Constant'] = function(self, expr, vars)
		local s = tostring(expr.value)
		if not s:find'e' then
			if not s:find'%.' then s = s .. '.' end
		end
		return {s}
	end,
	[require 'symmath.Invalid'] = function(self, expr, vars)
		return {'NAN'}
	end,
	[require 'symmath.Function'] = function(self, expr, vars)
		local predefs = table()
		local s = table()
		for i,x in ipairs(expr) do
			local sx = self:apply(x, vars)
			s:insert(sx[1])
			predefs = table(predefs, sx[2])
		end
		s = s:concat(', ')
		
		local funcName
		if not expr.code then
			funcName = expr.name
		else
			funcName = expr.name
			predefs['real '..funcName..'(real x) {'..expr.code..'}'] = true
		end
		return {funcName .. '(' .. s .. ')', predefs}
	end,
	[require 'symmath.op.unm'] = function(self, expr, vars)
		local sx = self:wrapStrOfChildWithParenthesis(expr, 1, vars)
		return {'-'..sx[1], sx[2]}
	end,
	[require 'symmath.op.pow'] = function(self, expr, vars)
		if expr[1] == require 'symmath'.e then
			local sx = self:apply(expr[2], vars)
			return {'(real)exp((real)' .. sx[1] .. ')', sx[2]}
		else
			local predefs = table()
			local s = table()
			for i,x in ipairs(expr) do
				local sx = self:apply(x, vars)
				s:insert('(real)'..sx[1])
				predefs = table(predefs, sx[2])
			end
			s = s:concat(', ')
			return {'(real)pow(' .. s .. ')', predefs}	
		end
	end,
	[require 'symmath.op.Binary'] = function(self, expr, vars)
		local predefs = table()
		return {range(#expr):map(function(i)
			local sx = self:wrapStrOfChildWithParenthesis(expr, i, vars)
			predefs = table(predefs, sx[2])
			return sx[1]
		end):concat(' '..expr.name..' '), predefs}
	end,
	[require 'symmath.Variable'] = function(self, expr, vars)
		if table.find(vars, nil, function(var) 
			return expr.name == var.name 
		end) then
			return {expr.name}
		end
		error("tried to compile variable "..expr.name.." that wasn't in your function argument variable list!\n"
		..(require 'symmath.export.MultiLine')(expr))
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		error("can't compile differentiation.  replace() your diff'd content first!\n"
		..(require 'symmath.export.MultiLine')(expr))
	end,
	[require 'symmath.Array'] = function(self, expr, vars)
		error("can't compile arrays in C.  replace() your diff'd content first!\n"
		..(require 'symmath.export.MultiLine')(expr))
	end,
}

function C:compile(expr, paramInputs, args)
	local expr, vars = self:prepareForCompile(expr, paramInputs)
	local info = self:apply(expr, vars)
	local body = info[1]
	local predefs = info[2]
	local code = (predefs and #predefs > 0) and (table.keys(predefs):concat'\n'..'\n') or ''
	if not (args and args.hideHeader) then
		code = code..'('..
			vars:map(function(var) 	
				return 'real '..var.name
			end):concat(', ')
		..') { return '..body..'; }'
	else
		code = body
	end
	return code
end

function C:__call(...)
	return self:apply(...)[1]
end

return C()	-- singleton
