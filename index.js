const api = require('./src/api');
const callback = require('./src/callback');
const config = require('./src/config');
const connect = require('./src/connect');
const Promise = require('es6-promise').Promise;
const Recorder = require('./src/recorder/recorder');
const stream = require('./src/stream');

module.exports = global.SC = {
  initialize (options = {}) {
    // set tokens
    config.set('oauth_token', options.oauth_token);
    config.set('client_id', options.client_id);
    config.set('redirect_uri', options.redirect_uri);
    config.set('baseURL', options.baseURL);
    config.set('connectURL', options.connectURL);
  },

  /** API METHODS */
  get (path, params) {
    return api.request('GET', path, params);
  },

  post (path, params) {
    return api.request('POST', path, params);
  },

  put (path, params) {
    return api.request('PUT', path, params);
  },

  delete (path) {
    return api.request('DELETE', path);
  },

  upload (options) {
    return api.upload(options);
  },

  /** CONNECT METHODS */
  connect (options) {
    return connect(options);
  },

  isConnected () {
    return config.get('oauth_token') !== undefined;
  },

  /** OEMBED METHODS */
  oEmbed (url, options) {
    return api.oEmbed(url, options);
  },

  /** RESOLVE METHODS */
  resolve (url) {
    return api.resolve(url);
  },

  /** RECORDER */
  Recorder: Recorder,

  /** PROMISE **/
  Promise: Promise,

  stream (trackPath, secretToken) {
    return stream(trackPath, secretToken);
  },

  connectCallback () {
    callback.notifyDialog(this.location);
  }
};
