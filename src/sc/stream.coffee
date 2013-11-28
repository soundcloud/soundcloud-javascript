class Handler
  whenStreamingReady: (callback) ->
    SC.Loader.packages.streaming.whenReady callback

  _isNumericId: (idOrUrl) ->
    idOrUrl.toString().match /^\d.*$/

class SoundManagerHandler extends Handler

  _prepareStreamUrl: (idOrUrl) ->
    if @_isNumericId(idOrUrl)
      url = "/tracks/#{idOrUrl}"
    else
      url = idOrUrl
    preparedUrl = SC.prepareRequestURI(url)
    preparedUrl.path += "/stream" if !preparedUrl.path.match(/\/stream/)
    preparedUrl.toString()

  _setOnPositionListenersForComments: (sound, comments, callback) ->
    group = SC.Helper.groupBy(comments, "timestamp")
    for timestamp, commentBatch of group
      do (timestamp, commentBatch, callback) ->
        sound.onposition parseInt(timestamp, 10), () ->
          callback(commentBatch)

  stream: (idOrUrl, options, callback) ->
    @whenStreamingReady =>
      options.id = "T" + idOrUrl + "-" + Math.random()
      options.url = @_prepareStreamUrl(idOrUrl)

      createAndCallback = (options) =>
        sound = soundManager.createSound(options)
        callback(sound) if callback?
        sound

      if ontimedcommentsCallback = options.ontimedcomments
        delete options.ontimedcomments
        SC._getAll options.url.replace("/stream", "/comments"), (comments) =>
          sound = createAndCallback(options)
          @_setOnPositionListenersForComments(sound, comments, ontimedcommentsCallback)
      else
        createAndCallback(options)

class AudioManagerHandler extends Handler

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

  stream: (idOrUrl, options, callback) ->
    options.id = "T" + idOrUrl + "-" + Math.random()

    @whenStreamingReady =>
      createAndCallback = (options) =>
        player = audioManager.createAudioPlayer(options)
        player.stop = ->
          @pause()
          @seek(0)
        if player.getState() == "initialize" or player.getState() == "loading"
          player.on 'stateChange', (state) ->
            player.play() if state == "idle"
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


window.SC = SC.Helper.merge SC || {},
  stream: (idOrUrl, optionsOrCallback, callback) ->
    a = SC.Helper.extractOptionsAndCallbackArguments(optionsOrCallback, callback)
    options = a.options; callback = a.callback
    handler = if options.enableRTMP then new AudioManagerHandler else new SoundManagerHandler
    handler.stream(idOrUrl, a.options, a.callback)

  streamStopAll: ->
    if window.soundManager?
      window.soundManager.stopAll()

SC.Loader.registerPackage new SC.Loader.Package "streaming", ->
  window.SM2_DEFER = true;
  scriptUrls =
    'audiomanager': SC._baseUrl + '/audiomanager/audiomanager.js',
    'soundmanager2': SC._baseUrl + '/soundmanager2/soundmanager2.js'
  SC.Helper.loadJavascript scriptUrls.audiomanager, ->
    window.audioManager = new AudioManager
      flashAudioPath: '/audiomanager/flashAudio.swf'
    if window.soundManager?
      SC.Loader.packages.streaming.setReady()
    else
      SC.Helper.loadJavascript scriptUrls.soundmanager2, ->
        window.soundManager = new SoundManager({debugFlash: false})
        soundManager.url = SC._baseUrl + '/soundmanager2'
        soundManager.debugFlash = false
        soundManager.flashVersion = 9
        soundManager.useFlashBlock = false
        soundManager.useHTML5Audio = false
        soundManager.beginDelayedInit()
        soundManager.onready ->
          SC.Loader.packages.streaming.setReady()
