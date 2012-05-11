window.SC ||= {}
SC.Helper =
  merge: (a, b) ->
    if a.constructor == Array
      newObj = Array.apply(null, a)
      newObj.push(v) for own v in b
      newObj
    else
      newObj = {}
      newObj[k] = v for own k,v of a
      newObj[k] = v for own k,v of b
      newObj

  groupBy: (collection, attribute) ->
    group = {}
    for object in collection
      if value = object[attribute]
        group[object[attribute]] ||= []
        group[object[attribute]].push(object)
    group

  loadJavascript: (src, callback) ->
    elem = document.createElement("script")
    elem.async = true
    elem.src = src
    SC.Helper.attachLoadEvent(elem, callback)
    document.body.appendChild(elem)
    elem

  extractOptionsAndCallbackArguments: (optionsOrCallback, callback) ->
    args = {}
    if callback?                                    # for (opt, cb)
      args.callback = callback
      args.options = optionsOrCallback
    else if typeof(optionsOrCallback) == "function" # for (cb)
      args.callback = optionsOrCallback
      args.options = {}
    else
      args.options = optionsOrCallback || {}        # for (opt) || ()
    args

  openCenteredPopup: (url, width, height) ->
    options = {}
    if height?
      options.width = width
      options.height = height
    else # threat width as options
      options = width

    options = SC.Helper.merge options,
      location: 1
      left: window.screenX + (window.outerWidth  - options.width)  / 2
      top:  window.screenY + (window.outerHeight - options.height) / 2
      toolbar: "no"
      scrollbars: "yes"
    window.open(url, options.name, @_optionsToString(options))

  _optionsToString: (options) ->
    optionsArray = []
    optionsArray.push(k + "=" + v) for own k, v of options
    optionsArray.join(", ")

  attachLoadEvent: (element, func) ->
    if element.addEventListener
      element.addEventListener("load", func, false)
    else
      element.onreadystatechange = ->
        if this.readyState == "complete"
          func()

  millisecondsToHMS: (ms) ->
    hms = {
      h: Math.floor(ms/(60*60*1000)),
      m: Math.floor((ms/60000) % 60),
      s: Math.floor((ms/1000) % 60)
    }
    tc = []
    tc.push(hms.h) if (hms.h > 0)
    m = hms.m;

    mPrefix = ""
    sPrefix = ""
    mPrefix = "0" if hms.m < 10 && hms.h > 0
    sPrefix = "0" if hms.s < 10

    tc.push(mPrefix + hms.m)
    tc.push(sPrefix + hms.s)
    tc.join('.')

  setFlashStatusCodeMaps: (query) ->
    query["_status_code_map[400]"] = 200
    query["_status_code_map[401]"] = 200
    query["_status_code_map[403]"] = 200
    query["_status_code_map[404]"] = 200
    query["_status_code_map[422]"] = 200
    query["_status_code_map[500]"] = 200
    query["_status_code_map[503]"] = 200
    query["_status_code_map[504]"] = 200

  responseHandler: (responseText, xhr) ->
    json = SC.Helper.JSON.parse(responseText)
    error = null

    if !json
      if xhr
        error = {message: "HTTP Error: " + xhr.status}
      else
        error = {message: "Unknown error"}
    else if json.errors
      error = { message: json.errors && json.errors[0].error_message }

    {"json": json, "error": error}

  FakeStorage: ->
    return {
      _store: {}
      getItem: (key) ->
        this._store[key] || null
      setItem: (key, value) ->
        this._store[key] = value.toString()
      removeItem: (key) ->
        delete this._store[key]
    }
  JSON:
    parse: (string) ->
      if string[0] != "{" && string[0] != "["
        return null
      else if window.JSON?
        window.JSON.parse(string)
      else
        eval(string)
