#############################
# SoundCloud JavaScript SDK #
#############################

window.SC ||=
  options:
    site: "soundcloud.dev",
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

#################
# AUTHORIZATION #
#################

  connect: (options) ->
    options.client_id    ||= SC.options.client_id
    options.redirect_uri ||= SC.options.redirect_uri
    SC.connectCallbacks.success    = options.connected
    SC.connectCallbacks.error      = options.error
    SC.connectCallbacks.general    = options.callback

    if options.client_id && options.redirect_uri
      uri = new SC.URI("https://" + this.hostname() + "/connect/?")
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

    if error == "redirect_uri_mismatch"
      popupWindow.document.body.innerHTML = "<p>The redirect URI '"+ popupLocation +"' you specified does not match the one that is configured in your SoundCloud app.</p> You can fix this in your <a href='http://soundcloud.com/you/apps' target='_blank'>app settings on SoundCloud</a>"
      return false

    popupWindow.close()
    if error
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

############################
# STREAMING                #
############################
  whenStreamingReady: (callback) ->
    if window.soundManager
      callback()
    else
      soundManagerURL = "http://" + this.hostname("connect") + "/soundmanager2/"
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
    trackId = track
    # track can be id, relative, absolute
    SC.whenStreamingReady ->
      options.id = "T" + trackId
      options.url = "http://" + SC.hostname("api") + "/tracks/" + trackId + "/stream?client_id=YOUR_CLIENT_ID"
      if !sound = soundManager.getSoundById(options.id)
        sound = soundManager.createSound(options)
      sound

############################
#  XDM post, put, delete   #
############################

  whenXDMReady: (callback) ->
    if window.crossdomain?
      callback()
    else
      window.CROSSDOMAINJS_PATH = "http://" + this.hostname("connect") + "/crossdomain-requests-js"
      SC.Helper.loadJavascript CROSSDOMAINJS_PATH + "/crossdomain-ajax.js", ->
        callback()

  request: (method, path, query, callback) ->
    if !callback?
      callback = query
      query = undefined
    query ||= {}
    uri = SC.prepareRequestURI(path, query)
    uri.query.format = "json"

    if SC.options.flashXHR
      SC.Helper.setFlashStatusCodeMaps(uri.query)

    if method == "PUT" || method == "DELETE"
      uri.query._method = method
      method = "POST"

    if method != "GET"
      data = uri.encodeParams(uri.query)
      uri.query = {}

    handleResponse = (responseText, xhr) ->
      json = SC.Helper.JSON.parse(responseText)
      error = null

      if !json
        if xhr
          error = {message: "HTTP Error: " + xhr.status}
        else
          error = {message: "Unknown error"}
      else if json.errors
        error = { message: json.errors && json.errors[0].error_message }

      callback(json, error)

    if SC.options.flashXHR
      this.whenRecordingReady ->
        Recorder.request method, uri.toString(), data, handleResponse
    else
      this._request method, uri.toString(), data, handleResponse

  _request: (method, uri, data, callback) ->
    request = new XMLHttpRequest();
    request.open(method, uri.toString(), true);
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.onreadystatechange = (e) ->
      if(e.target.readyState == 4)
        callback(e.target.responseText, e.target)
    request.send(data);

  post:   (path, query, callback) ->
    this.request("POST",   path, query, callback)

  put:    (path, query, callback) ->
    this.request("PUT",    path, query, callback)

  get:    (path, query, callback) ->
    this.request("GET",    path, query, callback)

  delete: (path, callback) ->
    this.request("DELETE", path, {}, callback)

  prepareRequestURI: (path, query={}) ->
    uri = new SC.URI(path, {"decodeQuery": true})
    
    # shallow merge of queries
    for own k,v of query
      uri.query[k] = v
    
    # add scheme & host if relative
    if uri.isRelative()
      uri.host = this.hostname("api")
      uri.scheme = "http"

    # add client_id or oauth access token
    if this.accessToken()?
      uri.query.oauth_token = this.accessToken()
      uri.scheme = "https"
    else
      uri.query.client_id    = this.options.client_id
  
    uri

##################################
# oEmbed                         #
##################################

  oEmbed: (trackUrl, query, callback) ->
    # optional query
    if !callback?
      callback = query
      query = undefined
    query ||= {}
    query.url = trackUrl

    uri = new SC.URI("http://" + SC.hostname("api") + "/oembed")
    uri.query = query

    # rewrite callback if it's a DOM
    if callback.nodeType != undefined && callback.nodeType == 1
       element = callback;
       callback = (oembed) =>
         element.innerHTML = oembed.html

    SC.Helper.JSONP.get(uri, callback)

############################
# STORAGE                  #
############################
  storage: ->
    window.localStorage || this._fakeStorage = new SC.Helper.FakeStorage()

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
      options =
        location: 1
        width: width
        height: height
        left: window.screenX + (window.outerWidth  - width)  / 2
        top:  window.screenY + (window.outerHeight - height) / 2
        toolbar: "no"
        scrollbars: "yes"
      
      options2 = []
      options2.push(k + "=" + v) for own k, v of options
      window.open(url, "connectWithSoundCloud", options2.join(", "))
      
    attachEvent: (element, eventName, func) ->
      if element.attachEvent
        element.attachEvent("on" + eventName, func)
      else 
        element.addEventListener(eventName, func, false)

    setFlashStatusCodeMaps: (query) ->
      query["_status_code_map[400]"] = 200
      query["_status_code_map[401]"] = 200
      query["_status_code_map[403]"] = 200
      query["_status_code_map[404]"] = 200
      query["_status_code_map[422]"] = 200
      query["_status_code_map[500]"] = 200
      query["_status_code_map[503]"] = 200
      query["_status_code_map[504]"] = 200
    FakeStorage: ->
      return {
        _store: {}
        getItem: (key) ->
          this._store[key] || null
        setItem: (key, value) ->
          this._store[key] = value.toString()
        removeItem: (key) ->
          delete this._store.key
      }
    JSON:
      parse: (string) ->
        if string[0] != "{" && string[0] != "["
          return null
        else if window.JSON?
          window.JSON.parse(string)
        else
          eval(string)
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
