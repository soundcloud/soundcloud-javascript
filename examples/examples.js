$(function(){
  var exampleSource = $(".exampleSource").val();

  if(window.location.host === "connect.soundcloud.dev"){
    exampleSource = exampleSource.replace("c202b469a633a7a5b15c9e10b5272b78", "694f15bbffd7ae8e6e399f49dd228725");
    exampleSource = exampleSource.replace("http://connect.soundcloud.com/examples/callback.html", 'http://connect.soundcloud.dev/examples/callback.html');
    exampleSource = exampleSource.replace("http://connect.soundcloud.com/sdk.js", "/sdk.js");
  }

  $("#right code").text(exampleSource);
  $(".example").html(exampleSource);

});