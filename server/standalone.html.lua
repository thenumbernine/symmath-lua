<html>
	<head>
		<title>Symmath Worksheet - <?=worksheetFilename?></title>
		<script type="text/javascript" src="jquery-3.6.0.min.js"></script>
		<script type="text/javascript" src="tryToFindMathJax.js"></script>
		<script type="text/javascript" src="standalone-bridge-ajax.js"></script>
		<script type="text/javascript" src="standalone.js"></script>
		<link rel="stylesheet" href="standalone.css"/>
		<script>
worksheetFilename = "<?=worksheetFilename?>";

//TODO would be nice to find mathjax async, and rebuild all mathjax cell outputs once mathjax is loaded
$(document).ready(function() {
	tryToFindMathJax({
		done : function() {
			init(document.body);
		},
		fail : fail
	});
});
		</script>
	</head>
	<body>
	</body>
</html>

