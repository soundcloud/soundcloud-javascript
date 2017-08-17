const webpack = require('webpack');

module.exports = {
  entry: './index.js',
  output: {
    libraryTarget: 'commonjs2',
    filename: 'playback.js'
  },
  plugins: [ new webpack.optimize.UglifyJsPlugin() ]
};
