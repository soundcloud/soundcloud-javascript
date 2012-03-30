$(document).ready(function(){
  module("SC");

  test("hostname", function(){
    SC.initialize({
      client_id: "YOUR_CLIENT_ID"
    });

    equal(SC.hostname(), "soundcloud.com");
    equal(SC.hostname("api"), "api.soundcloud.com");

    SC.initialize({
      client_id: "YOUR_CLIENT_ID",
      site:      "soundcloud.dev"
    });

    equal(SC.hostname("connect"), "connect.soundcloud.dev");

    // resetting
    SC.initialize({
      client_id: "YOUR_CLIENT_ID",
      site:      "soundcloud.com"
    });
  });

  module("SC Networking");

  test("prepareRequestURI unauthenticated", function(){
    SC.accessToken(null); //clear state
    SC.initialize({
      client_id: "YOUR_CLIENT_ID"
    });
    
    deepEqual(
      SC.prepareRequestURI("/tracks?limit=5"),
      new SC.URI("http://api.soundcloud.com/tracks?limit=5&client_id=YOUR_CLIENT_ID", {"decodeQuery": true})
    );  
  });
  
  test("prepareRequestURI authenticated", function(){
    SC.accessToken(null); //clear state
    
    SC.initialize({
      access_token: "SOME_TOKEN"
    });
    
    deepEqual(
      SC.prepareRequestURI("/tracks?limit=10", {"order": "created_at"}),
      new SC.URI("https://api.soundcloud.com/tracks?limit=10&order=created_at&oauth_token=SOME_TOKEN", {"decodeQuery": true})
    );

  });

  test("accessToken", function(){
    SC.accessToken(null); //clear state

    SC.initialize({
      access_token: "yo"
    });

    equal(SC.accessToken(), "yo");
  });

  test("fakeStorage", function(){
    var store = new SC.Helper.FakeStorage();
    equal(store.getItem("key"), null);
    equal(store.setItem("key", 123), "123");
    equal(store.getItem("key"), "123");
    store.removeItem("key");
    equal(store.getItem("key"), null);
  });
});