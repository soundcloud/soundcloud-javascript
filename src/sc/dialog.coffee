window.SC = SC.Helper.merge SC || {},
  _dialogsPath: "/dialogs"
  dialog: (dialogName, optionsOrCallback, callback) ->
    a = SC.Helper.extractOptionsAndCallbackArguments(optionsOrCallback, callback)
    options = a.options; callback = a.callback
    dialogId = @Dialog._generateDialogId()
    options.state = dialogId
    target = options.target
    delete options.target
    @Dialog._dialogCallbacks[dialogId] = callback
    url = @Dialog.buildUrlForDialog(dialogName, options)

    if target?
      target.src = url
    else
      SC.Helper.openCenteredPopup url, 
        width: @Dialog.WIDTH
        height: @Dialog.HEIGHT
        resizable: 0

  Dialog:
    WIDTH: 456
    HEIGHT: 510
    ECHO: "echo"
    CONNECT: "connect"
    PICKER: "picker"
    _dialogIdPrefix: "SoundCloud_Dialog"
    _dialogCallbacks: {}

    _generateDialogId: () ->
      [@_dialogIdPrefix, Math.ceil(Math.random() * 1000000).toString(16)].join("_")

    _isDialogId: (id) ->
      (id || "").match (new RegExp("^#{@_dialogIdPrefix}"))

    _getDialogIdFromWindow: (window) ->
      loc = new SC.URI(window.location, decodeQuery: true, decodeFragment: true)
      id = loc.query.state || loc.fragment.state
      if @_isDialogId(id)
        id
      else
        null

    _handleDialogReturn: (window) ->
      dialogId = @_getDialogIdFromWindow(window)
      callback = @_dialogCallbacks[dialogId]
      if callback?
        url = new SC.URI(window.location, decodeFragment: true, decodeQuery: true)
        options = SC.Helper.merge(url.query, url.fragment)
        window.close()
        callback(options)
        delete @_dialogCallbacks[dialogId]

    _handleInPopupContext: () ->
      if @_getDialogIdFromWindow(window) && !window.location.pathname.match(/\/dialogs\//)
        isiOS5 = (navigator.userAgent.match(/OS 5(_\d)+ like Mac OS X/i))
        if isiOS5
          window.opener.SC.Dialog._handleDialogReturn(window)
        else if window.opener
          window.opener.setTimeout (->
            window.opener.SC.Dialog._handleDialogReturn(window)
          ), 1
        else if window.top
          window.top.setTimeout (->
            window.top.SC.Dialog._handleDialogReturn(window)
          ), 1

    buildUrlForDialog: (dialogName, options={}) ->
      url = new SC.URI(SC._baseUrl)
      url.scheme = "http"
      url.fragment = SC.Helper.merge options,
        redirect_uri: SC.options.redirect_uri
      switch(dialogName)
        when SC.Dialog.ECHO
          url.path += SC._dialogsPath + "/" + SC.Dialog.ECHO + "/"
        when SC.Dialog.PICKER
          url.path += SC._dialogsPath + "/" + SC.Dialog.PICKER + "/"
          url.fragment.access_token = SC.accessToken()
        when SC.Dialog.CONNECT
          url.scheme = "https"
          url.host = "soundcloud.com"
          url.path = "/connect"
          url.query = url.fragment
          url.fragment = {}
      url.toString()

SC.Dialog._handleInPopupContext()
