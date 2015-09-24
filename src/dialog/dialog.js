const deferred = require('../deferred');
const dialogStore = require('./store');
const popup = require('./popup');
const qs = require('query-string');

const ID_PREFIX = 'SoundCloud_Dialog';

/**
 * Generates an id for the connect dialog
 * @return {String} id
 */
const generateId = () => {
  return [ID_PREFIX, Math.ceil(Math.random() * 1000000).toString(16)].join('_');
};

/**
 * Build the SoundCloud connect url
 * @param  {Object} options The options that will be passed on to the connect screen
 * @return {String}         The constructed URL
 */
const createURL = (options) => {
  return `https://soundcloud.com/connect?${qs.stringify(options)}`;
}

class Dialog {
  constructor (options = {}) {
    this.id = generateId();
    this.options = options;
    // will be used to identify the correct popup window
    this.options.state = this.id;
    this.width = 456;
    this.height = 510;

    this.deferred = deferred();
  }

  /**
   * Opens the dialog and returns a promise that fulfills when the
   * user has successfully connected
   * @return {Promise}
   */
  open () {
    const url = createURL(this.options);
    this.popup = popup.open(url, this.width, this.height);
    dialogStore.set(this.id, this);
    return this.deferred.promise;
  }

  /**
   * Resolves or rejects the dialog's promise based on the provided response.
   * (Is initiated from the callback module)
   * @param  {Object} options The callback's response
   */
  handleConnectResponse (options) {
    const hasError = options.error;
    // resolve or reject the dialog's promise, based on the callback's response
    if (hasError) {
      this.deferred.reject(options);
    } else {
      this.deferred.resolve(options);
    }
    // close the popup
    this.popup.close();
  }
}

module.exports = Dialog;
