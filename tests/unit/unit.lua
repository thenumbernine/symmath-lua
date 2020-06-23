return function(env, title)
	require 'ext.env'(env)
	local string = env.string
	require 'symmath'.setup{env=env, debugSimplifyLoops=true, MathJax={title=title, pathToTryToFindMathJax='..'}}
	local symmath = env.symmath

	function env.assert(a)
		if not a then
			print('expected '..tostring(a)..' to be true<br>')
			error'failed'
		end
	end

	function env.asserteq(a,b)
		local sa = symmath.simplify(a)
		local ta = symmath.simplify.stack
		local sb = symmath.simplify(b)
		local tb = symmath.simplify.stack
		if sa ~= sb then
			print('expected '..tostring(a)..' to equal '..tostring(b)..'<br>')
			print('instead found '..tostring(sa)..' vs '..tostring(sb)..'<br>')
			print('lhs stack<br>')
			for _,x in ipairs(ta) do print(x[1], x[2], '<br>') end
			print('rhs stack<br>')
			for _,x in ipairs(tb) do print(x[1], x[2], '<br>') end
			error'failed'
		end
	end

	function env.assertne(a,b)
		local sa = symmath.simplify(a)
		local ta = symmath.simplify.stack
		local sb = symmath.simplify(b)
		local tb = symmath.simplify.stack
		if sa == sb then
			print('expected '..tostring(a)..' to equal '..tostring(b)..'<br>')
			print('instead found '..tostring(sa)..' vs '..tostring(sb)..'<br>')
			print('lhs stack<br>')
			for _,x in ipairs(ta) do print(x[1], x[2], '<br>') end
			print('rhs stack<br>')
			for _,x in ipairs(tb) do print(x[1], x[2], '<br>') end
			error'failed'
		end
	end

	function env.assertalleq(ta,tb)
		env.asserteq(#ta, #tb)
		for i=1,#ta do
			env.asserteq(ta[i], tb[i])
		end
	end

	local ansi_red = '\x1B[31m'
	local ansi_green = '\x1B[32m'
	local ansi_reset = '\x1B[0m'
	local check = '✓'
	local fail = '✕'
	function env.exec(line)
		local code, comment = line:match'^(.-)%-%-(.*)$'
		code = string.trim(code or line)
		comment = string.trim(comment or '')
		print('<tr><td>')
		print('<b>'..comment..'</b><br>')
		print('<code>'..code..'</code>')
		print('</td><td>')
		if code == '' then return end
		xpcall(function()
			print(assert(load(code, nil, nil, env))())
			--print'<br>'
			print'<span style="color:green">GOOD</span>'
			-- verbose stderr output:	
			--io.stderr:write(ansi_green..check..ansi_reset..' '..comment..'\n')
			-- concise:
			io.stderr:write(ansi_green..check..ansi_reset)
		end, function(err)
			print('<span style="color:red">BAD</span><br>'..err)
			-- verbose
			--io.stderr:write(ansi_red..fail..ansi_reset..' '..comment..' '..err..'\n'..debug.traceback()..'\n')
			-- concise
			io.stderr:write(ansi_red..fail..ansi_reset)
		end)
		print'</td></tr>'
	end

	print'<table border="1" style="border-collapse:collapse">'
end
