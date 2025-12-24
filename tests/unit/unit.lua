local table = require 'ext.table'
local path = require 'ext.path'
local string = require 'ext.string'
local fromlua = require 'ext.fromlua'
local tolua = require 'ext.tolua'

local checkstr = '✓'
local failstr = '✕'

local symmathPath = os.getenv'SYMMATH_PATH'		-- I have it set to HOME/Projects/lua/symmath
assert(symmathPath, "expected environment variable SYMMATH_PATH to be set")
local unitTestPath = symmathPath..'/tests/unit'
local unitTestCachePath = path(symmathPath)/'tests/unit-cache'
local unitTestOutputPath = path(symmathPath)/'tests/output/unit'
unitTestCachePath:mkdir(true)
unitTestOutputPath:mkdir(true)

-- TODO maybe I should do a html library, and maybe it should be connected to the htmlparser library, and maybe I should rename that to just 'html' ...
local function htmlescape(str)
	return str
		:gsub('&', '&amp;')
		:gsub('<', '&lt;')
		:gsub('>', '&gt;')
		:gsub('"', '&quot;')
		:gsub("'", '&#39;')
end

local function updateMaster()
	local allTestResults = {}
	for fn in unitTestCachePath:dir() do
		local title, ext = fn:getext()
		if ext == 'lua' then
			allTestResults[title.path] = fromlua((unitTestCachePath/fn):read())
		end
	end
	(unitTestOutputPath/'index.html'):write([[
<!doctype html>
<html>
	<head>
		<meta charset='utf8'/>
		<title>test/unit master</title>
		<link rel='stylesheet' href='../darkmode.css'></link>
		<script type='text/javascript' src='../darkmode.js'></script>
		<style>
.title {
	width:auto;
	text-align:right;
	white-space:nowrap;
}
.content {
	width:100%;
	overflow-wrap:anywhere;
}
table {
	border-collapse:collapse;
	border-spacing:0;
	width:100%;
}
td, th {
	border: 1px solid var(--font-color);
	padding-left: 2px;
	padding-right: 2px;
}
		</style>
	</head>
	<body>
		<table>
]]
..table.keys(allTestResults):sort():mapi(function(title)
	local rows = allTestResults[title]
	title = title:match'^tests_unit_(.*)$' or title
	local numTotal = table.mapi(rows, function(row)
		return (row.error or (row.code and #string.trim(row.code) > 0)) and 1 or 0
	end):sum()
	local numFails = table.mapi(rows, function(row)
		return row.error and 1 or 0
	end):sum()
	return '<tr><td class="title">\n'
		.. '<a href="'..title..'.html">' .. title .. '</a>\n'
		.. '</td><td>' .. (numTotal == 0 and '' or numTotal)
		.. '</td><td>' .. (numFails == 0 and '' or numFails)
		.. '</td><td class="content">\n'
		.. 	table.mapi(rows, function(row)
				local rowdesctitle = htmlescape(row.code)
				if row.error then
					return '<span style="color:red" title="'..rowdesctitle..'">'..failstr..'</span>'
				elseif row.code and #string.trim(row.code) > 0 then
					return '<span style="color:green" title="'..rowdesctitle..'">'..checkstr..'</span>'
				elseif row.comment then
					return ''
				else
					return '?'
				end
			end):concat'\n'
		.. '</td></tr>\n'
end):concat()
..[[
		</table>
	</body>
</html>
]])
end

return function(env, title)
	require 'ext.env'(env)
	local string = env.string
	require 'symmath'.setup{env=env, MathJax={title=title, pathToTryToFindMathJax='..'}}
	local symmath = env.symmath
	symmath.simplify.debugLoops = 'rules'

	function env.assert(a)
		if not a then
			print('expected '..tostring(a)..' to be true<br>')
			error'failed'
		end
	end

	local function printStackEntry(x)
		printbr(x[1], x[2], '<pre>', symmath.Verbose(x[2]), '</pre>')
	end

	function env.simplifyAssertEq(a,b, showStackAnyways)
		printbr(symmath.op.eq(a,b))
		assert(a ~= nil, "simplifyAssertEq lhs is nil")
		assert(b ~= nil, "simplifyAssertEq rhs is nil")
		local sa = symmath.simplify(a)
		local ta = symmath.simplify.stack
		local sb = symmath.simplify(b)
		local tb = symmath.simplify.stack
		local fail = sa ~= sb
		if fail or showStackAnyways then
			print('expected '..tostring(a)..' to equal '..tostring(b)..'<br>')
			print('found '..tostring(sa)..' vs '..tostring(sb)..'<br>')
			print('lhs stack<br>')
			for _,x in ipairs(ta) do printStackEntry(x) end
			print('rhs stack<br>')
			for _,x in ipairs(tb) do printStackEntry(x) end
			if fail then error'failed' end
		end
	end

	function env.simplifyLHSAssertEq(a, b, showStackAnyways)
		printbr(symmath.op.eq(a,b))
		assert(a ~= nil, "simplifyLHSAssertEq lhs is nil")
		assert(b ~= nil, "simplifyLHSAssertEq rhs is nil")
		local sa = symmath.simplify(a)
		local ta = symmath.simplify.stack
		local fail = sa ~= b
		if fail or showStackAnyways then
			print('expected '..tostring(a)..' to equal '..tostring(b)..'<br>')
			print('found '..tostring(sa)..' vs '..tostring(b)..'<br>')
			print('lhs stack<br>')
			for _,x in ipairs(ta) do printStackEntry(x) end
			if fail then error'failed' end
		end
	end

	function env.simplifyAssertNe(a,b, showStackAnyways)
		printbr(symmath.op.ne(a,b))
		local sa = symmath.simplify(a)
		local ta = symmath.simplify.stack
		local sb = symmath.simplify(b)
		local tb = symmath.simplify.stack
		local fail = sa == sb
		if fail or showStackAnyways then
			print('expected '..tostring(a)..' to equal '..tostring(b)..'<br>')
			print('found '..tostring(sa)..' vs '..tostring(sb)..'<br>')
			print('lhs stack<br>')
			for _,x in ipairs(ta) do printStackEntry(x) end
			print('rhs stack<br>')
			for _,x in ipairs(tb) do printStackEntry(x) end
			if fail then error'failed' end
		end
	end

	function env.simplifyAssertAllEq(ta,tb)
		local ka = env.table.keys(ta)
		local kb = env.table.keys(tb)
		local k
		if not xpcall(function()
			env.simplifyAssertEq(#ka, #kb)
			for _,_k in ipairs(ka) do
				k = _k
				printbr(symmath.op.eq(ta[k],tb[k]))
				env.simplifyAssertEq(ta[k], tb[k])
			end
		end, function(err)
			print('lhs:', ka:mapi(function(k) return k..'='..tostring(ta[k]) end):concat', ', '<br>')
			print('rhs:', kb:mapi(function(k) return k..'='..tostring(tb[k]) end):concat', ', '<br>')
			if k then
				print('when comparing key '..k, '<br>')
			end
			print('<span style="color:red">BAD</span><br>'..err..'<br>')
			print(debug.traceback():gsub('\n', '<br>\n'))
		end) then
			error'failed'
		end
	end

	function env.assertEq(a,b)
		-- hmm, maybe this fix means I need to fix Expression's ctor as well?
		do
			local va = a
			local vb = b
			if type(va) == 'boolean' then va = symmath.Variable(tostring(va)) end
			if type(vb) == 'boolean' then vb = symmath.Variable(tostring(vb)) end
			printbr(symmath.op.eq(va,vb))
		end
		if a ~= b then
			print('expected '..tostring(a)..' to equal '..tostring(b)..'<br>')
			error'failed'
		end
	end

	-- TODO expect a specific error message
	function env.assertError(f)
		local _, result = xpcall(f, function() end)
		printbr(result)
		assert(not result, "expected an error, but found none")
	end

	local testRows = {}

	local ansi_red = '\x1b[31m'
	local ansi_green = '\x1b[32m'
	local ansi_reset = '\x1b[0m'
	function env.exec(code)
		-- before executing, make sure to clear the stack / make sure a stack exists (in case we don't end up running simplify() ... )
		symmath.simplify.stack = table()

		-- strip out single-line comments, put them in bold over the code
		-- TODO just put the first/last comment over the code, and put the other comments as bold output?
		local comments = table()
		repeat
			local before, comment, after = code:match'^(.-)%-%-([^\r\n]*)(.-)$'
			if not before then break end
			comments:insert(comment)
			code = before..'\n'..after
		until false
		code = string.trim(code)
		local comment = string.trim(comments:concat'\n')

		print'<tr><td>'
		print('<b>'..comment..'</b><br>')
		--print('<code>'..code..'</code>')
		print('<pre>'..code..'</pre>')
		print'</td><td>'
		local startTime = os.clock()
		local err
		if code ~= '' then
			xpcall(function()
				print(assert(load(code, nil, nil, env))())
				--print'<br>'
				print'<span style="color:green">GOOD</span>'
				-- verbose stderr output:
				--io.stderr:write(ansi_green..checkstr..ansi_reset..' '..comment..'\n')
				-- concise:
				io.stderr:write(ansi_green..checkstr..ansi_reset)
			end, function(msg)
				err = msg..'\n'..debug.traceback()
				print('<span style="color:red">BAD</span><br>'..err:gsub('\n', '<br>\n'))
				-- verbose
				--io.stderr:write(ansi_red..failstr..ansi_reset..' '..comment..' '..err..'\n')
				-- concise
				io.stderr:write(ansi_red..failstr..ansi_reset)
			end)
		end
		local endTime = os.clock()
		local duration = endTime - startTime
		print'</td><td>'
		local simplifyStack
		if code ~= '' then
			simplifyStack = symmath.simplify.stack:mapi(function(x) return x[1] end)
			print('time: '..('%.6f'):format(duration * 1000)..'ms<br>')
			print('stack: '
				..'size: '..#simplifyStack..'<br>'
				..'<ul style="margin:0px">'
				..simplifyStack:mapi(function(x) return '<li>'..x end):concat'<br>'
				..'</ul>'
			)
		end
		print'</td></tr>'

		local row = {}
		row.comment = comment
		row.code = code
		row.error = err	-- if this is nil then the test was a success
		row.duration = duration
		row.simplifyStack = simplifyStack
		table.insert(testRows, row)
	end

	env.done = function()
		assert((unitTestCachePath/(title:gsub('/', '_')..'.lua')):write(tolua(testRows)))
		updateMaster()
	end

	print'<table border="1" style="border-collapse:collapse">'
end
