$(document).ready(function(){
  module("SC.Helper");
  
  test("mergeUrlParams", function() {
    equals(
      SC.Helper.mergeUrlParams("http://soundcloud.com/bla"),
      "http://soundcloud.com/bla"
    );
    equals(
      SC.Helper.mergeUrlParams("http://soundcloud.com/bla", {}),
      "http://soundcloud.com/bla"
    );
    equals(
      SC.Helper.mergeUrlParams("http://soundcloud.com/bla?foo=bar", {foo: "blub"}),
      "http://soundcloud.com/bla?foo=blub"
    );
    equals(
      SC.Helper.mergeUrlParams("http://soundcloud.com/bla", {abc: "1 2 & 3", cba: 321}),
      "http://soundcloud.com/bla?abc=1%202%20%26%203&cba=321"
    );
  });

  test("mergeUrlParams", function() {
    equals(SC.Helper.isRelativeUrl("http://soundcloud.com/bla"), false);
    equals(SC.Helper.isRelativeUrl("https://soundcloud.com/bla"), false);
    equals(SC.Helper.isRelativeUrl("/bla"), true);
  });

  test("enforceHTTPS", function() {
    equals(SC.Helper.enforceHTTPS("http://soundcloud.com/bla"),  "https://soundcloud.com/bla");
    equals(SC.Helper.enforceHTTPS("https://soundcloud.com/bla"), "https://soundcloud.com/bla");
  });
  
  
  test("parseParameters", function(){
    deepEqual(
      SC.Helper.parseParameters("?#access_token=ASDF34refdfg2&expires_in=3599&scope=%2A"),
      {
        access_token: "ASDF34refdfg2",
        expires_in:   "3599",
        scope:        "*"
      }
    );
  });  

});