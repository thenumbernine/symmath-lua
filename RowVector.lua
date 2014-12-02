require 'ext'
local Expression = require 'symmath.Expression'

-- should default be columns or rows?
-- rows, so a_ij = Row[i].Element[j]
-- also so input matches what is seen on the screen
local RowVector = class(Expression)
RowVector.name = 'RowVector'
RowVector.precedence = 10

return RowVector

