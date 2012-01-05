$(function(){
  QUnit.config.reorder = false;
  SC.initialize({
    site: "soundcloud.dev",
    client_id: "YOUR_CLIENT_ID"
  });

  /* the first 2 tests will setup the accessToken and fixture track */
  var fixtureTrackId, accessToken;

  asyncTest("Retrieve token using OAuth2", 1, function(){
    SC.accessToken(null);
    SC.post("/oauth2/token", {
      'client_id':     'YOUR_CLIENT_ID',
      'client_secret': 'YOUR_CLIENT_SECRET',
      'grant_type':    'password',
      'username':      'js-sdk-test',
      'password':      'js-sdk-test-pw'
    }, function(response){
      accessToken = response.access_token;
      SC.accessToken(accessToken);
      ok(response.access_token);
      start();
    });
  });
  
  asyncTest("Audio Recording and Uploading", 1, function(){
    var trackTitle = "JS SDK Test Recording";
    SC.record({
      start: function(){
        window.setTimeout(function(){
          SC.recordStop();
          SC.recordUpload({
            track: {
              title: trackTitle,
              sharing: "private"
            }}, function(track){
              fixtureTrackId = track.id;
              equal(track.title, trackTitle);
              start();
            }
          );
        }, 2000);
      }
    })
  });

  asyncTest("Receive latest tracks", 1, function(){
    SC.get("/tracks", {limit: 2}, function(tracks){
      equal(tracks.length, 2);
      start();
    });
  });

  asyncTest("Update a user description", 1, function(){
    var randomDescription = "ABC: " + Math.random();
    SC.put("/me", {user: {description: randomDescription}}, function(updatedMe){
      equal(updatedMe.description, randomDescription);
      start();
    });
  });

  asyncTest("Create a comment", 1, function(){
    var commentBody = "Great Track";
    SC.post("/tracks/" + fixtureTrackId + "/comments", {comment: {body: commentBody}}, function(comment){
      equal(comment.body, commentBody);
      start();
    });
  });

  asyncTest("Handle a 404 error", 1, function(){
    SC.get("/tracks/0", function(track, error){
      equal(error.message, "404 - Not Found");
      start();
    });
  });

  asyncTest("Use private _request to create an attachment", 1, function(){
    var boundary = "SOMERANDOMBOUNDARY";
    var contentType = "multipart/mixed; boundary=" + boundary;
    var body = "";

    body += "--" + boundary + "\r\n";
    body += "Content-Disposition: form-data; name=\"oauth_token\"\r\n";
    body += "\r\n";
    body += SC.accessToken() + "\r\n";

    body += "--" + boundary + "\r\n";
    body += "Content-Disposition: form-data; name=\"attachment[asset_data]\"; filename=\"attachment\"\r\n";
    body += "Content-Type: application/octet-stream\r\n";
    body += "\r\n";
    body += "JSONPCALLBACK({a:1})\r\n";
    body += "--" + boundary + "--\r\n";

    var url = "https://" + SC.hostname("api") + "/tracks/" + fixtureTrackId + "/attachments.json";
    SC._request("POST", url, contentType, body, function(responseText, xhr){
      response = SC.Helper.responseHandler(responseText, xhr);
      equals(response.json.size, 20);
      start();
    });
  });

  /* logged out tests */

  asyncTest("Handle a 302 redirect", 1, function(){
    SC.accessToken(null);
    var permalink_url = "http://" + SC.hostname() + "/js-sdk-test/fixture-track";
    SC.get("/resolve", {url: permalink_url}, function(track, error){
      equal(track.permalink_url, permalink_url);
      start();
    });
  });
});
