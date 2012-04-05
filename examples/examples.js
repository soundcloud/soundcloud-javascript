$(function(){
  var code = $(".example").html();
  $("#right code").text(code);

  if(window.location.host === "connect.soundcloud.dev"){
    SC.initialize({
      client_id:    "694f15bbffd7ae8e6e399f49dd228725",
      redirect_uri: "http://connect.soundcloud.dev/examples/callback.html",
      baseUrl:      "http://connect.soundcloud.dev/"
    });
  }
});