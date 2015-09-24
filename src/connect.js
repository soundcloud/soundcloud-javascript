const config = require('./config');
const Dialog = require('./dialog/dialog');
const Promise = require('es6-promise').Promise;

/**
 * Sets the oauth_token to the value that was provided by the callback
 * @param  {Object} options The callback's parameters
 * @return {Object}         The callback's parameters
 */
const setOauthToken = (options) => {
  config.set('oauth_token', options.oauth_token);
  return options;
};

module.exports = function (options = {}) {
  // resolve immediately when oauth_token is set
  const oauth_token = config.get('oauth_token');
  if (oauth_token) {
    return new Promise((resolve) => { resolve({oauth_token}); });
  }
  // set up the options for the dialog
  // make `client_id`, `redirect_uri` and `scope` overridable
  const dialogOptions = {
    client_id: options.client_id || config.get('client_id'),
    redirect_uri: options.redirect_uri || config.get('redirect_uri'),
    response_type: 'code_and_token',
    scope: options.scope || 'non-expiring',
    display: 'popup'
  };

  // `client_id` and `redirect_uri` have to be passed
  if (!dialogOptions.client_id || !dialogOptions.redirect_uri) {
    throw new Error('Options client_id and redirect_uri must be passed');
  }

  // set up and open the dialog
  // set access token when user is done
  let dialog = new Dialog(dialogOptions);
  return dialog.open().then(setOauthToken);
};
