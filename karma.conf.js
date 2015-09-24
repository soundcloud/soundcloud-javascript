const VERSION = require('./package.json').version

module.exports = function(config) {
  config.set({
    browsers: ['Chrome', 'Firefox', 'Safari'],

    frameworks: ['chai', 'mocha', 'sinon'],

    files: [
      'build/sdk/sdk-' + VERSION + '.js',
      'test/*.js'
    ]
  });
};

