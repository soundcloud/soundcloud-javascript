window.SC = SC.Helper.merge SC || {},
  _soundmanagerPath: "/soundmanager2/"
  whenStreamingReady: (callback) ->
    if window.soundManager
      callback()
    else
      soundManagerURL = @.options.baseUrl + @._soundmanagerPath
      window.SM2_DEFER = true;
      SC.Helper.loadJavascript soundManagerURL + "soundmanager2.js", ->
        window.soundManager = new SoundManager()
        soundManager.url = soundManagerURL;
        soundManager.flashVersion = 9;
        soundManager.useFlashBlock = false;
        soundManager.useHTML5Audio = false;
        soundManager.beginDelayedInit()
        soundManager.onready ->
          callback()
  
  stream: (track, options={}) ->
    trackId = track
    # track can be id, relative, absolute
    SC.whenStreamingReady ->
      options.id = "T" + trackId + "-" + Math.random()
      options.url = "http://" + SC.hostname("api") + "/tracks/" + trackId + "/stream?client_id=" + SC.options.client_id
      sound = soundManager.createSound(options)
      sound

  streamStopAll: ->
    if window.soundManager?
      window.soundManager.stopAll()