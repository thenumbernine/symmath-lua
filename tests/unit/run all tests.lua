#!/usr/bin/env lua
local force = ... == 'force'
local lfs = require 'lfs'
require 'ext'

-- vanilla lua on windows isn't processing escape codes for color changes etc, but luajit is.
-- linux works fine for both of course
local lua = 'luajit'

local function exec(cmd)
	print('>'..cmd)
	return os.execute(cmd)
end

for f in os.listdir'.' do
	if f:sub(-4) == '.lua'
	and f ~= 'run all tests.lua'
	and f ~= 'unit.lua'
	-- not a part of the unit tests:
	and f ~= 'determinant_performance.lua'
	then
		local target = '../output/unit/'..f:sub(1,-5)..'.html'
		local fileattr = lfs.attributes(f)
		local targetattr = lfs.attributes(target)
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
