const config = require('./config');
const form = require('form-urlencoded');
const Promise = require('es6-promise').Promise;

const sendRequest = (method, url, data, progress) => {
  let xhr;
  const requestPromise = new Promise((resolve) => {
    const isFormData = global.FormData && (data instanceof FormData);
    xhr = new XMLHttpRequest();

    if (xhr.upload) {
      xhr.upload.addEventListener('progress', progress);
    }
    xhr.open(method, url, true);

    if (!isFormData) {
      xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    }

    xhr.onreadystatechange = () => {
      if (xhr.readyState === 4) {
        resolve({responseText: xhr.responseText, request: xhr});
      }
    };

    xhr.send(data);
  });

  requestPromise.request = xhr;
  return requestPromise;
};

/**
 * Parses the public API's response and constructs error messages
 * @param  {String}         responseText  The API's raw response
 * @param  {XMLHttpRequest} xhr           The original XMLHttpRequest
 * @return {Object({json, error})}        An object containing the response and a possible error
 */
const parseResponse = ({responseText, request}) => {
  let error, json;
  try {
    json = JSON.parse(responseText);
  } catch (e) {

  }

  if (!json) {
    if (request) {
      error = { message: `HTTP Error: ${request.status}` };
    } else {
      error = { message: 'Unknown error' };
    }
  } else if (json.errors) {
    error = { message: '' };
    if (json.errors[0] && json.errors[0].error_message) {
      error = { message: json.errors[0].error_message };
    }
  }

  if (error) {
    error.status = request.status;
  }

  return { json, error };
};

/**
 * Executes the public API request
 * @param  {String}     method    The HTTP method (GET, POST, PUT, DELETE)
 * @param  {String}     url       The resource's url
 * @param  {Object}     data      Data to send along with the request
 * @param  {Function=}  progress  upload progress handler
 * @return {Promise}
 */
const sendAndFollow = (method, url, data, progress) => {
  const requestPromise = sendRequest(method, url, data, progress);
  const followPromise = requestPromise.then(({responseText, request}) => {
    const response = parseResponse({responseText, request});

    if (response.json && response.json.status === '302 - Found') {
      return sendAndFollow('GET', response.json.location, null);
    } else {
      if (request.status !== 200 && response.error) {
        throw response.error;
      } else {
        return response.json;
      }
    }
  });
  followPromise.request = requestPromise.request;
  return followPromise;
};

const addParams = (params, additionalParams, isFormData) => {
  Object.keys(additionalParams).forEach((key) => {
    if (isFormData) {
      params.append(key, additionalParams[key]);
    } else {
      params[key] = additionalParams[key];
    }
  });
};

module.exports = {
  /**
   * Executes the public API request
   * @param  {String}            method HTTP method
   * @param  {String}            path   The resource's path
   * @param  {(Object|FormData)} params Parameters that will be sent
   * @param  {Function=}         progress  optional upload progress handler
   * @return {Promise}
   */
  request (method, path, params = {}, progress = () => {}) {
    const oauthToken = config.get('oauth_token');
    const clientId = config.get('client_id');
    const additionalParams = {};
    const isFormData = global.FormData && (params instanceof FormData);
    let data, url;

    additionalParams.format = 'json';

    // set the oauth_token or, in case none has been issued yet, the client_id
    if (oauthToken) {
      additionalParams.oauth_token = oauthToken;
    } else {
      additionalParams.client_id = clientId;
    }

    // add the additional params to the received params
    addParams(params, additionalParams, isFormData);

    // in case of POST, PUT, DELETE -> prepare data
    if (method !== 'GET') {
      data = isFormData ? params : form.encode(params);
      params = { oauth_token: oauthToken };
    }

    // prepend `/` if not present
    path = path[0] !== '/' ? `/${path}` : path;

    // construct request url
    url = `${config.get('baseURL')}${path}?${form.encode(params)}`;

    return sendAndFollow(method, url, data, progress);
  },

  /**
   * Fetches oEmbed information for the provided URL.
   * Also embeds the response into an element if prodived in options
   * @param  {String} trackUrl
   * @param  {Object} options
   * @return {Promise}
   */
  oEmbed (trackUrl, options = {}) {
    // save element
    const element = options.element;
    delete options.element;

    options.url = trackUrl;

    // construct URL
    const url = `https://soundcloud.com/oembed.json?${form.encode(options)}`;

    // send the request and embed response into element if provided
    return sendAndFollow('GET', url, null).then((oEmbed) => {
      if (element && oEmbed.html) {
        element.innerHTML = oEmbed.html;
      }
      return oEmbed;
    });
  },

  /**
   * Uploads a track to SoundCloud
   * @param  {Object}     options      The track's properties
   * @param  {String}     title        The track's title
   * @param  {Blob}       file         The track's data
   * @param  {Blob=}      artwork_data The track's artwork
   * @param  {Function=}  progress     Progress callback
   * @return {Promise}
   */
  upload (options = {}) {
    const file = options.asset_data || options.file;
    const canMakeRequest = config.get('oauth_token') && options.title && file;

    if (!canMakeRequest) {
      return new Promise((resolve, reject) => {
        reject({
          status: 0,
          error_message: 'oauth_token needs to be present and title and asset_data / file passed as parameters'
        });
      });
    }

    const properties = Object.keys(options);
    const formData = new FormData();

    // add all data to formdata
    properties.forEach((property) => {
      let value = options[property];
      // `file` is used as short hand for `asset_data`
      if (property === 'file') {
        property = 'asset_data';
        value = options['file'];
      }

      formData.append(`track[${property}]`, value);
    });

    return this.request('POST', '/tracks', formData, options.progress);
  },

  /**
   * Resolves a SoundCloud url to a JSON representation of its entity
   * @param  {String} url The URL that should get resolved
   * @return {Promise}
   */
  resolve (url) {
    return this.request('GET', '/resolve', { url: url });
  }
};
