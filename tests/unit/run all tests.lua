#!/usr/bin/env lua
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

for f in path:dir() do
	f = f.path
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
		local fileattr = path(f):attr()
		local targetattr = path(target):attr()
		if fileattr and targetattr then
			print('comparing '..os.date(nil, targetattr.change)..' vs '..os.date(nil, fileattr.change))
		end
		if not targetattr or targetattr.change < fileattr.change or force then
			if not path'../output':isdir() then path'../output':mkdir() end
			if not path'../output/unit':isdir() then path'../output/unit':mkdir() end
			os.exec(lua..' "'..f..'" > "'..target..'"')
			io.stderr:write'\n'
		else
			print(f..' is up-to-date.')
		end
	end
end
