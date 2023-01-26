local table = require 'ext.table'
local range = require 'ext.range'
local add = require 'symmath.op.add'
local Constant = require 'symmath.Constant'
local simplify = require 'symmath.simplify'
local Array = require 'symmath.Array'

local function isZero(x)
	return Constant:isa(x) and x.value == 0
end

--[[
args:
	m = matrix

	args:
		callback = optional callback, every second, with the percent of progress
		TODO maxDepth = how deep to compute
		... but to allow for maxDepth to leave determinants unevaluated, I need support for unevaluated functions
			right now all I have is Lua functions, which themselves immediately evaluate.  nothing is deferred.
		dontSimplify = don't simplify results before returning

	args internally used:
		lastTime = table holding the last time that the callback was called
--]]
local function determinant(m, args)
	local callback = args and args.callback
	local lastTime = args and args.lastTime or {t=os.time()}
	local dontSimplify = args and args.dontSimplify
	--local depth = args and args.depth or 1

	-- require the caller to simplify beforehand

	-- non-array?  return itself
	if not Array:isa(m) then return m end
	local dim = m:dim()
	if #dim == 0 then return Constant(1) end

	local volume = #dim == 0 and 0 or 1
	for i=1,#dim do
		volume = volume * dim[i]
	end

	-- 0x0 array?  return itself
	if volume == 0 then return Constant(1) end

	-- tempted to write a volume=1 rank=n return the n-th nested element condition ...

	-- not a rank-2 array? return nothing.  maybe error.
	if #dim ~= 2 then
		--print('m',require 'ext.tolua'(m))
		error("dim is "..#dim..' with value '..m[1][1])
	end

	-- not square?
	if dim[1] ~= dim[2] then
		error("determinant only works on square matrices")
	end

	local n = dim[1]

	-- 1x1 matrix?
	if n == 1 then
		return m[1][1]
	elseif n == 2 then
		local results = m[1][1] * m[2][2] - m[1][2] * m[2][1]
		if not dontSimplify then
			results = results:simplify()
		end
		return results
	end

	-- pick row (or column) with most zeroes
	local mostZerosOfRow = -1
	local mostZerosOfCol = -1
	local rowWithMostZeros
	local colWithMostZeros
	for i=1,n do
		local sumRow = 0
		local sumCol = 0
		for j=1,n do
			if isZero(m[i][j]) then sumRow = sumRow + 1 end
			if isZero(m[j][i]) then sumCol = sumCol + 1 end
		end
		if sumRow > mostZerosOfRow then
			mostZerosOfRow = sumRow
			rowWithMostZeros = i
		end
		if sumCol > mostZerosOfCol then
			mostZerosOfCol = sumCol
			colWithMostZeros = i
		end
	end

	local useCol = mostZerosOfCol > mostZerosOfRow
	local x = useCol and colWithMostZeros or rowWithMostZeros

	local results = Constant(0)
	for y=1,n do
		local i,j
		if useCol then i,j = y,x else i,j = x,y end
		local mij = m[i][j]
		-- if the # of flips is odd then scale by -1, if even then by +1
		local sign = ((i+j)%2)==0 and 1 or -1
		if not isZero(mij) then
			local submat = Array()
			for u=1,n-1 do
				local submat_u = Array()
				submat[u] = submat_u
				for v=1,n-1 do
					local p,q = u,v
					if p>=i then p=p+1 end
					if q>=j then q=q+1 end
					submat_u[v] = m[p][q]
				end
			end
			local subcallback = callback and function(...) return callback(y, ...) end or nil
			local subres = determinant(submat, args and table(args, {callback=subcallback, lastTime=lastTime}) or nil)
			results = results + sign * mij * subres
			if not dontSimplify then
				results = results()
			end
		end
		if callback then
			local thisTime = os.time()
			if thisTime ~= lastTime[1] then
				lastTime[1] = thisTime
				callback(y)
			end
		end
	end
	return results
end

return determinant
