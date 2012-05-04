module "Full Integration Test against api.soundcloud.com"

fixtureTrackId = 41948537
fixtureAccessToken = "1-4928-9174539-e8ed8a9e7bed36a43"
fixturePrivateTrackId = 41948548
fixturePrivateTrackToken = "s-2gxGq"

# Can be used to update accessToken
#asyncTest "Retrieve token using OAuth2", 1, ->
#  SC.accessToken null
#  SC.post "/oauth2/token",
#    client_id: "YOUR_CLIENT_ID"
#    client_secret: "YOUR_CLIENT_SECRET"
#    grant_type: "password"
#    username: "js-sdk-test"
#    password: "js-sdk-test-pw"
#    scope: "non-expiring"
#  , (response) ->
#
#    SC.accessToken accessToken
#    ok response.access_token
#    start()

asyncTest "Audio Recording and Uploading", 2, ->
  SC.accessToken(fixtureAccessToken)
  trackTitle = "JS SDK Test Recording"
  uploaded = false
  SC.record
    start: ->
      ok(1, "start event fired")
    progress: ->
      SC.recordStop()
      if !uploaded
        uploaded = true
        SC.recordUpload
          track:
            title: trackTitle
            sharing: "private"
        , (track) ->
          equal track.title, trackTitle, "Track response matches track request"
          start()

asyncTest "Receive latest tracks", 1, ->
  SC.get "/tracks",
    limit: 2
  , (tracks) ->
    equal tracks.length, 2
    start()

asyncTest "Update a user description", 1, ->
  SC.accessToken(fixtureAccessToken)
  randomDescription = "ABC: " + Math.random()
  SC.put "/me",
    user:
      description: randomDescription
  , (updatedMe) ->
    equal updatedMe.description, randomDescription
    start()

asyncTest "Create a comment", 1, ->
  SC.accessToken(fixtureAccessToken)
  commentBody = "Great Track"
  SC.post "/tracks/" + fixtureTrackId + "/comments",
    comment:
      body: commentBody
  , (comment) ->
    equal comment.body, commentBody
    start()

asyncTest "Handle a 404 error", 1, ->
  SC.get "/tracks/0", (track, error) ->
    equal error.message, "404 - Not Found"
    start()

asyncTest "Use private _request to create an attachment", 1, ->
  SC.accessToken(fixtureAccessToken)
  boundary = "SOMERANDOMBOUNDARY"
  contentType = "multipart/mixed; boundary=" + boundary
  body = ""
  body += "--" + boundary + "\r\n"
  body += "Content-Disposition: form-data; name=\"oauth_token\"\r\n"
  body += "\r\n"
  body += SC.accessToken() + "\r\n"
  body += "--" + boundary + "\r\n"
  body += "Content-Disposition: form-data; name=\"attachment[asset_data]\"; filename=\"attachment\"\r\n"
  body += "Content-Type: application/octet-stream\r\n"
  body += "\r\n"
  body += "JSONPCALLBACK({a:1})\r\n"
  body += "--" + boundary + "--\r\n"
  url = "https://" + SC.hostname("api") + "/tracks/" + fixtureTrackId + "/attachments.json"
  SC._request "POST", url, contentType, body, (responseText, xhr) ->
    response = SC.Helper.responseHandler(responseText, xhr)
    equal response.json.size, 20
    start()

asyncTest "Handle a 302 redirect", 1, ->
  SC.accessToken null
  permalink_url = "http://" + SC.hostname() + "/js-sdk-test/fixture-track"
  SC.get "/resolve",
    url: permalink_url
  , (track, error) ->
    equal track.permalink_url, permalink_url
    start()

module "SC.stream"

asyncTest "Playback of a track by id within whenStreamingReady with an ontimedcomment", 2, ->
  SC.whenStreamingReady ->
    sound = SC.stream fixtureTrackId,
      autoPlay: true
      volume: 0
      ontimedcomments: (comments) ->
        equal(2, comments.length, "A timedcomments event was fired")
        start()
      onplay: () ->
        ok(true, "Playback started")

asyncTest "Playback of a private track using a secret token", 1, ->
  SC.stream "/tracks/" + fixturePrivateTrackId + "?secret_token=" + fixturePrivateTrackToken, 
    autoPlay: true
    volume: 0
    onload: () ->
      this.stop()
      ok(true, "Track Stream Loaded")
      start()
