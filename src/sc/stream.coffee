window.SC = SC.Helper.merge SC || {},
  _soundmanagerPath: "/soundmanager2"
  _soundmanagerScriptPath: "/soundmanager2.js"
  whenStreamingReady: (callback) ->
    SC.Loader.packages.streaming.whenReady callback

  _prepareStreamUrl: (idOrUrl) ->
    if idOrUrl.toString().match /^\d.*$/ # legacy rewrite from id to path
      url = "/tracks/" + idOrUrl
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

  stream: (idOrUrl, optionsOrCallback, callback) ->
    a = SC.Helper.extractOptionsAndCallbackArguments(optionsOrCallback, callback)
    options = a.options; callback = a.callback

    SC.whenStreamingReady =>
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

  streamStopAll: ->
    if window.soundManager?
      window.soundManager.stopAll()

SC.Loader.registerPackage new SC.Loader.Package "streaming", ->
  if window.soundManager?
    SC.Loader.packages.streaming.setReady()
  else
    soundManagerURL = SC._baseUrl + SC._soundmanagerPath
    window.SM2_DEFER = true;
    SC.Helper.loadJavascript soundManagerURL + SC._soundmanagerScriptPath, ->
      window.soundManager = new SoundManager()
      soundManager.url = soundManagerURL;
      soundManager.flashVersion = 9;
      soundManager.useFlashBlock = false;
      soundManager.useHTML5Audio = false;
      soundManager.beginDelayedInit()
      soundManager.onready ->
        SC.Loader.packages.streaming.setReady()
