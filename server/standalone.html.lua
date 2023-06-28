<!doctype html>
<html>
	<head>
		<meta charset='utf8'/>
		<title>Symmath Worksheet - <?=worksheetFilename?></title>
		<link rel="stylesheet" href="/server/standalone.css"/>
		<script type="text/javascript" src="/server/showdown-1.9.1.min.js"></script>
		<script type="text/javascript">
worksheetFilename = "<?=worksheetFilename?>";
symmathDir = '.';	//standalone.lua includes SYMMATH_PATH in its search path
symmathWorksheets = [
<?
local sep = ''
local dir = symmathPath..'/tests/'
for i,f in ipairs(require 'ext.file'(dir):rdir()) do
	if f:sub(-8) == '.symmath' then
		?><?=sep?><?=require 'ext.tolua'(f:sub(#dir+2,-9))?>
<?		sep = ','
	end
end
?>
];
		</script>
		<script type="module" src="/server/standalone-bridge-ajax.js" defer></script>
	</head>
	<body>
	</body>
</html>
