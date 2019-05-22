#!/usr/bin/env lua
local lfs = require 'lfs'
require 'ext'
io.rdir('.', function(fn, isdir)
	return isdir or fn:sub(-4) == '.lua'
end):map(function(f)
	local target = 'output/'..f:sub(1,-5)..'.html'
	if not io.fileexists(target) 
	or lfs.attributes(target).change < lfs.attributes(f).change 
	then
		os.execute('mkdir output/'..dir)
		os.execute('"'..f..'" > "'..target..'"')
	else
		print(f..' is up-to-date.')
	end
end)
