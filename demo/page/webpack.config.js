var path = require('path');

module.exports = {
	entry: './src/cea-608-demo.js',
	output: {
		filename: 'cea-608-demo.js',
		path: path.join(__dirname, 'dist')
	},
	module: {
		loaders: [{
			test: /\.css$/,
			loader: 'style-loader!css-loader'
		}]
	}
};
