window.SC = SC.Helper.merge SC || {},
  connect: (optionsOrCallback) ->
    if typeof(optionsOrCallback) == "function"
      options =
        connected: optionsOrCallback
    else
      options = optionsOrCallback

    options.client_id    ||= SC.options.client_id
    options.redirect_uri ||= SC.options.redirect_uri
    SC.connectCallbacks.success    = options.connected
    SC.connectCallbacks.error      = options.error
    SC.connectCallbacks.general    = options.callback

    if options.client_id && options.redirect_uri
      uri = new SC.URI("https://" + this.hostname() + "/connect?")
      uri.query = 
        client_id:      options.client_id
        redirect_uri:   options.redirect_uri
        response_type:  "code_and_token"
        scope:          options.scope || "non-expiring"
        display:        "popup"
      SC._popupWindow = SC.Helper.openCenteredPopup uri.toString(), 456, 510
    else
      throw "Either client_id and redirect_uri (for user agent flow) must be passed as an option"

  connectCallback: ->
    popupWindow = SC._popupWindow
    popupLocation = popupWindow.location.toString()
    uri = new SC.URI(popupLocation, {decodeQuery: true, decodeFragment: true})
    error = uri.query.error || uri.fragment.error
    popupWindow.close()

    if error
      throw new Error("SC OAuth2 Error: " + uri.query.error_description)
      SC._trigger("error", error)
    else
      SC.accessToken(uri.fragment.access_token);
      SC._trigger("success")

    SC._trigger("general", error)

  disconnect: ->
    this.accessToken(null);
  
  _trigger: (eventName, argument) -> 
    this.connectCallbacks[eventName](argument) if this.connectCallbacks[eventName]?

  accessToken: (value) ->
    storageKey = "SC.accessToken"
    storage = this.storage()
    if value == undefined
      storage.getItem(storageKey)
    else if value == null
      storage.removeItem(storageKey)
    else
      storage.setItem(storageKey, value)

  isConnected: ->
    this.accessToken()?