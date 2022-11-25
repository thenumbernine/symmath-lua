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

var tryToFindMathJax = {};

tryToFindMathJax.urls = [
	'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js',
	'/MathJax/es5/tex-svg.js',
];


tryToFindMathJax.loadScript = function(args) {
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
	//el.setAttr('id', 'MathJax-script');
	//el.setAttr('async');
};

tryToFindMathJax.init = function(args) {
	if (args === undefined) args = {};
	console.log('init...');
	var i = 0;
	var loadNext = function() {
		tryToFindMathJax.loadScript({
			src : tryToFindMathJax.urls[i],
			done : function() {
				console.log("success!");
				if (args.done !== undefined) args.done();
			},
			fail : function() {
				++i;
				if (i >= tryToFindMathJax.urls.length) {
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
/*
window.addEventListener('load', function() {
	tryToFindMathJax.init();
}, false);
*/
