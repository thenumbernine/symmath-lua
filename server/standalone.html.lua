<!doctype html>
<html>
	<head>
		<meta charset='utf8'/>
		<title>Symmath Worksheet - <?=worksheetFilename?></title>
		<link rel="stylesheet" href="/server/standalone.css"/>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/showdown/1.9.1/showdown.min.js" integrity="sha512-L03kznCrNOfVxOUovR6ESfCz9Gfny7gihUX/huVbQB9zjODtYpxaVtIaAkpetoiyV2eqWbvxMH9fiSv5enX7bw==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
		<script type="text/javascript">
worksheetFilename = "<?=worksheetFilename?>";
symmathDir = '.';	//standalone.lua includes SYMMATH_PATH in its search path
symmathWorksheets = [
<?
local sep = ''
local dir = symmathPath..'/tests/'
for i,f in ipairs(require 'ext.path'(dir):rdir()) do
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
