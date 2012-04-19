$(function(){
  var exampleSource = $(".exampleSource").val();

  if(window.location.host === "connect.soundcloud.dev"){
    exampleSource = exampleSource.replace("c202b469a633a7a5b15c9e10b5272b78", "694f15bbffd7ae8e6e399f49dd228725");
    exampleSource = exampleSource.replace("http://connect.soundcloud.com/examples/callback.html", 'http://connect.soundcloud.dev/examples/callback.html');

    exampleSource = exampleSource.replace("http://connect.soundcloud.com/sdk.js", "/sdk.js");

    exampleSource = exampleSource.replace("SC.initialize({", 'SC.initialize({ baseUrl: "http://connect.soundcloud.dev/",');
    var developmentMode = true;
    if(developmentMode) {
      exampleSource = exampleSource.replace("<script>", "<script>window.SC_DEV_SDK_READY = function(){");
      exampleSource = exampleSource.replace("\n</script>", "};</script>");
    }
  }

  $("#right code").text(exampleSource);
  $(".example").html(exampleSource);

});