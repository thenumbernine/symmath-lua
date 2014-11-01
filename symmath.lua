--[[

    File: symmath.lua 

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

require 'ext'

local symmath = {}
symmath.verbose = false
symmath.simplifyConstantPowers = false	-- whether 1/3 stays or becomes .33333...
symmath.usePowerSymbol = true			-- whether to use a^b or pow(a,b).  This is a dirty trick to get around some dirtier regex converting compiled functions from one language to another.  A more proper fix would be to allow different backends to compile to.

symmath.replace = require 'symmath.replace'
symmath.solve = require 'symmath.solve'
symmath.map = require 'symmath.map'

symmath.prune = require 'symmath.prune'
symmath.expand = require 'symmath.expand'
symmath.factor = require 'symmath.factor'
symmath.tidy = require 'symmath.tidy'
symmath.simplify = require 'symmath.simplify'

symmath.Variable = require 'symmath.Variable'
--[[
replace variables with names as keys in evalmap with constants of the associated values
--]]
function symmath.evaluate(expr, evalmap)
	if evalmap then
		expr = symmath.map(expr, function(node)
			if node == nil then
				error("found a nil node in expression "..tostring(expr))
			end
			if not node:isa(symmath.Variable) then return end
			local newval = evalmap[node.name]
			if newval == nil then return end
			if type(newval) ~= 'number' then
				error("expected the values of the evaluation map to be numbers, but found "..node.name.." = ("..type(newval)..").."..tostring(newval))
			end
			return symmath.Constant(newval)
		end)
	end
	expr = symmath.simplify(expr)
	return expr:eval()
end

--[[
builds a lua function out of the expression
vars - specifies the list of variables that will associate with function input parameters
if there are any Derivatives or variables (other those listed) then compiling will produce an error
so if you have any derivs you want as function parameters, use map() or replace() to replace them for new variables
	and then put them in the vars list
--]]
function symmath.compile(expr, vars)
	return symmath.ToLuaCode:compile(expr, vars)
end

--[[ potential new system based on breadth-first search ... not finished yet

local rules = {
	function(expr)
		
	end,
}


function applyRuleAtNode(expr, node, rule)
	expr = expr:clone()
	
	-- find 'node' in 'expr'
	-- replace it with 'prune(node)'
	if node == expr then
		return rule:apply(expr)
	end

	local parent, index = expr:findChild(node)
	parent.xs[index] = rule(parent.xs[index])
	return expr
end

function applyRulesAtNode(expr, node)
	for _,rule in ipairs(rules) do
		applyRuleAtNode(expr, node, rule)
	end
end

function simplify(firstExpr)
	local allExprs = table{firstExpr:clone()}
	local currentExprs = table{firstExpr:clone()}
	local tries = 0
	while #currentExprs > 0 do
		local expr = currentExprs:remove(1)
		local nodes = expr:getAllNodes()
		for i=1,#nodes do
			local newExprs = applyRulesAtNode(expr, nodes[i])
			for _,newExpr in ipairs(newExprs) do
				if not allExprs:find(newExpr) then
					allExprs:insert(newExpr)
					currentExprs:insert(newExpr)
				end
			end
		end
		tries = tries + 1
		if tries > 10 then break end
	end
	local smallestNodes
	local smallestExpr
	for _,expr in ipairs(currentExpr) do
		local numNodes = #expr:getAllNodes()
		if not smallestNodes or numNodes < smallestNodes then
			smallestNodes = numNodes
			smallestExpr = expr
		end
	end
	return smallestExpr
end

--]]

symmath.tableCommutativeEqual = require 'symmath.tableCommutativeEqual'
symmath.nodeCommutativeEqual = require 'symmath.nodeCommutativeEqual'

symmath.Expression = require 'symmath.Expression'
symmath.Constant = require 'symmath.Constant'
symmath.Invalid = require 'symmath.Invalid'
symmath.Function = require 'symmath.Function'

symmath.sqrt = require 'symmath.sqrt'
symmath.log = require 'symmath.log'
symmath.exp = require 'symmath.exp'
symmath.sin = require 'symmath.sin'
symmath.cos = require 'symmath.cos'
symmath.tan = require 'symmath.tan'
symmath.asin = require 'symmath.asin'
symmath.acos = require 'symmath.acos'
symmath.atan = require 'symmath.atan'
symmath.atan2 = require 'symmath.atan2'

symmath.unmOp = require 'symmath.unmOp'
symmath.BinaryOp = require 'symmath.BinaryOp'
symmath.addOp = require 'symmath.addOp'
symmath.subOp = require 'symmath.subOp'
symmath.mulOp = require 'symmath.mulOp'
symmath.divOp = require 'symmath.divOp'
symmath.powOp = require 'symmath.powOp'
symmath.modOp = require 'symmath.modOp'

--symmath.Variable = require 'symmath.Variable'
symmath.Derivative = require 'symmath.Derivative'
symmath.diff = symmath.Derivative	-- shorthand

symmath.EquationOp = require 'symmath.EquationOp'
symmath.equals = require 'symmath.equals'
symmath.lessThan = require 'symmath.lessThan'
symmath.lessThanOrEquals = require 'symmath.lessThanOrEquals'
symmath.greaterThan = require 'symmath.greaterThan'
symmath.greaterThanOrEquals = require 'symmath.greaterThanOrEquals'

-- change the default as you see fit
symmath.toStringMethod = assert(require 'symmath.tostring.MultiLine')
symmath.Verbose = assert(require 'symmath.tostring.Verbose')

return symmath

