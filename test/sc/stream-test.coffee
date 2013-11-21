module "SC.whenStreamingReady"

asyncTest "should be able to handle multiple calls in a row", 2, ->
  SC.whenStreamingReady ->
    ok 1, "first was called"
  SC.whenStreamingReady ->
    ok 1, "second was called"
    start()

module "SC._prepareStreamUrl"

test "should resolve id to /tracks/id/streams", ->
  equal SC._prepareStreamUrl(123), "/tracks/123/streams"

test "should resolve string id to /tracks/id/streams", ->
  equal SC._prepareStreamUrl("123"), "/tracks/123/streams"

test "should preserve the secret token if passed", ->
  equal SC._prepareStreamUrl("http://api.soundcloud.com/tracks/321/streams?secret_token=s-123"), "http://api.soundcloud.com/tracks/321/streams?secret_token=s-123"
