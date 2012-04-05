window.SC = SC.Helper.merge SC || {},
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

  _getAll: (path, query, callback, collection=[]) ->
    if !callback?
      callback = query
      query = undefined
    query ||= {}
    query.offset ||= 0
    query.limit  ||= 50
    this.get path, query, (objects, error) ->
      if objects.constructor == Array && objects.length > 0
        collection = SC.Helper.merge(collection, objects)
        query.offset += query.limit
        SC._getAll(path, query, callback, collection)
      else
        callback(collection, null)
        #callback.apply(this, arguments);
