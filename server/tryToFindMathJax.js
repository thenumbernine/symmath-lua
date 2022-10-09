// mathjax config
// https://docs.mathjax.org/en/latest/web/configuration.html
MathJax = {
	tex: {
		inlineMath: [['$', '$'], ['\\(', '\\)']]
	},
	svg: {
		fontCache: 'global'
	}
};

function loadScript(args) {
	console.log("loading "+args.src);
	var el = document.createElement('script');
	document.body.append(el);
	el.onload = function() {
		console.log('loaded');
		if (args.done !== undefined) args.done();
	};
	el.onerror = function() {
		console.log("failed to load "+args.src);
		if (args.fail !== undefined) args.fail();
	};
	el.src = args.src;
}

function tryToFindMathJax(args) {
	if (args === undefined) args = {};
	console.log('init...');
	var urls = [
		'/MathJax/MathJax.js?config=TeX-MML-AM_CHTML',
		'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js'
	];
	var i = 0;
	var loadNext = function() {
		loadScript({
			src : urls[i],
			done : function() {
				console.log("success!");
				if (args.done !== undefined) args.done();
			},
			fail : function() {
				++i;
				if (i >= urls.length) {
					console.log("looks like all our sources have failed!");
					if (args.fail !== undefined) args.fail();
				} else {
					loadNext();
				}
			}
		});
	}
	loadNext();
}
