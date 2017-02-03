var renderer = require('./caption-renderer.js');

var player = document.querySelector("#player");
var ccContainer = document.querySelector(".sixOeight-container");
var videoSource = 'https://content.uplynk.com/154126917cff4a6f95bf8c3c43c48551.m3u8';
var renderer;

window.onCaptionData = function(data) {
	console.log('capData', decodeURIComponent(data));
	renderer.injectCea608Cue(JSON.parse(decodeURIComponent(data)));
}

window.onCaptionCommand = function(data) {
	console.log('capCommand', decodeURIComponent(data));
	renderer.injectCea608Cue(JSON.parse(decodeURIComponent(data)));
}

if (player !== null && ccContainer !== null) {
	console.log('creating caption renderer');
	renderer = renderer(ccContainer);

	if (window.playerIsReady) {
		console.log('playerIsReady');
		player.load(videoSource);
		renderer.initialize();
	} else {
		console.log('waiting for player ready');
		window.playerReady = function() {
			player.load(videoSource);
			renderer.initialize();
		}
	}
} else {
	console.log('no player element found');
}