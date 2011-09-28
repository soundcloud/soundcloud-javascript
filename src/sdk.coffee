#############################
# SoundCloud JavaScript SDK #
#############################

window.SC ||=
  options:
    site: "soundcloud.com",
    apiHost: "api.soundcloud.com"
  connectCallbacks: {}
  _popupWindow: undefined
  
  initialize: (options) ->
    this.options[key] = value for own key, value of options
    this

#################
# AUTHORIZATION #
#################
    
  connect: (options) ->
    options.client_id    ||= SC.options.client_id
    options.redirect_uri ||= SC.options.redirect_uri
    SC.connectCallbacks.success    = options.connected
    SC.connectCallbacks.error      = options.error
    SC.connectCallbacks.general    = options.callback
    SC.connectCallbacks.disconnect = options.disconnected
  
  
    if options.client_id && options.redirect_uri
      params =
        client_id:      options.client_id
        redirect_uri:   options.redirect_uri
        response_type:  options.flow == ("code" ? "code_and_token" : "token")
        scope:          options.scope || ""
        display:        "popup"
  
      url = "https://soundcloud.com/connect?" + SC.Helper.buildQueryString(params)
  
      SC._popupWindow = SC.Helper.openCenteredPopup url, 456, 510
    else
      throw "Either client_id and redirect_uri (for user agent flow) must be passed as an option"
    
  connectCallback: ->
    popupWindow = SC._popupWindow
    params = SC.Helper.parseParameters(popupWindow.location.search + popupWindow.location.hash)
    if params.error == "redirect_uri_mismatch"
      popupWindow.document.body.innerHTML = "<p>The redirect URI '"+ popupWindow.location.toString() +"' you specified does not match the one that is configured in your SoundCloud app.</p> You can fix this in your <a href='http://soundcloud.com/you/apps' target='_blank'>app settings on SoundCloud</a>"
      return false
    
    popupWindow.close()
    if params.error
      SC._trigger("error", params.error)
    else
      SC.options.access_token = params.access_token
      expiresInMS = params.expires_in * 1000
      window.setTimeout(SC.disconnectCallback, expiresInMS)
      SC._trigger("success")
  
    SC._trigger("general", params.error)
  
  
  disconnect: ->
    this.disconnectCallback()
  
  disconnectCallback: ->
    if SC.options.access_token != undefined
      SC.options.access_token = undefined
      SC._trigger("disconnect")

  _trigger: (eventName, argument) -> 
    this.connectCallbacks[eventName](argument) if this.connectCallbacks[eventName]?

############################
# STREAMING                #
############################
  whenStreamingReady: (callback) ->
    if window.soundManager
      callback()
    else
      soundManagerURL = "http://connect.soundcloud.dev/soundmanager2/"
      window.SM2_DEFER = true;
      SC.Helper.loadJavascript soundManagerURL + "soundmanager2.js", ->
        window.soundManager = new SoundManager()
        soundManager.url = soundManagerURL;
        soundManager.flashVersion = 9;
        soundManager.useFlashBlock = false;
        soundManager.useHTML5Audio = false;
        soundManager.beginDelayedInit()
        soundManager.onready ->
          callback()
  
  stream: (track, options={}) ->
    trackId = SC.Helper.extractTrackId(track);
    # track can be id, relative, absolute
    SC.whenStreamingReady ->
      options.id = "T" + trackId
      #options.url = authenticateUrla
      #options.url = "http://api.soundcloud.com/tracks/" + trackId + "/stream?client_id=YOUR_CLIENT_ID"
      if !sound = soundManager.getSoundById(options.id)
        sound = soundManager.createSound(options)
      sound
      
############################      
#  NETWORKING              #
############################
  get: (path, query, callback) ->
    uri = this.prepareRequestURI(path, query)
    unless callback?
      callback = query
      query = undefined
    SC.Helper.JSONP.get uri, callback
    

  prepareRequestURI: (path, query={}) ->
    uri = new SC.URI(path, {"decodeQuery": true})
    
    # shallow merge of queries
    for own k,v of query
      uri.query[k] = v
    
    # add scheme & host if relative
    if uri.isRelative()
      uri.host = this.options.apiHost
      uri.scheme = "http"

    # add client_id or oauth access token
    if this.options.access_token?
      uri.query.oauth_token = this.options.access_token
      uri.scheme = "https"
    else
      uri.query.client_id    = this.options.client_id
  
    uri
  
############################   
#  HELPER                  #
############################
  Helper:      
    loadJavascript: (src, callback) ->
      elem = document.createElement("script")
      elem.async = true
      elem.src = src
      SC.Helper.attachEvent(elem, "load", callback)
      document.body.appendChild(elem)
      elem
      
    openCenteredPopup: (url, width, height) ->
      left   = window.screenX + (window.outerWidth  - width)  / 2
      top    = window.screenY + (window.outerHeight - height) / 2
      window.open(url, "connectWithSoundCloud", "location=1, width=" + width + ", height=" + height + ", top="+ top +", left="+ left +", toolbar=no,scrollbars=yes")

    attachEvent: (element, eventName, func) ->
      if element.attachEvent
        element.attachEvent("on" + eventName, func)
      else 
        element.addEventListener(eventName, func, false)
     
    JSONP:
      callbacks: {}
      randomCallbackName: ->
        "CB" + parseInt Math.random() * 999999, 10
      
      get: (uri, callback) ->
        callbackName        = this.randomCallbackName()
        uri.query.format = "js"
        uri.query.callback = "SC.Helper.JSONP.callbacks." + callbackName
        SC.Helper.JSONP.callbacks[callbackName] = callback
        
        SC.Helper.loadJavascript uri.toString(), ->
          document.body.removeChild(this)
