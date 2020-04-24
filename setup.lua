-- This allows for -lsymmath.setup shorthand for "require 'symmath'.setup()"
-- I seem to use this most when running scripts in console, so I'll add in my most commonly used console setup flags.
-- Maybe I should call this file something like 'consetup'?
return require 'symmath'.setup{implicitVars=true, fixVariableNames=true}
