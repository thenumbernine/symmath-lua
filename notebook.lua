--[[

    File: notebook.lua

    Copyright (C) 2000-2014 Christopher Moore (christopher.e.moore@gmail.com)
	  
    This software is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
  
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
  
    You should have received a copy of the GNU General Public License along
    with this program; if not, write the Free Software Foundation, Inc., 51
    Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--]]

-- notebook expects symmath to be assigned in global scope
symmath = require 'symmath'

function asserteq(a,b)
	if a ~= b then
		error("\nexpected "..tostring(a).." to equal "..tostring(b))
	end
end

function notebook(cmd)
	for _,line in ipairs(cmd:split('\n')) do
		line = line:trim()
		if #line > 0 then
			print('> '..line)
			if line:sub(1,1) == '=' then
				line = 'return '..line:sub(2)
			end
			local startTime = os.time()	-- TODO hires timer
			local ok, err = assert(loadstring(line))
			if not ok then
				print(err)
			else
				local func = ok
				local errmsg
				local result = {xpcall(func, function(err)
					errmsg = err .. '\n' .. debug.traceback()
				end)}	-- scope? all global, right? unless 'local' is added on...
				local duration = os.time() - startTime
				if errmsg then
					io.write(errmsg)
				else
					if #result > 0 then
						io.write(table.concat(table.map(result, tostring),'\t')..'\t')
					end
				end
				print('('..duration..' seconds)')
			end
		else
			print()
		end
	end
end
