local class = require 'ext.class'
local LaTeX = require 'symmath.tostring.LaTeX'	-- returns a singleton object
local MathJax = class(LaTeX.class)

--cdn
--local url = 'https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML'
-- local filesystem
local url = '/MathJax/MathJax.js?config=TeX-MML-AM_CHTML'

MathJax.header = [=[
<!doctype html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Symbolic Lua Output</title>
		<script type="text/javascript" async src="]=]..url..[=["></script>
		<script type="text/x-mathjax-config">MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});</script>
	</head>
    <body>
]=]

MathJax.footer = [[
	</body>
</html>
]]

function MathJax:__call(...)
	return '$' .. MathJax.super.__call(self, ...) .. '$'
end

function MathJax.print(...)
	print(...)
	print'<br>'
	io.stdout:flush()
end

local inst = MathJax()

-- call this to setup mathjax
function MathJax.setup(args)
	args = args or {}
	local env = args.env or _G
	for k,v in pairs(args) do
		if k ~= 'env' then
			inst[k] = v
		end
	end
	local symmath = require 'symmath'
	symmath.tostring = inst
	print(MathJax.header)
	env.printbr = MathJax.print
end

return inst
