window.SC = SC.Helper.merge SC || {},
  _version: "1.1.5"
  _baseUrl: "//connect.soundcloud.com"
  options:
    site: "soundcloud.com"
    baseUrl: "//connect.soundcloud.com"
  connectCallbacks: {}
  _popupWindow: undefined

  initialize: (options={}) ->
    this.accessToken(options["access_token"])
    this.options[key] = value for own key, value of options
    this.options.flashXHR ||= (new XMLHttpRequest()).withCredentials == undefined
    this

  hostname: (subdomain) ->
    str = ""
    str += subdomain + "." if subdomain?
    str += this.options.site
    str
