local namespace
return function(...)
	local old = namespace	
	if select('#', ...) > 0 then
		namespace = ...
	end
	return old
end
