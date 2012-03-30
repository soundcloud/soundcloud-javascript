window.URI = (uri="", options={}) ->
  URI_REGEXP        = /^(?:([^:\/?\#]+):)?(?:\/\/([^\/?\#]*))?([^?\#]*)(?:\?([^\#]*))?(?:\#(.*))?/
  AUTHORITY_REGEXP  = /^(?:([^@]*)@)?([^:]*)(?::(\d*))?/
  this.scheme = this.user = this.password = this.host = this.port = this.path = this.query = this.fragment = null
  
  this.toString    = ->
    str = ""
    if this.isAbsolute()
      str += this.scheme
      str += "://"
      str += this.user + ":" + this.password + "@" if this.user?        
      str += this.host
      str += ":" + this.port   if this.port?
    
    str += this.path

    str += "/" if this.path == "" && (this.query? || this.fragment?)
    str += "?" + this.encodeParams(this.query)    if this.query?
    str += "#" + this.encodeParams(this.fragment) if this.fragment?

    str
    
  this.isRelative = -> 
    !this.isAbsolute()

  this.isAbsolute = -> 
    this.host?
  
  # decodeParams decodes a query string into an
  # object following the params rails conventions
  this.decodeParams = (string="") ->
    params = {}
    for part in string.split("&")
      if part != ""
        splitted = part.split("=")
        key   =  decodeURIComponent(splitted[0])
        value =  decodeURIComponent(splitted[1] || '').replace(/\+/g, " ")
        this.normalizeParams(params, key, value)
    
    params

  this.normalizeParams = (params, name, v = NULL) ->
    result = name.match(/^[\[\]]*([^\[\]]+)\]*(.*)/)
    k = result[1] || ''
    after = result[2] || ''
    
    if after == "" # is a standard k = v
      params[k] = v
    else if after == "[]" # is a plain array
      params[k] ||= []
      #raise TypeError, "expected Array (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Array)
      params[k].push(v)
    else if result_i = after.match(/^\[\]\[([^\[\]]+)\]$/) || result_i = after.match(/^\[\](.+)$/)
      child_key = result_i[1]
      params[k] ||= []
      #raise TypeError, "expected Array (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Array)
        
      lastP = params[k][params[k].length-1]
      if (lastP? && lastP.constructor == Object) && !lastP[child_key]?
        this.normalizeParams(lastP, child_key, v)
      else
        params[k].push this.normalizeParams({}, child_key, v)
    else
      params[k] ||= {}
      #raise TypeError, "expected Hash (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Hash)
      params[k] = this.normalizeParams(params[k], after, v)

    params
    
  # will reverse decodeParams 
  this.encodeParams = (params) ->
    paramString = ""
    if params.constructor == String
      paramString = params
    else 
      flattened = this.flattenParams(params)
      keyValueStrings = []
      for kv in flattened
        key = kv[0]
        value = kv[1]
        
        if value == null
          keyValueStrings.push(key)
        else
          keyValueStrings.push(key + "=" + encodeURIComponent(value))
      paramString = keyValueStrings.join("&")

  this.flattenParams = (params, prefix='', paramsArray=[]) ->
    if params == null 
      paramsArray.push([prefix, null]) if prefix?
    else if params.constructor == Object
      for own key, value of params
        if prefix != ""
          prefixedKey = prefix + "[" + key + "]"
        else
          prefixedKey = key

        this.flattenParams(value, prefixedKey, paramsArray)
    else if params.constructor == Array
      for value in params
        this.flattenParams(value, prefix + "[]", paramsArray)
    else if prefix != ''
      paramsArray.push([prefix, params])

    paramsArray

  this.parse = (uri="", options={}) ->
    nullIfBlank = (str) -> \
      if str == ""
        return null
      else
        return str

    result           = uri.match(URI_REGEXP)  
    this.scheme      = nullIfBlank(result[1])
    authority        = result[2]
    if authority?
      authority_result = authority.match(AUTHORITY_REGEXP)
      userinfo         = nullIfBlank(authority_result[1])

      if userinfo?
        this.user      = userinfo.split(":")[0]
        this.password  = userinfo.split(":")[1]

      this.host        = nullIfBlank(authority_result[2])
      this.port        = parseInt(authority_result[3], 10) || null

    this.path        = result[3]

    this.query    = nullIfBlank(result[4])
    this.query    = this.decodeParams(this.query)    if options.decodeQuery

    this.fragment = nullIfBlank(result[5])
    this.fragment = this.decodeParams(this.fragment) if options.decodeFragment

  this.parse(uri.toString(), options)
  this
