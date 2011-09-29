$(document).ready(function(){
  module("SC");

  test("hostname", function(){
    SC.initialize({
      client_id: "YOUR_CLIENT_ID"
    });

    // should default to sc.dev
    equals(SC.hostname(), "soundcloud.dev");

    // should prepend a subdomain if passed
    equals(SC.hostname("api"), "api.soundcloud.dev");

    SC.initialize({
      client_id: "YOUR_CLIENT_ID",
      site:      "soundcloud.com"
    })
    equals(SC.hostname("connect"), "connect.soundcloud.com");
  });

  module("SC Networking");

  test("prepareRequestURI unauthenticated", function(){
    SC.initialize({
      client_id: "YOUR_CLIENT_ID"
    });
    
    deepEqual(
      SC.prepareRequestURI("/tracks?limit=5"),
      new SC.URI("http://api.soundcloud.com/tracks?limit=5&client_id=YOUR_CLIENT_ID", {"decodeQuery": true})
    );  
  });
  
  test("prepareRequestURI authenticated", function(){
    SC.initialize({
      access_token: "SOME_TOKEN"
    });
    
    deepEqual(
      SC.prepareRequestURI("/tracks?limit=10", {"order": "created_at"}),
      new SC.URI("https://api.soundcloud.com/tracks?limit=10&order=created_at&oauth_token=SOME_TOKEN", {"decodeQuery": true})
    );  
  });
});