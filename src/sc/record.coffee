window.SC = SC.Helper.merge SC || {},
  _recorderSwfPath: "/recorder.js/recorder-0.9.0.swf"
  whenRecordingReady: (callback) ->
    SC.Loader.packages.recording.whenReady callback

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

SC.Loader.registerPackage new SC.Loader.Package "recording", ->
  if Recorder.flashInterface()
    SC.Loader.packages.recording.setReady()
  else
    Recorder.initialize
      swfSrc: SC._baseUrl + SC._recorderSwfPath + "?" + SC._version
      initialized: () ->
        SC.Loader.packages.recording.setReady()
