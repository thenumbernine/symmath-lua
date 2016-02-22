require 'ext'
local LaTeX = require 'symmath.tostring.LaTeX'	-- returns a singleton object
local MathJax = class(LaTeX.class)

MathJax.header = [=[
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Symbolic Lua Output</title>
		<script type="text/javascript" async src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML"></script>
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

-- call this to setup mathjax
function MathJax.setup()
	local symmath = require 'symmath'
	symmath.tostring = MathJax
	print(MathJax.header)
	function printbr(...)
		print(...)
		print'<br>'
	end
end

return MathJax()	-- singleton
