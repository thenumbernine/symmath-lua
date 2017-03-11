local class = require 'ext.class'
local LaTeX = require 'symmath.tostring.LaTeX'	-- returns a singleton object
local MathJax = class(LaTeX.class)

--cdn
--local url = 'https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML'
-- local filesystem
local url = '/MathJax/MathJax.js?config=TeX-MML-AM_CHTML'

MathJax.header = [=[
<!DOCTYPE html>
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

-- call this to setup mathjax
function MathJax.setup()
	local symmath = require 'symmath'
	symmath.tostring = MathJax
	print(MathJax.header)
	printbr = MathJax.print
end

return MathJax()	-- singleton
