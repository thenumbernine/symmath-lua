#!/usr/bin/env lua
require 'ext'
local function exec(cmd)
	print('>'..cmd)
	return os.execute(cmd)
end
for f in path:dir() do
	if f:sub(-4) == '.lua' then
		local target = 'output/'..f:sub(1,-5)..'.html'
		local fileattr = path(f):attr()
		local targetattr = path(target):attr()
		if fileattr and targetattr then
			print('comparing '..os.date(nil, targetattr.change)..' vs '..os.date(nil, fileattr.change))
		end
		if not targetattr or targetattr.change < fileattr.change then
			if not path'output':isdir() then path'output':mkdir() end
			exec('"./'..f..'" > "'..target..'"')
		else
			print(f..' is up-to-date.')
		end
	end
end
