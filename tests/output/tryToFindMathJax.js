// mathjax config
// https://docs.mathjax.org/en/latest/web/configuration.html
window.MathJax = window.MathJax || {};
window.MathJax.tex = window.MathJax.tex || {};
window.MathJax.tex.inlineMath = [['$', '$'], ['\\(', '\\)']];
window.MathJax.svg = window.MathJax.svg || {};
window.MathJax.svg.fontCache = 'global';
// MathJax can easily parse and render a 500x500 matrix of expressions,
// but as soon as you put as many macros in it (to cut down on file size), it feels the need to buffer everything, and you now have to request allocation of the entire string's size's worth of memory up front.
window.MathJax.tex.maxBuffer = 5 * 1024 * 1024;	// macro substitution exceeding the 5k buffer size
// And you have to declare to it how many macros are going to be in the expression as its macro substitution upper bound.
window.MathJax.tex.maxMacros = 1024 * 1024;		// default is 1000 or so
// They say this is to stop it from having a recursive macro expansion run-on.
// But honestly.  Just detect loops in the recursive replacement graph.  And just output as you read macros.
// No need for a buffer, no need to count macros, problem solved.
//
// The solution turns out to be, you must define your macros in the MathJax.tex.macros config object before initializing MathJax.
// Only then it will use O(1) memory instead of O(n) .... smfh idk why.
// Hmm but that isn't 100% true, I still do need to raise the buffer sizes, but it does seem to be more stable with macros written in the MathJax config.


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
