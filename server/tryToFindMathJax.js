import {DOM} from '/js/util.js';

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

let tryToFindMathJax = {};

tryToFindMathJax.urls = [
	'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js',
	'/MathJax/es5/tex-svg.js',
];


tryToFindMathJax.loadScript = args => {
	console.log("loading "+args.src);
	const el = DOM('script', {
		appendTo : document.body,
	}, {
		load : e => {
console.log('loaded');
			if (args.done !== undefined) args.done();
		},
		error : e => {
console.log("failed to load "+args.src);
			if (args.fail !== undefined) args.fail();
		},
	});
	el.src = args.src;
	//el.id = 'MathJax-script';
	//el.async = true;
};

tryToFindMathJax.init = args => {
	if (args === undefined) args = {};
console.log('init...');
	let i = 0;
	const loadNext = () => {
		tryToFindMathJax.loadScript({
			src : tryToFindMathJax.urls[i],
			done : () => {
console.log("success!");
				if (args.done !== undefined) args.done();
			},
			fail : () => {
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
window.addEventListener('DOMContentLoaded', e => {
	tryToFindMathJax.init();
}, false);
*/

export {tryToFindMathJax};
