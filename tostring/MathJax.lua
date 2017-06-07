local class = require 'ext.class'
local table = require 'ext.table'
local string = require 'ext.string'
local LaTeX = require 'symmath.tostring.LaTeX'	-- returns a singleton object
local MathJax = class(LaTeX.class)

local Header = class()

Header.title = 'Symbolic Lua Output'

Header.cdnURL = 'https://cdn.rawgit.com/mathjax/MathJax/2.7.1/MathJax.js?config=TeX-MML-AM_CHTML'

local envURLs = os.getenv'SYMMATH_MATHJAX_URLS'
Header.urls = (envURLs and string.split(envURLs, ';') or table()):append{Header.cdnURL}

function Header:init(title)
	self.title = title
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
        <title>]=] .. self.title .. [=[</title>
		<script type="text/javascript">
function loadScript(args) {
	console.log("loading "+args.src);
	var el = document.createElement('script');
	document.body.append(el);
	el.onload = function() {
		console.log('loaded');
		if (args.done !== undefined) args.done();
	};
	el.onerror = function() {
		console.log("failed to load "+args.src);
		if (args.fail !== undefined) args.fail();
	};
	el.src = args.src; 
}
function init() {
	console.log('init...');
	var urls = [
]=] .. self.urls:map(function(url,i)
		return "\t\t'" .. url .. "'"
	end):concat',\n' .. [=[
	];
	var i = 0;
	var loadNext = function() {
		loadScript({
			src : urls[i],
			done : function() {
				console.log("success!");
				MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
			},
			fail : function() {
				++i;
				if (i >= urls.length) {
					console.log("looks like all our sources have failed!");
				} else {
					loadNext();
				}
			}
		});
	}
	loadNext();
}
		</script>
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
	
	local title = args.title
	if not title then 
		title = os.getenv'_'
		if title then title = title:match('^%./(.*)%.lua$') end
	end
	
	print(Header(title))
	env.printbr = MathJax.print
end

return inst
