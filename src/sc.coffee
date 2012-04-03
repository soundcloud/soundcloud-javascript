window.SC = SC.Helper.merge SC || {},
  _version: "1.0.13"
  options:
    baseUrl: "http://connect.soundcloud.com"
    site: "soundcloud.com"
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
