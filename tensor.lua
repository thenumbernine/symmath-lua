--[[

    File: tensor.lua 

    Copyright (C) 2000-2014 Christopher Moore (christopher.e.moore@gmail.com)
	  
    This software is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
  
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
  
    You should have received a copy of the GNU General Public License along
    with this program; if not, write the Free Software Foundation, Inc., 51
    Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--]]



--[[
this is just a regex means of defining multiple assignments and summing across indexes
it isn't a good data structure and doesn't handle index gymnastics or comma or semicolon derivatives
for all of that, see my 'tensor' package (rather than this, which is 'symmath.tensor')
--]]

local symmath = require 'symmath'

-- tensor isn't too compatible with the MathJax string output (or any other except SingleLine) since it appends tostring'd variables, and MathJax has its \( \) around every tostring() output
--  TODO make tensor more flexible 
symmath.toStringMethod = require 'symmath.tostring.LaTeX'

local MathJax = require 'symmath.tostring.MathJax'
print(MathJax.header)

local oldPrint = print
local function print(...)
	oldPrint(...)
	oldPrint('<br>')
end

local tensor = {}

--[[
map of the following format:
coordSrcs[1] is the default coordinate list (of symmath variables)
coordSrcs[k] is any other custom variable list.  k is a string of all indexes used to reference those variables

current assumptions:
	1) that indexes are a single letter (and with a $-prefix) -- otherwise I'd have to change the mechanism of specifying them in tensor.coords()
	2) that all index lists are the same dimension -- otherwise I'd have to change rank() to lookup each associated coordinate list and use that list's upper bound
--]]
local coordSrcs

function tensor.coords(newCoords)
	local oldCoords = coordSrcs
	if newCoords ~= nil then coordSrcs = newCoords end
	return oldCoords
end

function tensor.lookupCoordSrc(index)
	-- right now we only support $a $b etc
	-- otherwise I'd need to better define coordinate mapping in tensor.coords()
	if not (type(index) == 'string' and #index == 1) then
		error("got a bad index "..type(index)..' '..tostring(index))
	end

	for k,v in pairs(coordSrcs) do
		if type(k) == 'string' then
			if k:find(index,1,true) then
				return v
			end
		end
	end
	return assert(coordSrcs[1], "didn't find a default coordinate list")
end

function tensor.lookupVarsForIndexes(names, indexes)
	local vars = table()
	for i=1,#names do
		local coordSrc = tensor.lookupCoordSrc(names[i])
		vars[i] = coordSrc[indexes[i]]
	end
	return vars
end

function tensor.varsub(expr, vars)
	for k,v in pairs(vars) do
		expr = expr:gsub('$'..k, tostring(v))
	end
	return expr
end

function tensor.exec(expr, vars)
	if vars then expr = tensor.varsub(expr, vars) end
	local errmsg
	xpcall(function()
		assert(loadstring(expr))()
	end, function(err)
		errmsg = err .. '\n' .. debug.traceback()
	end)
	if errmsg then
		print("error on this command: "..tostring(expr))
		print(errmsg)
	end
end

function tensor.rank(names)
	return coroutine.wrap(function()
		if #names == 0 then 
			coroutine.yield({})
			return
		end
		local is = table()
		for i=1,#names do is[i] = 1 end
		local done
		repeat
			coroutine.yield(tensor.lookupVarsForIndexes(names, is))
			for i=1,#names do
				is[i] = is[i] + 1
				if is[i] <= #assert(tensor.lookupCoordSrc(names[i])) then
					break
				end
				is[i] = 1
				if i == #names then
					done = true
				end
			end
		until done
	end)
end

function tensor.printNonZero(expr, vars)
	expr = tensor.varsub(expr, vars)
	local exprstr = tostring(expr)
	tensor.exec("if "..exprstr.." ~= symmath.Constant(0) then print('\\\\("..exprstr.." = '..tostring("..exprstr..")..'\\\\)<br>') end")
end

-- get a list of var names
function tensor.getExprVarNames(expr)
	local varset = table()
	for var in expr:gmatch('%$%w+') do
		varset[var:sub(2)] = true
	end
	local vars = table()
	for k,_ in pairs(varset) do
		vars:insert(k)
	end
	return vars
end

-- get a mapping from var names to variables
function tensor.getReplVars(varNames, vars)
	local replvars = {}
	for i=1,#varNames do
		replvars[varNames[i]] = vars[i]
	end
	return replvars
end

-- bug: separate terms should be summed separately, but this sums the whole thing
--  this appears when a sum term is used
-- 	i.e. assign'1 + x_$u * x_$u' evaluates to 4 + assign'x_$u * x_$u'
function tensor.assign(expr)
	
	local eq = expr:find('=')
	if not eq then error("assign expected an equal operator") end
	local lhs = expr:sub(1,eq-1):trim()
	local rhs = expr:sub(eq+1):trim()

	local varNames = tensor.getExprVarNames(expr)
	local lhsVarNames = tensor.getExprVarNames(lhs)
	local sumVarNames = varNames:filter(function(varName) return not lhsVarNames:find(varName) end)
	
	for lhsVars in tensor.rank(lhsVarNames) do
		local sumexprs = table()
		for sumVars in tensor.rank(sumVarNames) do
			local replvars = tensor.getReplVars(table(lhsVarNames):append(sumVarNames), table(lhsVars):append(sumVars))
			sumexprs:insert(tensor.varsub(rhs, replvars))
		end
		
		local replvars = tensor.getReplVars(lhsVarNames, lhsVars)
		tensor.exec(tensor.varsub(lhs,replvars)..' = symmath.simplify('..sumexprs:concat(' + ')..')')
		tensor.printNonZero(lhs, replvars)
	end
	print()
end

return tensor

