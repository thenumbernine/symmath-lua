require 'ext'
local LaTeX = require 'symmath.tostring.LaTeX'	-- returns a singleton object
local MathJax = class(LaTeX.class)

MathJax.header = [=[
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Symbolic Lua Output</title>
        <script type="text/javascript" src="/MathJax-2.4-latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
		<script type="text/x-mathjax-config">MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});</script>
	</head>
    <body>
]=]

MathJax.footer = [[
	</body>
</html>
]]

function MathJax:__call(...)
	return '\\(' .. MathJax.super.__call(self, ...) .. '\\)'
end

return MathJax()	-- singleton

