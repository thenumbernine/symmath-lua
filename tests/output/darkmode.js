//https://stackoverflow.com/questions/56300132/how-to-override-css-prefers-color-scheme-setting
// do you even need to wait for page load?  if you do wait then you will get white background for a second always
//window.addEventListener('load', () => {
let darkMode = false;
if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
	darkMode = true;
}
if (darkMode) {
	document.documentElement.setAttribute('data-theme', 'dark');
} else {
	document.documentElement.removeAttribute('data-theme', 'dark');
}
//});
