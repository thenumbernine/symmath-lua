local class = require 'ext.class'
local table = require 'ext.table'
local string = require 'ext.string'
local LaTeX = require 'symmath.export.LaTeX'	-- returns a singleton object

local symmath


local MathJax = LaTeX.class:subclass()

MathJax.name = 'MathJax'
MathJax.colsep = '&amp;'	-- & but for html

local Header = class()

Header.title = 'Symbolic Lua Output'

Header.cdnURL = 'https://cdn.rawgit.com/mathjax/MathJax/2.7.1/MathJax.js?config=TeX-MML-AM_CHTML'

local envURLs = os.getenv'SYMMATH_MATHJAX_URLS'
Header.urls = (envURLs and string.split(envURLs, ';') or table()):append{Header.cdnURL}

Header.pathToTryToFindMathJax = '.'

function Header:init(title)
	self.title = title
	-- read from global if it exists?
	self.pathToTryToFindMathJax = pathToTryToFindMathJax
end
function Header:__tostring()
--[==[ old header
	return [=[
<!doctype html>
<html>
	<head>
		<meta charset='utf-8'>
		<title>]=] .. self.title .. [=[</title>
		<script type="text/javascript" async src="]=]..self.url..[=["></script>
		<script type="text/x-mathjax-config">MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});</script>
	</head>
	<body>
]=]
--]==]
--[==[ new header, which tries multiple sources, and works great (except doesn't work with htmlpreview)
	-- no promises the javascript loading callbacks work on all browsers
	return [=[
<!doctype html>
<html>
	<head>
		<meta charset='utf-8'>
		<title>]=] .. self.title .. [=[</title>
		<script type='text/javascript'>
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
	end):concat',' .. [=[
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
-- [==[ next iteration -- in one tryToFindMathJax.js file -- which ignores the URLs here
	return [=[
<!doctype html>
<html>
	<head>
		<meta charset='utf-8'>
		<title>]=] .. self.title .. [=[</title>
		<script type='text/javascript' src=']=] .. self.pathToTryToFindMathJax .. [=[/tryToFindMathJax.js'></script>
		<link rel='stylesheet' href=']=] .. self.pathToTryToFindMathJax .. [=[/darkmode.css'></link>
		<script type='text/javascript' src=']=] .. self.pathToTryToFindMathJax .. [=[/darkmode.js'></script>
	</head>
	<body>
]=]
--]==]
end
Header.__concat = string.concat

-- Header class
MathJax.Header = Header
-- default instance
MathJax.header = Header()

MathJax.footer = [[
	</body>
</html>
]]


function MathJax.print(...)
	print(...)
	print'<br>'
	io.stdout:flush()
	return ...		-- why isn't this a thing with Lua print()?
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
		and k ~= 'pathToTryToFindMathJax'
		then
			inst[k] = v
		end
	end
	symmath = symmath or require 'symmath.namespace'()
	symmath.tostring = inst

	local title = args.title
	if not title then
		title = os.getenv'_'
		if title then title = title:match('^%./(.*)%.lua$') end
	end
	if type(inst.header) ~= 'string' then
		inst.header.title = title
		inst.header.pathToTryToFindMathJax = args.pathToTryToFindMathJax
	end

	print(inst.header)
	env.printbr = MathJax.print
end

return inst
