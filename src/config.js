const config = {
  oauth_token: undefined,
  baseURL: 'https://api.soundcloud.com',
  connectURL: '//connect.soundcloud.com',
  client_id: undefined,
  redirect_uri: undefined
};

module.exports = {
  get(key) {
    return config[key];
  },

  set(key, value) {
    if (value) {
      config[key] = value;
    }
  }
};
