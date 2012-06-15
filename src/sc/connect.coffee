window.SC = SC.Helper.merge SC || {},
  _connectWindow: null
  connect: (optionsOrCallback) ->
    if typeof(optionsOrCallback) == "function"
      options =
        connected: optionsOrCallback
    else
      options = optionsOrCallback

    dialogOptions =
      client_id:      options.client_id || SC.options.client_id
      redirect_uri:   options.redirect_uri || SC.options.redirect_uri
      response_type:  "code_and_token"
      scope:          options.scope || "non-expiring"
      display:        "popup"
      window:         options.window
      retainWindow:   options.retainWindow

    if dialogOptions.client_id && dialogOptions.redirect_uri
      dialog = SC.dialog SC.Dialog.CONNECT, dialogOptions, (params) ->
        if params.error?
          throw new Error("SC OAuth2 Error: " + params.error_description)
        else
          SC.accessToken(params.access_token)
          options.connected() if options.connected?
        options.callback() if options.callback?
      @_connectWindow = dialog.options.window
      dialog
    else
      throw "Options client_id and redirect_uri must be passed"

  # legacy from old callback.html
  connectCallback: ->
    SC.Dialog._handleDialogReturn(SC._connectWindow)

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
