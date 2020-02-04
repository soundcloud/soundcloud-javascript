const getUserMedia = global.navigator ? (global.navigator.getUserMedia ||
                     global.navigator.webkitGetUserMedia ||
                     global.navigator.mozGetUserMedia) : false;

module.exports = (options, success, error) => {
  getUserMedia.call(global.navigator, options, success, error);
};
