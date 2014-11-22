require 'ext'
-- single-line strings 
local ToString = require 'symmath.tostring.ToString'
local SingleLine = class(ToString)

SingleLine.lookupTable = {
	--[[
	[require 'symmath.Expression'] = function(self, expr)
		local s = table{}
		for k,v in pairs(expr) do s:insert(rawtostring(k)..'='..rawtostring(v)) end
		return 'Expression{'..s:concat(', ')..'}'
	end,
	--]]
	[require 'symmath.Constant'] = function(self, expr) 
		return tostring(expr.value) 
	end,
	[require 'symmath.Invalid'] = function(self, expr)
		return 'Invalid'
	end,
	[require 'symmath.Function'] = function(self, expr)
		return expr.name..'(' .. expr.xs:map(function(x) return self:apply(x) end):concat(', ') .. ')'
	end,
	[require 'symmath.unmOp'] = function(self, expr)
		return '-'..self:wrapStrOfChildWithParenthesis(expr, 1)
	end,
	[require 'symmath.BinaryOp'] = function(self, expr)
		return expr.xs:map(function(x,i)
			return self:wrapStrOfChildWithParenthesis(expr, i)
		end):concat(expr:getSepStr())
	end,
	[require 'symmath.Variable'] = function(self, expr)
		local s = expr.name
		if expr.value then
			s = s .. '|' .. expr.value
		end
		return s
	end,
	[require 'symmath.Derivative'] = function(self, expr) 
		local topText = 'd'
		local diffVars = expr.xs:sub(2)
		local diffPower = #diffVars
		if diffPower > 1 then
			topText = topText .. '^'..diffPower
		end	
		local powersForDeriv = {}
		for _,var in ipairs(diffVars) do
			powersForDeriv[var.name] = (powersForDeriv[var.name] or 0) + 1
		end
		local diffexpr = self:apply(assert(expr.xs[1]))
		return topText..'/{'..table.map(powersForDeriv, function(power, name, newtable)
			local s = 'd'..name
			if power > 1 then
				s = s .. '^' .. power
			end
			return s, #newtable+1
		end):concat(' ')..'}['..diffexpr..']'
	end
}

return SingleLine()		-- singleton

