#!/usr/bin/env lua
local force = ... == 'force'
require 'ext'
for f in path:dir() do
	f = f.path
	if f:sub(-4) == '.lua' then
		local target = 'output/'..f:sub(1,-5)..'.html'
		local fileattr = path(f):attr()
		local targetattr = path(target):attr()
		if fileattr and targetattr then
			print('comparing '..os.date(nil, targetattr.change)..' vs '..os.date(nil, fileattr.change))
		end
		if force or not targetattr or targetattr.change < fileattr.change then
			if not path'output':isdir() then path'output':mkdir() end
			assert(os.exec('"./'..f..'" > "'..target..'"'))
		else
			print(f..' is up-to-date.')
		end
	end
end
