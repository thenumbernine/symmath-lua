--[[
Euler angles
TODO 'Euler angles' should refer to the concatenation of all these
and each of this is an exponential map
So think of better names?
--]]
local table = require 'ext.table'
return table{
	function(theta)
		local Matrix = require 'symmath.Matrix'
		local sin = require 'symmath.sin'
		local cos = require 'symmath.cos'
		return Matrix(
			{1, 0, 0},
			{0, cos(theta), -sin(theta)},
			{0, sin(theta), cos(theta)})
	end,
	function(theta)
		local Matrix = require 'symmath.Matrix'
		local sin = require 'symmath.sin'
		local cos = require 'symmath.cos'
		return Matrix(
			{cos(theta), 0, sin(theta)},
			{0, 1, 0},
			{-sin(theta), 0, cos(theta)})
	end,
	function(theta)
		local Matrix = require 'symmath.Matrix'
		local sin = require 'symmath.sin'
		local cos = require 'symmath.cos'
		return Matrix(
			{cos(theta), -sin(theta), 0},
			{sin(theta), cos(theta), 0},
			{0, 0, 1})
	end,
}
