const qs = require('query-string');
const dialogStore = require('./dialog/store');

module.exports = {
  /**
   * Finds a dialog and passes it the callback's options
   * @param  {Object} options The callback's options
   */
  notifyDialog (location) {
    // in the original implementation, values are read from search and hash
    // maybe this is due to the fact, that it might change in the future
    // using both values here then as well
    const searchParams = qs.parse(location.search);
    const hashParams = qs.parse(location.hash);
    const options = {
      oauth_token: searchParams.access_token || hashParams.access_token,
      dialog_id: searchParams.state || hashParams.state,
      error: searchParams.error || hashParams.error,
      error_description: searchParams.error_description || hashParams.error_description
    };

    const dialog = dialogStore.get(options.dialog_id);
    if (dialog) {
      dialog.handleConnectResponse(options);
    }
  }
};
