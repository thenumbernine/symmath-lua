#!/usr/bin/env luajit
require 'ext'
local function recurse(dir)
	for f in file[dir]() do
		local fn = dir..'/'..f
		if io.isdir(fn) then
			recurse(fn)
		elseif f:sub(-4) == '.lua' then
			os.execute('mkdir output/'..dir)
			os.execute(fn..' > output/'..fn:sub(1,-5)..'.html')
		end
	end
end
recurse'.'
