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
local symmathPath = assert(os.getenv'SYMMATH_PATH', 'SYMMATH_PATH not defined')
local sep = ''
local dir = symmathPath..'/tests/'
for f in require 'ext.path'(dir):rdir() do
	if f.path:sub(-8) == '.symmath' then
		?><?=sep?><?=require 'ext.tolua'(f.path:sub(#dir+2,-9))?>
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
