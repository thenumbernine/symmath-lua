local table = require 'ext.table'
return function(a,b)
	-- order-independent
	a = table(a)
	b = table(b)
	for i=#a,1,-1 do
		local j = b:find(a[i])
		if j then
			a:remove(i)
			b:remove(j)
		end
	end
	return #a == 0 and #b == 0
end
