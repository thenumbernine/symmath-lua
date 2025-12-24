// mathjax config
// https://docs.mathjax.org/en/latest/web/configuration.html
window.MathJax = {
	tex: {
		inlineMath: [['$', '$'], ['\\(', '\\)']]
	},
	svg: {
		fontCache: 'global'
	}
};

const tryToFindMathJax = {};

tryToFindMathJax.urls = [
	// TODO just use CDN.  my site is down anyways.  i hate being dependent on the internet.  but the whole world has gone retarded.
	'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js',
	//'file:///home/chris/Projects/christopheremoore.net/MathJax/es5/tex-svg.js',
	//'/MathJax/es5/tex-svg.js',
];

tryToFindMathJax.loadScript = function(args) {
console.log("loading "+args.src);
	const el = document.createElement('script');
	document.body.appendChild(el);
	el.addEventListener('load', e => {
console.log('loaded');
		if (args.done !== undefined) args.done();
	});
	el.addEventListener('error', e => {
console.log("failed to load "+args.src);
		if (args.fail !== undefined) args.fail();
	});
	el.src = args.src;
	//el.id = 'MathJax-script';
	//el.async = true;
};

tryToFindMathJax.init = function(args) {
	const urls = tryToFindMathJax.urls;
	if (args === undefined) args = {};
console.log('init...');
	let i = 0;
	const loadNext = () => {
		tryToFindMathJax.loadScript({
			src : urls[i],
			done : () => {
console.log("success!");
				if (args.done !== undefined) args.done();
			},
			fail : () => {
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
};

// if I specify this as a module then I can no longer use it for file:// (without messing with browser config ... bleh)
/* if it's not a module, use this: */
window.addEventListener('DOMContentLoaded', e => {
	tryToFindMathJax.init();
}, false);
/**/
/* if it is a module, use this: * /
export {tryToFindMathJax};
/**/
