module "SC"
test "hostname", ->
  SC.initialize client_id: "YOUR_CLIENT_ID"
  equal SC.hostname(), "soundcloud.com"
  equal SC.hostname("api"), "api.soundcloud.com"
  SC.initialize
    client_id: "YOUR_CLIENT_ID"
    site: "soundcloud.dev"

  equal SC.hostname("connect"), "connect.soundcloud.dev"
  SC.initialize
    client_id: "YOUR_CLIENT_ID"
    site: "soundcloud.com"

module "SC Networking"
test "prepareRequestURI unauthenticated", ->
  SC.accessToken null
  SC.initialize client_id: "YOUR_CLIENT_ID"
  deepEqual SC.prepareRequestURI("/tracks?limit=5"), new SC.URI("http://api.soundcloud.com/tracks?limit=5&client_id=YOUR_CLIENT_ID",
    decodeQuery: true
  )

test "prepareRequestURI authenticated", ->
  SC.accessToken null
  SC.initialize access_token: "SOME_TOKEN"
  deepEqual SC.prepareRequestURI("/tracks?limit=10",
    order: "created_at"
  ), new SC.URI("https://api.soundcloud.com/tracks?limit=10&order=created_at&oauth_token=SOME_TOKEN",
    decodeQuery: true
  )

test "accessToken", ->
  SC.accessToken null
  SC.initialize access_token: "yo"
  equal SC.accessToken(), "yo"

test "fakeStorage", ->
  store = new SC.Helper.FakeStorage()
  equal store.getItem("key"), null
  equal store.setItem("key", 123), "123"
  equal store.getItem("key"), "123"
  store.removeItem "key"
  equal store.getItem("key"), null

test "oEmbed", ->
  expectCallAndStub SC, "_request", (method, uri, contentType, data, cb) ->
    equal method, "GET"
    equal uri, "http://soundcloud.com/oembed.json?url=http%3A%2F%2Fsoundcloud.com%2Fforss%2Fflickermood"

  SC.oEmbed "http://soundcloud.com/forss/flickermood", ->
    1
