local class = require 'ext.class'
local LaTeX = require 'symmath.tostring.LaTeX'	-- returns a singleton object
local MathJax = class(LaTeX.class)

local Header = class()

Header.title = 'Symbolic Lua Output'

Header.cdnURL = 'https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML'
Header.localURL = '/MathJax/MathJax.js?config=TeX-MML-AM_CHTML'
Header.url = Header.localURL

function Header:init(title, url)
	self.title = title
	self.url = url
end
function Header:__tostring()
	return [=[
<!doctype html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>]=] .. self.title .. [=[</title>
		<script type="text/javascript" async src="]=]..self.url..[=["></script>
		<script type="text/x-mathjax-config">MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});</script>
	</head>
    <body>
]=]
end
function Header.__concat(a,b)
	return tostring(a) .. tostring(b) 
end

-- Header class
MathJax.Header = Header
-- default instance
MathJax.header = Header()

MathJax.openSymbol = '$'
MathJax.closeSymbol = '$'

MathJax.footer = [[
	</body>
</html>
]]

function MathJax:__call(...)
	return self.openSymbol .. MathJax.super.__call(self, ...) .. self.closeSymbol
end

function MathJax.print(...)
	print(...)
	print'<br>'
	io.stdout:flush()
end

local inst = MathJax()

--[[
call this to setup mathjax
args:
	env = environment.  _G by default.
	title = page title.
	any other args are forwarded to the MathJax singleton
--]]
function MathJax.setup(args)
	args = args or {}
	local env = args.env or _G
	for k,v in pairs(args) do
		if k ~= 'env' 
		and k ~= 'title'
		then
			inst[k] = v
		end
	end
	local symmath = require 'symmath'
	symmath.tostring = inst
	print(Header(args.title, args.url))
	env.printbr = MathJax.print
end

return inst
