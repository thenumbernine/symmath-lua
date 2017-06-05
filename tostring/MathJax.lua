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
--[==[ old header
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
--]==]
-- [==[ new header, which tries multiple sources
	-- no promises the javascript loading callbacks work on all browsers
	return [=[
<!doctype html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Metric Catalogue</title>
		<script type="text/x-mathjax-config">MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});</script>
		<script type="text/javascript">
function loadScript(url) {
	console.log("loading "+url);
	var done = undefined;
	var fail = undefined;
	var result = {
		done : function(f) { done = f; return result; },
		fail : function(f) { fail = f; return result; }
	};
	var el = document.createElement('script');
	document.body.append(el);
	el.onload = function() {
		console.log('loaded');
		if (done !== undefined) done();
	};
	el.onerror = function() {
		console.log("failed to load "+url);
		if (fail !== undefined) {
			fail();
		}
	};
	el.src = url; 
	return result;
}
function init() {
	console.log('init...');
	var urls = [
		'file:///home/chris/Projects/christopheremoore.net/MathJax/MathJax.js?config=TeX-MML-AM_CHTML',
		'/MathJax/MathJax.js?config=TeX-MML-AM_CHTML',
		'https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML'
	];
	var i = 0;
	var loadNext = function() {
		loadScript(urls[i])
		.done(function() {
			console.log("success!");
		}).fail(function() {
			++i;
			if (i >= urls.length) {
				console.log("looks like all our sources have failed!");
			} else {
				loadNext();
			}
		});
	}
	loadNext();
}
		</script>
		<script type="text/x-mathjax-config">MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});</script>
	</head>
    <body onload='init();'>
]=]
--]==]
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
