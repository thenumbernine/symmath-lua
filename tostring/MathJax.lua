require 'ext'
local LaTeX = require 'symmath.tostring.LaTeX'	-- returns a singleton object
local MathJax = class(LaTeX.class)

MathJax.header = [[
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>MHD Symmetrization</title>
        <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
    </head>
    <body>
]]

MathJax.footer = [[
	</body>
</html>
]]

function MathJax:__call(...)
	return '\\(' .. MathJax.super.__call(self, ...) .. '\\)'
end

return MathJax()

