window.SC = SC.Helper.merge SC || {},
  _audiomanagerPath: "/audiomanager"
  _audiomanagerScriptPath: "/audiomanager.js"
  _players:  []

  whenStreamingReady: (callback) ->
    SC.Loader.packages.streaming.whenReady callback

  _setOnPositionListenersForComments: (player, comments, callback) ->
    window.group = SC.Helper.groupBy(comments, "timestamp")
    window.player = player
    player.on 'positionChange', (current, loaded, duration) =>
      lookup = parseInt(current, 10).toString()
      callback(window.group[lookup]) if window.group.hasOwnProperty(lookup)

  _prepareStreamUrl: (idOrUrl) ->
    if idOrUrl.toString().match /^\d.*$/
      return "/tracks/#{idOrUrl}/streams"
    uri = new SC.URI(idOrUrl, {decodeQuery: true})
    suffix = "/streams"
    if uri.path.indexOf(suffix, uri.path.length - suffix.length) == -1
      uri.path += suffix
    uri.toString()

  stream: (idOrUrl, optionsOrCallback, callback) ->
    a = SC.Helper.extractOptionsAndCallbackArguments(optionsOrCallback, callback)
    options = a.options; callback = a.callback
    options.id = "T" + idOrUrl + "-" + Math.random()

    @whenStreamingReady =>
      createAndCallback = (options) =>
        player = audioManager.createAudioPlayer(options)
        callback(player) if callback?
        player

      url = if idOrUrl.toString().match /^\d.*$/ then "/tracks/" + idOrUrl else idOrUrl
      streamsUrl = @_prepareStreamUrl(url)

      SC.get url, (track) ->
        SC.get streamsUrl, (streams) ->
          options.src = streams.http_mp3_128_url || streams.rtmp_mp3_128_url
          options.duration = track.duration
          if ontimedcommentsCallback = options.ontimedcomments
            delete options.ontimedcomments
            SC._getAll url + "/comments", (comments) =>
              player = createAndCallback(options)
              group = SC.Helper.groupBy(comments, "timestamp")
              player.on 'positionChange', (current, loaded, duration) =>
                collection = []
                for key in Object.keys(group)
                  break if key > parseInt(current, 10)
                  collection.push(group[key])
                  delete group[key]
                collection = [].concat.apply([], collection)
                ontimedcommentsCallback(collection)
          else
            createAndCallback(options)

  streamStopAll: ->
    if window.audioManager?
      for player in window.audioManager._players
        player.pause()

SC.Loader.registerPackage new SC.Loader.Package "streaming", ->
  audioManagerURL = SC._baseUrl + SC._audiomanagerPath
  SC.Helper.loadJavascript audioManagerURL + SC._audiomanagerScriptPath, ->
    window.audioManager = new AudioManager
      flashAudioPath: SC._audiomanagerPath + '/flashAudio.swf'
    SC.Loader.packages.streaming.setReady()
