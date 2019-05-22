#!/usr/bin/env lua
require 'ext'
local url = require 'socket.url'

--local base = [[https://cdn.rawgit.com/thenumbernine/symmath-lua/master/]]
--local base = [[https://htmlpreview.github.io/?https://github.com/thenumbernine/symmath-lua/blob/master/]]
local base = [[https://thenumbernine.github.io/symmath/]]

local s = table{[[
Output CDN URLs:
]]}

local fs = io.rdir('.', function(fn, isdir)
	return fn ~= '.git' and (isdir or fn:sub(-5) == '.html')
end):mapi(function(f)
	assert(f:sub(1,2) == './')
	return f:sub(3)
end):sort():mapi(function(f)
	local name = f:sub(1,-6)
	s:insert('['..name..']('..base..
		url.escape(f)
			:gsub('%%2f','/')
			:gsub('%%2e','.')
		..')\n')
end)

file['README.md'] = file['README.contents.md']..'\n'..s:concat'\n'
