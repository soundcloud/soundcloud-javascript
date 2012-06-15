window.SC = SC.Helper.merge SC || {},
  _dialogsPath: "/dialogs"
  dialog: (dialogName, optionsOrCallback, callback) ->
    a = SC.Helper.extractOptionsAndCallbackArguments(optionsOrCallback, callback)
    options = a.options; callback = a.callback

    options.callback = callback
    options.redirect_uri = @options.redirect_uri
    dialog = new SC.Dialog[dialogName + "Dialog"](options)
    SC.Dialog._dialogs[dialog.id] = dialog
    dialog.open()
    dialog

  Dialog:
    ECHO: "Echo"
    CONNECT: "Connect"
    PICKER: "Picker"
    ID_PREFIX: "SoundCloud_Dialog"
    _dialogs: {}

    _isDialogId: (id) ->
      (id || "").match (new RegExp("^#{@ID_PREFIX}"))

    _getDialogIdFromWindow: (window) ->
      loc = new SC.URI(window.location, decodeQuery: true, decodeFragment: true)
      id = loc.query.state || loc.fragment.state
      if @_isDialogId(id)
        id
      else
        null

    _handleDialogReturn: (window) ->
      dialogId = @_getDialogIdFromWindow(window)
      dialog = @_dialogs[dialogId]
      if dialog?
        if dialog.handleReturn()
          delete @_dialogs[dialogId]

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

    AbstractDialog: class AbstractDialog
      WIDTH: 456
      HEIGHT: 510
      ID_PREFIX: "SoundCloud_Dialog"
      PARAM_KEYS: ["redirect_uri"]
      requiresAuthentication: false

      generateId: ->
        [@ID_PREFIX, Math.ceil(Math.random() * 1000000).toString(16)].join("_")

      constructor: (@options={}) ->
        @id = @generateId()

      buildURI: (uri=new SC.URI(SC._baseUrl)) ->
        uri.scheme = "http"
        uri.path += SC._dialogsPath + "/" + @name + "/"

        uri.fragment =
          state: @id

        if @requiresAuthentication
          uri.fragment.access_token = SC.accessToken()

        for paramKey in @PARAM_KEYS
          uri.fragment[paramKey] = @options[paramKey] if @options[paramKey]?

        uri

      open: ->
        if @requiresAuthentication && !SC.accessToken()?
          @authenticateAndOpen()
        else
          url = @buildURI()
          if @options.window?
            @options.window.location = url
          else
            @options.window = SC.Helper.openCenteredPopup url,
              width: @WIDTH
              height: @HEIGHT

      authenticateAndOpen: ->
        connectDialog = SC.connect
          retainWindow: true
          window: @options.window
          connected: =>
            @options.window = connectDialog.options.window
            @open()

      paramsFromWindow: ->
        url = new SC.URI(@options.window.location, decodeFragment: true, decodeQuery: true)
        params = SC.Helper.merge url.query, url.fragment

      handleReturn: ->
        params = @paramsFromWindow()
        @options.window.close() unless @options.retainWindow
        @options.callback(params)

    EchoDialog: class EchoDialog extends AbstractDialog
      PARAM_KEYS: ["client_id", "redirect_uri", "hello"]
      name: "echo"

    PickerDialog: class PickerDialog extends AbstractDialog
      PARAM_KEYS: ["client_id", "redirect_uri"]
      name: "picker"
      requiresAuthentication: true

      handleReturn: ->
        params = @paramsFromWindow()
        if params.action == "logout"
          SC.accessToken(null)
          @open()
          false
        else if params.track_uri?
          @options.window.close() unless @options.retainWindow
          SC.get params.track_uri, (track) =>
            @options.callback
              track: track
          true

    ConnectDialog: class ConnectDialog extends AbstractDialog
      PARAM_KEYS: ["client_id", "redirect_uri", "client_secret", "response_type", "scope", "display"]
      name: "connect"
      buildURI: ->
        uri = super
        uri.scheme = "https"
        uri.host = "soundcloud.com"
        uri.path = "/connect"
        uri.query = uri.fragment
        uri.fragment = {}
        uri

SC.Dialog._handleInPopupContext()
