return function(x)
	if x.precedence then return x.precedence end
	return 10
end

