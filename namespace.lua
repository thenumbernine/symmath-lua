--[[
the main module is require'd, and what's returned holds everything
the main module then requires other files which must write to the namespace
those modules must grab the main module's namespace to read and write to it
but if it is still in construction they can't reach back to it without a require loop.
so this package will hold the main module namespace
--]]
return {}
