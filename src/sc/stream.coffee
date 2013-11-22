window.SC = SC.Helper.merge SC || {},
  _audiomanagerPath: "/audiomanager"
  _audiomanagerScriptPath: "/audiomanager.js"

  whenStreamingReady: (callback) ->
    SC.Loader.packages.streaming.whenReady callback

  _isNumericId: (idOrUrl) ->
    return idOrUrl.toString().match /^\d.*$/

  _prepareStreamUrl: (idOrUrl) ->
    return "/tracks/#{idOrUrl}/streams" if @_isNumericId(idOrUrl)
    uri = new SC.URI(idOrUrl, {decodeQuery: true})
    suffix = "/streams"
    if uri.path.indexOf(suffix, uri.path.length - suffix.length) == -1
      uri.path += suffix
    uri.toString()

  _setOnPositionListenersForComments: (player, comments, callback) ->
    player.on 'positionChange', (current, loaded, duration) =>
      collection = []
      for key in Object.keys(comments)
        break if key > parseInt(current, 10)
        collection.push(comments[key])
        delete comments[key]
      collection = [].concat.apply([], collection)
      callback(collection)

  stream: (idOrUrl, optionsOrCallback, callback) ->
    a = SC.Helper.extractOptionsAndCallbackArguments(optionsOrCallback, callback)
    options = a.options; callback = a.callback
    options.id = "T" + idOrUrl + "-" + Math.random()

    @whenStreamingReady =>
      createAndCallback = (options) =>
        player = audioManager.createAudioPlayer(options)
        callback(player) if callback?
        player

      url = if @_isNumericId(idOrUrl) then "/tracks/" + idOrUrl else idOrUrl
      streamsUrl = @_prepareStreamUrl(url)

      SC.get url, (track) =>
        options.duration = track.duration
        SC.get streamsUrl, (streams) =>
          options.src = streams.http_mp3_128_url || streams.rtmp_mp3_128_url
          if ontimedcommentsCallback = options.ontimedcomments
            delete options.ontimedcomments
            SC._getAll url + "/comments", (comments) =>
              player = createAndCallback(options)
              group = SC.Helper.groupBy(comments, "timestamp")
              @_setOnPositionListenersForComments(player, group, ontimedcommentsCallback)
          else
            createAndCallback(options)

SC.Loader.registerPackage new SC.Loader.Package "streaming", ->
  audioManagerURL = SC._baseUrl + SC._audiomanagerPath
  SC.Helper.loadJavascript audioManagerURL + SC._audiomanagerScriptPath, ->
    window.audioManager = new AudioManager
      flashAudioPath: SC._audiomanagerPath + '/flashAudio.swf'
    SC.Loader.packages.streaming.setReady()
