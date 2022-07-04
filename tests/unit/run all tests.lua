#!/usr/bin/env lua
local haslfs, lfs = pcall(require, 'lfs')
if not haslfs then lfs = nil end
require 'ext'
local force = cmdline.force

-- vanilla lua on windows isn't processing escape codes for color changes etc, but luajit is.
-- linux works fine for both of course
local lua = 'luajit'

--[[
ex: to run all tests with the 'useHasBeenFlags' disabled:  ./run\ all\ tests.lua force "-e=require'symmath'.useHasBeenFlags=false"
--]]
local dashE = cmdline['-e']
if dashE then
	lua = lua..' -e "'..dashE..'"'
end

local function exec(cmd)
	print('>'..cmd)
	return os.execute(cmd)
end

for f in os.listdir'.' do
	if f:sub(-4) == '.lua'
	and f ~= 'run all tests.lua'
	and f ~= 'unit.lua'
	-- the following aren't unit test suites
	-- usually they have no asserts at all
	-- (except plot or export which have no asserts but still serve a purpose for output of examples)
	-- maybe some I should redo these into test suits 
	and f ~= 'determinant_performance.lua'
	and f ~= 'linear solver.lua'
	and f ~= 'sub-tensor assignment.lua'
	and f ~= 'tensor use case.lua'
	then
		local target = '../output/unit/'..f:sub(1,-5)..'.html'
		local fileattr, targetattr
		if lfs then
			fileattr = lfs.attributes(f)
			targetattr = lfs.attributes(target)
		end
		if fileattr and targetattr then
			print('comparing '..os.date(nil, targetattr.change)..' vs '..os.date(nil, fileattr.change))
		end
		if not targetattr or targetattr.change < fileattr.change or force then
			if not os.isdir'../output' then exec'mkdir "../output"' end
			if not os.isdir'../output/unit' then exec'mkdir "../output/unit"' end
			exec(lua..' "'..f..'" > "'..target..'"')
			io.stderr:write'\n'
		else
			print(f..' is up-to-date.')
		end
	end
end
