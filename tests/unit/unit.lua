local table = require 'ext.table'

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

	local ansi_red = '\x1b[31m'
	local ansi_green = '\x1b[32m'
	local ansi_reset = '\x1b[0m'
	local check = '✓'
	local fail = '✕'
	function env.exec(line)
		-- before executing, make sure to clear the stack / make sure a stack exists (in case we don't end up running simplify() ... )
		symmath.simplify.stack = table()

		local code, comment = line:match'^(.-)%-%-(.*)$'
		code = string.trim(code or line)
		comment = string.trim(comment or '')
		print'<tr><td>'
		print('<b>'..comment..'</b><br>')
		print('<code>'..code..'</code>')
		print'</td><td>'
		local startTime = os.clock()
		if code ~= '' then
			xpcall(function()
				print(assert(load(code, nil, nil, env))())
				--print'<br>'
				print'<span style="color:green">GOOD</span>'
				-- verbose stderr output:
				--io.stderr:write(ansi_green..check..ansi_reset..' '..comment..'\n')
				-- concise:
				io.stderr:write(ansi_green..check..ansi_reset)
			end, function(err)
				print('<span style="color:red">BAD</span><br>'..err..'<br>'..debug.traceback():gsub('\n', '<br>\n'))
				-- verbose
				--io.stderr:write(ansi_red..fail..ansi_reset..' '..comment..' '..err..'\n'..debug.traceback()..'\n')
				-- concise
				io.stderr:write(ansi_red..fail..ansi_reset)
			end)
		end
		local endTime = os.clock()
		print'</td><td>'
		if code ~= '' then
			print('time: '..('%.6f'):format((endTime - startTime) * 1000)..'ms<br>')
			print('stack: '
				..'size: '..#symmath.simplify.stack..'<br>'
				..'<ul style="margin:0px">'
				..symmath.simplify.stack:mapi(function(x)
					return '<li>'..x[1]
				end):concat'<br>'
				..'</ul>'
			)
		end
		print'</td></tr>'
	end

	print'<table border="1" style="border-collapse:collapse">'
end
