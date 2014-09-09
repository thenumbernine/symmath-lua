local function tableCommutativeEqual(ac,bc)
	-- order-independent
	ac = table(ac)
	bc = table(bc)
	for ai=#ac,1,-1 do
		local bi = bc:find(ac[ai])
		if bi then
			ac:remove(ai)
			bc:remove(bi)
		end
	end
	return #ac == 0 and #bc == 0
end
return tableCommutativeEqual

