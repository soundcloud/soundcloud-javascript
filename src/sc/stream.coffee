class Player
  constructor: (@_player) ->

  play: (position) ->
    if @_player.getState() == "loading" or @_player.getState() == "initialize"
      @_player.on 'stateChange', (state) ->
        @play() if state == "idle"
    else
      @_player.play()

  stop: ->
    @_player.pause()
    @_player.seek(0)

  pause: -> @_player.pause()
  seek: (ms) -> @_player.seek(ms)
  setVolume: (volume) -> @_player.setVolume(volume)
  getVolume: -> @_player.getVolume()
  getType: -> @_player.getType()
  getCurrentPosition: -> @_player.getCurrentPosition()
  getLoadedPosition: -> @_player.getLoadedPosition()
  getDuration: -> @_player.getDuration()
  getState: -> @_player.getState()

window.SC = SC.Helper.merge SC || {},

  whenStreamingReady: (callback) ->
    SC.Loader.packages.streaming.whenReady callback

  _isNumeric: (idOrUrl) ->
    idOrUrl.toString().match /^\d.*$/

  _prepareTrackUrl: (idOrUrl) ->
    url = if @_isNumeric(idOrUrl) then "/tracks/#{idOrUrl}" else idOrUrl
    preparedUrl = SC.prepareRequestURI(url)
    preparedUrl.toString()

  _prepareStreamUrl: (idOrUrl) ->
    url = if @_isNumeric(idOrUrl) then "/tracks/#{idOrUrl}" else idOrUrl
    preparedUrl = SC.prepareRequestURI(url)
    preparedUrl.path += "/streams" if !preparedUrl.path.match(/\/stream/)
    preparedUrl.toString()

  _setOnPositionListenersForComments: (player, comments, callback) ->
    group = SC.Helper.groupBy(comments, "timestamp")
    player._player.on 'positionChange', (current, loaded, duration) ->
      collection = []
      for key in Object.keys(group)
        break if key > parseInt(current, 10)
        collection.push(group[key])
        delete group[key]
      collection = [].concat.apply([], collection)
      callback(collection)

  stream: (idOrUrl, optionsOrCallback, callback) ->
    a = SC.Helper.extractOptionsAndCallbackArguments(optionsOrCallback, callback)
    options = a.options; callback = a.callback

    options.id = "T" + idOrUrl + "-" + Math.random()
    track_url = @_prepareTrackUrl(idOrUrl)
    stream_url = @_prepareStreamUrl(idOrUrl)

    SC.whenStreamingReady ->
      SC.get track_url, (track) ->
        options.duration = track.duration
        SC.get stream_url, (streams) ->
          options.src = streams.http_mp3_128_url || streams.rtmp_mp3_128_url

          createAndCallback = (options) =>
            player = new Player(audioManager.createAudioPlayer(options))
            callback(player) if callback?
            player

          if ontimedcommentsCallback = options.ontimedcomments
            delete options.ontimedcomments
            SC._getAll track_url + "/comments", (comments) ->
              player = createAndCallback(options)
              SC._setOnPositionListenersForComments(player, comments, ontimedcommentsCallback)
          else
            createAndCallback(options)

  streamStopAll: ->
    if window.audioManager?
      for player in window.audioManager._players
        player.pause()
        player.seek(0)

SC.Loader.registerPackage new SC.Loader.Package "streaming", ->
  if window.audioManager?
    SC.Loader.packages.streaming.setReady()
  else
    audioManagerURL = SC._baseUrl + '/audiomanager'
    SC.Helper.loadJavascript audioManagerURL + '/audiomanager.js', ->
      window.audioManager = new AudioManager
        flashAudioPath: SC._baseUrl + '/audiomanager/flashAudio.swf'
      SC.Loader.packages.streaming.setReady()
