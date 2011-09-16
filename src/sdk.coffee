window.SC ||=
  options:
    site: "soundcloud.com",
    apiHost: "http://api.soundcloud.com"
  connectCallbacks: {}
  _popupWindow: undefined
  
  initialize: (options) ->
    this.options[key] = options[key] for own key in options
    
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

  prepareStreaming: ->
    
    
    

  Helper:
    openCenteredPopup: (url, width, height) ->
      left   = window.screenX + (window.outerWidth  - width)  / 2
      top    = window.screenY + (window.outerHeight - height) / 2
      window.open(url, "connectWithSoundCloud", "location=1, width=" + width + ", height=" + height + ", top="+ top +", left="+ left +", toolbar=no,scrollbars=yes")

    attachEvent: (element, eventName, func) ->
      if(element.attachEvent)
        element.attachEvent("on" + eventName, func)
      else
        element.addEventListener(eventName, func, false)
     
    JSONP:
      callbacks: {}
      randomCallbackName: ->
        "CB" + parseInt Math.random() * 999999, 10
      
      get: (url, callback) ->
        callbackName = this.randomCallbackName()
        scriptElement = document.createElement('script')
        src = url + "&callback=SC.Helper.JSONP.callbacks." + callbackName
        scriptElement.src = src
    
        SC.Helper.attachEvent scriptElement, "load", ->
          document.body.removeChild(scriptElement)
    
        SC.Helper.JSONP.callbacks[callbackName] = callback
        document.body.appendChild(scriptElement)
      
    get: (options) ->
      options.params.format = "js"
      mergedUrl = this.mergeUrlParams(options.url, options.params)
      SC.Helper.JSONP.get mergedUrl, options.callback
    
    mergeUrlParams: (url, params) ->
      baseURL = url.split("?")[0]
      newParams = this.parseParameters(url.toString())
      params ||= {}
      for own key of params
        newParams[key] = params[key]
        
      queryString = this.buildQueryString(newParams)
      if queryString.length > 0
        queryString = "?" + queryString
      baseURL + queryString;
    
    scheme: (force) ->
      (force ? "https:" : window.location.protocol) + "//"
    
    buildUrl: (location, params) ->
      location + "?" + this.buildQueryString(params)
    
    isRelativeUrl: (url) ->
      url[0] == "/"
    
    enforceHTTPS: (url) ->
      url.replace("http:", "https:")
    
    buildQueryString: (params) ->
      queryStringArray = [];
      for own name of params
        queryStringArray.push(name + "=" + escape(params[name]))
      queryStringArray.join("&")
    
    parseParameters: (uri) -> 
      splitted = uri.split(/[&?#]/)
      if splitted[0].match(/^http/)
        splitted.shift()
    
      obj = {};
      for own i of splitted
        kv = splitted[i].split("=")
        obj[kv[0]] = unescape(kv[1]) if kv[0]
        
      obj
    
