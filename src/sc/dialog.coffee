window.SC = SC.Helper.merge SC || {},
  _dialogsPath: "/dialogs"
  dialog: (dialogName, optionsOrCallback, callback) ->
    a = SC.Helper.extractOptionsAndCallbackArguments(optionsOrCallback, callback)
    options = a.options; callback = a.callback
    url = @Dialog.buildUrlForDialog(dialogName, options)

    name = @Dialog._generateWindowName()
    @Dialog._dialogCallbacks[name] = callback
    SC.Helper.openCenteredPopup url, 
      width: @Dialog.WIDTH
      height: @Dialog.HEIGHT
      name: name

  Dialog:
    WIDTH: 456
    HEIGHT: 510
    ECHO: "echo"
    CONNECT: "connect"
    PICKER: "picker"
    _windowNamePrefix: "SoundCloud Dialog"
    _dialogCallbacks: {}

    _generateWindowName: () ->
      [@_windowNamePrefix, Math.ceil(Math.random() * 1000000).toString(16)].join("_")

    _isDialogWindowName: (name) ->
      name.match (new RegExp("^#{@_windowNamePrefix}"))

    _handleDialogReturn: (window) ->
      callback = @_dialogCallbacks[window.name]
      if callback?
        url = new SC.URI(window.location, decodeFragment: true, decodeQuery: true)
        options = SC.Helper.merge(url.query, url.fragment)
        window.close()
        callback(options)
        delete @_dialogCallbacks[window.name]

    _handleInPopupContext: () ->
      if @_isDialogWindowName(window.name) && !window.location.pathname.match(/\/dialogs\//)
        window.opener.setTimeout (->
          window.opener.SC.Dialog._handleDialogReturn(window);
        ), 1

    buildUrlForDialog: (dialogName, options={}) ->
      url = new SC.URI(SC._baseUrl)
      url.fragment = SC.Helper.merge options,
        redirect_uri: SC.options.redirect_uri
      switch(dialogName)
        when SC.Dialog.ECHO
          url.path += SC._dialogsPath + "/" + SC.Dialog.ECHO
        when SC.Dialog.CONNECT
          url.scheme = "https"
          url.host = "soundcloud.com"
          url.path = "/connect"
          url.query = url.fragment
          url.fragment = {}
      url.toString()

SC.Dialog._handleInPopupContext()
