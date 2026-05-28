<!doctype html>
<html>
	<head>
		<meta charset='utf8'/>
		<title>Symmath Worksheet - <?=worksheetFilename?></title>
		<link rel="stylesheet" href="/server/standalone.css"/>
		<script type='module' defer>
			import { init } from './server/standalone-bridge-ajax.js';

const worksheetFilename = "<?=worksheetFilename?>";
const symmathPath = '.';	//standalone.lua includes SYMMATH_PATH in its search path
const worksheets = [
<?
local path = require 'ext.path'

-- [[ here and in tests/unit/unit.lua
local symmathPath = os.getenv'SYMMATH_PATH'
if symmathPath then
	symmathPath = path(symmathPath)
else
	-- use pth
	local fn = package.searchpath('symmath', package.path):gsub('\\', '/')
	if fn then
		symmathPath = path(fn):getdir()
	end
end
if not symmathPath then
	error("SYMMATH_PATH not defined and I can't find require 'symmath' in the LUA_PATH")
end
--]]

local sep = ''
local dir = symmathPath/'tests'
for f in path(dir):rdir() do
	local name, ext = f:getext()
	if ext == 'symmath' then
		-- hmm 'makerelative' function for path?
		if name.path:sub(1,#dir.path) == dir.path then
			name.path = name.path:sub(#dir.path+1)
			if name.path:sub(1,1) == '/' then name.path = name.path:sub(2) end
		end
		?><?=sep?><?=require 'ext.tolua'(name.path)?>
<?		sep = ','
	end
end
?>
];
			init({
				worksheetFilename : worksheetFilename,
				symmathPath : symmathPath,
				worksheets : worksheets,
			});
		</script>
	</head>
	<body>
	</body>
</html>
