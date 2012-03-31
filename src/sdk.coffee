#############################
# SoundCloud JavaScript SDK #
#############################

window.SC =
  _version: "1.0.13"
  _recorderSwfPath: "/recorder.js/recorder-0.7.swf" #?" + SC._version
  _soundmanagerPath: "/soundmanager2/"
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

#################
# AUTHORIZATION #
#################
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

############################
# STREAMING                #
############################
  whenStreamingReady: (callback) ->
    if window.soundManager
      callback()
    else
      soundManagerURL = @.options.baseUrl + @._soundmanagerPath
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
      options.id = "T" + trackId + "-" + Math.random()
      options.url = "http://" + SC.hostname("api") + "/tracks/" + trackId + "/stream?client_id=" + SC.options.client_id
      sound = soundManager.createSound(options)
      sound

  streamStopAll: ->
    if window.soundManager?
      window.soundManager.stopAll()

############################
#  XDM post, put, delete   #
############################
  _apiRequest: (method, path, query, callback) ->
    if !callback?
      callback = query 
      query = undefined
    query ||= {}
    uri = SC.prepareRequestURI(path, query)
    uri.query.format = "json"

    if SC.options.flashXHR
      SC.Helper.setFlashStatusCodeMaps(uri.query)
    else
      uri.query["_status_code_map[302]"] = 200

    if method == "PUT" || method == "DELETE"
      uri.query._method = method
      method = "POST"

    if method != "GET"
      data = uri.encodeParams(uri.query)
      uri.query = {}

    this._request method, uri, "application/x-www-form-urlencoded", data, (responseText, xhr) ->
      response = SC.Helper.responseHandler(responseText, xhr)
      if response.json && response.json.status == "302 - Found"
        SC._apiRequest("GET", response.json.location, callback)
      else
        callback(response.json, response.error)

  _request: (method, uri, contentType, data, callback) ->
    if SC.options.flashXHR
      this._flashRequest method, uri, contentType, data, callback
    else
      this._xhrRequest   method, uri, contentType, data, callback

  _xhrRequest: (method, uri, contentType, data, callback) ->
    request = new XMLHttpRequest();
    request.open(method, uri.toString(), true);
    request.setRequestHeader("Content-Type", contentType)
    request.onreadystatechange = (e) ->
      if(e.target.readyState == 4)
        callback(e.target.responseText, e.target)
    request.send(data);

  _flashRequest: (method, uri, contentType, data, callback) ->
    this.whenRecordingReady ->
      Recorder.request method, uri.toString(), contentType, data, (data, xhr) ->
        callback(Recorder._externalInterfaceDecode(data), xhr)

  post:   (path, query, callback) ->
    this._apiRequest("POST",   path, query, callback)

  put:    (path, query, callback) ->
    this._apiRequest("PUT",    path, query, callback)

  get:    (path, query, callback) ->
    this._apiRequest("GET",    path, query, callback)

  delete: (path, callback) ->
    this._apiRequest("DELETE", path, {}, callback)

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

    uri = new SC.URI("http://" + SC.hostname() + "/oembed.json")
    uri.query = query

    # rewrite callback if it's a DOM
    if callback.nodeType != undefined && callback.nodeType == 1
       element = callback;
       callback = (oembed) =>
         element.innerHTML = oembed.html

    @._request "GET", uri.toString(), null, null, (responseText, xhr) ->
      response = SC.Helper.responseHandler(responseText, xhr)
      callback(response.json, response.error)

############################
# STORAGE                  #
############################
  storage: ->
    window.localStorage || this._fakeStorage = new SC.Helper.FakeStorage()

############################
# Record                   #
############################
  whenRecordingReady: (callback) ->
    if window.Recorder.flashInterface() && window.Recorder.flashInterface().record?
      callback()
    else
      Recorder.initialize({
        swfSrc: @.options.baseUrl + @._recorderSwfPath + "?" + @._version
        initialized: () ->
          callback()
      })

  record: (options={}) ->
    this.whenRecordingReady ->
      Recorder.record(options)
  recordStop: (options={}) ->
    Recorder.stop()
  recordPlay: (options={}) ->
    Recorder.play(options)
  recordUpload: (query={}, callback) ->
    uri = SC.prepareRequestURI("/tracks", query)
    uri.query.format = "json"
    SC.Helper.setFlashStatusCodeMaps(uri.query)
    flattenedParams = uri.flattenParams(uri.query)

    Recorder.upload({
      method: "POST",
      url: "https://" + this.hostname("api") + "/tracks"
      audioParam: "track[asset_data]",
      params: flattenedParams,
      success: (responseText) ->
        response = SC.Helper.responseHandler(responseText);
        callback(response.json, response.error)
    })

