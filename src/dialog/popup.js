module.exports = {
  /**
   * Opens a centered popup with the specified URL
   * @param  {String} url
   * @param  {Number} width
   * @param  {Number} height
   * @return {Window}        A reference to the popup
   */
  open (url, width, height) {
    const options = {};
    let stringOptions;

    options.location = 1;
    options.width = width;
    options.height = height;
    options.left = window.screenX + (window.outerWidth - width) / 2;
    options.top = window.screenY + (window.outerHeight - height) / 2;
    options.toolbar = 'no';
    options.scrollbars = 'yes';

    stringOptions = Object.keys(options).map((key) => {
      return `${key}=${options[key]}`;
    }).join(', ');

    return window.open(url, options.name, stringOptions);
  }
};
