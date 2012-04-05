module "SC._prepareStreamUrl"

test "should resolve id to /tracks/id/stream", ->
  equal SC._prepareStreamUrl(123), "http://api.soundcloud.com/tracks/123/stream?client_id=YOUR_CLIENT_ID"

test "should resolve string id to /tracks/id/stream", ->
  equal SC._prepareStreamUrl("123"), "http://api.soundcloud.com/tracks/123/stream?client_id=YOUR_CLIENT_ID"

test "should append the access token if connected", ->
  SC.accessToken("hi")
  equal SC._prepareStreamUrl("/tracks/123"), "https://api.soundcloud.com/tracks/123/stream?oauth_token=hi"

test "should preserve the secret token if passed", ->
  equal SC._prepareStreamUrl("http://api.soundcloud.com/tracks/321/stream?secret_token=s-123"), "http://api.soundcloud.com/tracks/321/stream?secret_token=s-123&client_id=YOUR_CLIENT_ID"
