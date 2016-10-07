local table = require 'ext.table'
return function(n)
	local ps = table()
	while n > 1 do
		local found = false
		for i=2,math.floor(math.sqrt(n)) do
			if n%i == 0 then
				n = n/i
				ps:insert(i)
				found = true
				break
			end
		end
		if not found then
			ps:insert(n)
			break
		end
	end
	return ps
end
