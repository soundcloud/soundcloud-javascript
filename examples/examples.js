$(function(){
  var exampleSource = $(".exampleSource").val();
  var credentials = {
    "connect.soundcloud.dev": {
      sdk: "/sdk.js",
      key: "694f15bbffd7ae8e6e399f49dd228725",
      redirect_uri: 'http://connect.soundcloud.dev/examples/callback.html'
    },

    /*"connect.soundcloud.dev": {
      sdk: "/sdk.js",
      key: "00c9cd78323eaae31c9007d847d14b25",
      redirect_uri: 'http://connect.soundcloud.dev/examples/callback-old.html'
    },*/

    "connect.soundcloud.com": {
      sdk: "//connect.soundcloud.com/sdk.js",
      key: "c202b469a633a7a5b15c9e10b5272b78",
      redirect_uri: 'http://connect.soundcloud.com/examples/callback.html'
    },

    "sc-sdk.ponyho.st": {
      sdk: "/sdk.js",
      key: "2ca0ee245bd49b2c9daa620097d635b3",
      redirect_uri: 'http://sc-sdk.ponyho.st/examples/callback.html'
    }
  }

  originalCredentials = credentials["connect.soundcloud.com"];
  newCredentials = credentials[window.location.host];

  exampleSource = exampleSource.replace(originalCredentials.sdk, newCredentials.sdk);
  exampleSource = exampleSource.replace(originalCredentials.key, newCredentials.key);
  exampleSource = exampleSource.replace(originalCredentials.redirect_uri, newCredentials.redirect_uri);

  $("#right code").text(exampleSource);
  $(".example").html(exampleSource);


  if(window.location.host !== "connect.soundcloud.com"){
    window.setTimeout(function(){
      SC._baseUrl = "http://" + window.location.hostname;
    }, 1000);
  }
});
