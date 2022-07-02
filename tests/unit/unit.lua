local table = require 'ext.table'
local os = require 'ext.os'
local io = require 'ext.io'
local fromlua = require 'ext.fromlua'
local tolua = require 'ext.tolua'
	
local checkstr = '✓'
local failstr = '✕'

local symmathPath = os.getenv'SYMMATH_PATH'		-- I have it set to HOME/Projects/lua/symmath
assert(symmathPath, "expected environment variable SYMMATH_PATH to be set")
local unitTestPath = symmathPath..'/tests/unit'
local unitTestCachePath = symmathPath..'/tests/unit-cache'
local unitTestOutputPath = symmathPath..'/tests/output/unit'
os.mkdir(unitTestCachePath, true)
os.mkdir(unitTestOutputPath, true)

local function updateMaster()
	local allTestResults = {}
	for fn in os.listdir(unitTestCachePath) do
		local title, ext = io.getfileext(fn)
		if ext == 'lua' then
			allTestResults[title] = fromlua(io.readfile(unitTestCachePath..'/'..fn)) 
		end
	end
	io.writefile(unitTestOutputPath..'/master.html', [[
<!doctype html>
<html>
	<head>
		<meta charset='utf8'/>
		<title>test/unit master</title>
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
	border: 1px solid black;
	padding: 1px;
}
		</style>
	</head>
	<body>
		<table>
]]
..table.keys(allTestResults):sort():mapi(function(title)
	local rows = allTestResults[title]
	title = title:match'^tests_unit_(.*)$' or title
	return '<tr><td class="title">'
		.. '<a href="'..title..'.html">' .. title .. '</a>'
		.. '</td><td class="content">'
		.. 	table.mapi(rows, function(row) 
				if row.error then
					return '<span style="color:red">'..failstr..'</span>'
				else
					return '<span style="color:green">'..checkstr..'</span>'
				end
			end):concat()
		.. '</td></tr>'
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

	function env.simplifyAssertEq(a,b, showStackAnyways)
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
			for _,x in ipairs(ta) do print(x[1], x[2], '<br>') end
			print('rhs stack<br>')
			for _,x in ipairs(tb) do print(x[1], x[2], '<br>') end
			if fail then error'failed' end
		end
	end

	function env.simplifyLHSAssertEq(a, b, showStackAnyways)
		assert(a ~= nil, "simplifyLHSAssertEq lhs is nil")
		assert(b ~= nil, "simplifyLHSAssertEq rhs is nil")
		local sa = symmath.simplify(a)
		local ta = symmath.simplify.stack
		local fail = sa ~= b
		if fail or showStackAnyways then
			print('expected '..tostring(a)..' to equal '..tostring(b)..'<br>')
			print('found '..tostring(sa)..' vs '..tostring(b)..'<br>')
			print('lhs stack<br>')
			for _,x in ipairs(ta) do print(x[1], x[2], '<br>') end
			if fail then error'failed' end
		end
	end

	function env.simplifyAssertNe(a,b, showStackAnyways)
		local sa = symmath.simplify(a)
		local ta = symmath.simplify.stack
		local sb = symmath.simplify(b)
		local tb = symmath.simplify.stack
		local fail = sa == sb
		if fail or showStackAnyways then
			print('expected '..tostring(a)..' to equal '..tostring(b)..'<br>')
			print('found '..tostring(sa)..' vs '..tostring(sb)..'<br>')
			print('lhs stack<br>')
			for _,x in ipairs(ta) do print(x[1], x[2], '<br>') end
			print('rhs stack<br>')
			for _,x in ipairs(tb) do print(x[1], x[2], '<br>') end
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
		if a ~= b then
			print('expected '..tostring(a)..' to equal '..tostring(b)..'<br>')
			error'failed'
		end
	end

	-- TODO expect a specific error message
	function env.assertError(f)
		local result = xpcall(f, function() end)
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
		print('<code>'..code..'</code>')
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
		assert(io.writefile(unitTestCachePath..'/'..title:gsub('/', '_')..'.lua', tolua(testRows)))
		updateMaster()
	end

	print'<table border="1" style="border-collapse:collapse">'
end
