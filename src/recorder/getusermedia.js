const getUserMedia = global.navigator.getUserMedia ||
                     global.navigator.webkitGetUserMedia ||
                     global.navigator.mozGetUserMedia;

module.exports = (options, success, error) => {
  getUserMedia.call(global.navigator, options, success, error);
};
