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

local table = require 'ext.table'

local symmath = {}
symmath.verbose = false
symmath.simplifyConstantPowers = false	-- whether 1/3 stays or becomes .33333...

symmath.clone = require 'symmath.clone'	-- also casts numbers to Constant

symmath.replace = require 'symmath.replace'
symmath.solve = require 'symmath.solve'
symmath.map = require 'symmath.map'

symmath.prune = require 'symmath.prune'
symmath.distributeDivision = require 'symmath.distributeDivision'
symmath.factorDivision = require 'symmath.factorDivision'
symmath.expand = require 'symmath.expand'
symmath.factor = require 'symmath.factor'
symmath.factorLinearSystem = require 'symmath.factorLinearSystem'
symmath.tidy = require 'symmath.tidy'
symmath.simplify = require 'symmath.simplify'
symmath.polyCoeffs = require 'symmath.polyCoeffs'

-- replace variables with names as keys in evalmap with constants of the associated values
symmath.eval = require 'symmath.eval'

local Variable = require 'symmath.Variable'
symmath.Variable = Variable
symmath.var = Variable					--shorthand
function symmath.vars(...)						--create variables for each string parameter 
	return table{...}:map(function(x) return symmath.var(x) end):unpack()
end

--[[
builds a function out of the expression
exprs - specifies the table of expressions that will be associated with function input parameters
	- can either be a list of expressions -- in which case the text of the expression will be used (i.e. the name of the Variable) 
	- or can be a table with a key/value pair, mapping the expression (the key) to the string to be used in the function (the value)
	- ex: 
		x=symmath.var'x' 
		(x^2):compile{x} 
		... produces "function(x) return x^2 end"
		
		x=symmath.var'x' 
		(x^2):copmile{x='y'} 
		... produces "function(y) return y^2 end"
		
		x,t=symmath.vars('x','t') 
		x:depends(t) 
		symmath.exp(-x^2):diff(t):simplify():compile{x,{[x:diff(t)]='dx_dt']}}
		... produces "function(x, dx_dt) return -2 * x * dx_dt * math.exp(-x^2) end"

language - specifies the target language.  options are 'Lua' (default) and 'JavaScript'

if there are any Derivatives or variables (other those listed) then compiling will produce an error
so if you have any derivs you want as function parameters, use map() or replace() to replace them for new variables
	and then put them in the vars list
--]]
function symmath.compile(expr, vars, language)
	language = language or 'Lua'
	return require('symmath.tostring.'..language):compile(expr, vars)
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
	parent[index] = rule(parent[index])
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
symmath.complex = require 'symmath.complex'
symmath.Invalid = require 'symmath.Invalid'
symmath.Function = require 'symmath.Function'

symmath.sqrt = require 'symmath.sqrt'
symmath.log = require 'symmath.log'
symmath.abs = require 'symmath.abs'
symmath.exp = require 'symmath.exp'
symmath.sin = require 'symmath.sin'
symmath.cos = require 'symmath.cos'
symmath.tan = require 'symmath.tan'
symmath.asin = require 'symmath.asin'
symmath.acos = require 'symmath.acos'
symmath.atan = require 'symmath.atan'
symmath.atan2 = require 'symmath.atan2'
symmath.cosh = require 'symmath.cosh'
symmath.sinh = require 'symmath.sinh'
symmath.tanh = require 'symmath.tanh'
symmath.Heaviside = require 'symmath.Heaviside'

symmath.op = {
	Binary = require 'symmath.op.Binary',
	unm = require 'symmath.op.unm',
	add = require 'symmath.op.add',
	sub = require 'symmath.op.sub',
	mul = require 'symmath.op.mul',
	div = require 'symmath.op.div',
	pow = require 'symmath.op.pow',
	mod = require 'symmath.op.mod',

	Equation = require 'symmath.op.Equation',
	eq = require 'symmath.op.eq',
	ne = require 'symmath.op.ne',
	lt = require 'symmath.op.lt',
	le = require 'symmath.op.le',
	gt = require 'symmath.op.gt',
	ge = require 'symmath.op.ge',
}
-- shorthand
symmath.frac = symmath.op.div

--symmath.Variable = require 'symmath.Variable'
symmath.Derivative = require 'symmath.Derivative'
symmath.diff = symmath.Derivative	-- shorthand

-- thinking of lowercasing all of these ...
symmath.Sum = require 'symmath.Sum'
-- symmath.Product
symmath.Integral = require 'symmath.Integral'

-- specific to Matrix
symmath.Vector = require 'symmath.Vector'
symmath.Matrix = require 'symmath.Matrix'
symmath.Array = require 'symmath.Array'
symmath.Tensor = require 'symmath.Tensor'

-- change the default as you see fit
symmath.tostring = assert(require 'symmath.tostring.MultiLine')
symmath.Verbose = assert(require 'symmath.tostring.Verbose')

-- constants 
symmath.e = Variable('e', nil, math.exp(1))
symmath.pi = Variable('\\pi', nil, math.pi)
symmath.inf = Variable('\\infty', nil, math.huge)

-- hack implicit variable names to look good in TeX

local texSymbols = {}
for k in ([[
alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu
nu xi omicron pi rho sigma tau upsilon phi chi psi omega
hBar
]]):gmatch'%S+' do
	table.insert(texSymbols, k)
	k = k:sub(1,1):upper() .. k:sub(2)
	table.insert(texSymbols, k)
end
-- sort these largest to smallest so replacements work
table.sort(texSymbols, function(a,b) return #a > #b end)

symmath.setup = function(args)
	args = args or {}
	local env = args.env or _G	
	
	--[[ just copy
	for k,v in pairs(symmath) do
		if k ~= 'tostring' then
			env[k] = v
		end
	end
	--]]
	-- [[ override environment
	for k,v in pairs(args) do
		-- hmm, some args are for symmath, some are for setup ...
		if k ~= 'env' then
			symmath[k] = v
		end
	end
	assert(not getmetatable(env), "ut oh")
	env.symmath = symmath
	setmetatable(env, {
		__index = function(t,k)
			-- first check symmath (except tostring, for circular reference reasons)
			local x
			if k ~= 'tostring' then
				x = symmath[k]
				if x ~= nil then return x end
			end
			x = rawget(env,k)
			if x ~= nil then return x end
			
			-- extra ugly hack - create vars by request?
			-- maybe only with certain variable names?
			if symmath.implicitVars then
				local i=1
				while i < #k do
					if i>1 and k:sub(i):match('^[%^_]') then
						k = k:sub(1,i-1) .. '_{' .. k:sub(i+1) .. '}'
					end
					for _,w in ipairs(texSymbols) do
						if k:sub(i):match('^'..w) then
							k = k:sub(1,i-1) .. '\\' .. k:sub(i)
							i = i + #w
						end
					end
					i=i+1
				end
				return symmath.var(k)
			end

			return nil
		end
	})
	--]]
end

return symmath
