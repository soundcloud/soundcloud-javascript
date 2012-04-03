window.SC = SC.Helper.merge SC || {},
  _recorderSwfPath: "/recorder.js/recorder-0.7.swf" #?" + SC._version
  whenRecordingReady: (callback) ->
    if window.Recorder.flashInterface() && window.Recorder.flashInterface().record?
      callback()
    else
      Recorder.initialize({
        swfSrc: @.options.baseUrl + @._recorderSwfPath + "?" + @._version
        initialized: () ->
          callback()
      })

  record: (options={}) ->
    this.whenRecordingReady ->
      Recorder.record(options)
  recordStop: (options={}) ->
    Recorder.stop()
  recordPlay: (options={}) ->
    Recorder.play(options)
  recordUpload: (query={}, callback) ->
    uri = SC.prepareRequestURI("/tracks", query)
    uri.query.format = "json"
    SC.Helper.setFlashStatusCodeMaps(uri.query)
    flattenedParams = uri.flattenParams(uri.query)

    Recorder.upload({
      method: "POST",
      url: "https://" + this.hostname("api") + "/tracks"
      audioParam: "track[asset_data]",
      params: flattenedParams,
      success: (responseText) ->
        response = SC.Helper.responseHandler(responseText);
        callback(response.json, response.error)
    })