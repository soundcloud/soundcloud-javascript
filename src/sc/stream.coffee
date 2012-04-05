window.SC = SC.Helper.merge SC || {},
  _soundmanagerPath: "/soundmanager2/"
  _soundmanagerScriptPath: "soundmanager2.js"
  whenStreamingReady: (callback) ->
    if window.soundManager
      callback()
    else
      soundManagerURL = @.options.baseUrl + @._soundmanagerPath
      window.SM2_DEFER = true;
      SC.Helper.loadJavascript soundManagerURL + @_soundmanagerScriptPath, ->
        window.soundManager = new SoundManager()
        soundManager.url = soundManagerURL;
        soundManager.flashVersion = 9;
        soundManager.useFlashBlock = false;
        soundManager.useHTML5Audio = false;
        soundManager.beginDelayedInit()
        soundManager.onready ->
          callback()

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
    if callback?                                    # for stream(id, opt, cb)
      options = optionsOrCallback
    else if typeof(optionsOrCallback) == "function" # for stream(id, cb)
      callback = optionsOrCallback
    else
      options = optionsOrCallback || {}             # for stream(id, opt) || stream(id)

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