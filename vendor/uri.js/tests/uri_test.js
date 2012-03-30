$(document).ready(function(){
  module("URI");
  
  test("from 'http://example.com/bla?abc=def#foo=bar'", function() {
    var originalUrl = 'http://example.com/bla?abc=def#foo=bar'
    var url = new URI(originalUrl);
    equals(url.scheme,   'http');
    equals(url.user,     null);
    equals(url.password, null);
    equals(url.host,     'example.com');
    equals(url.port,     null);
    equals(url.path,     '/bla');
    equals(url.query,    'abc=def');
    equals(url.fragment, 'foo=bar');
    equals(url.isRelative(), false);
    equals(url.isAbsolute(), true);
    equals(url.toString(), originalUrl);
  });
  
  test("from 'https://user:pass@127.0.0.1:342'", function() {
    var originalUrl = 'https://user:pass@127.0.0.1:342'
    var url = new URI(originalUrl);
    equals(url.scheme,   'https');
    equals(url.user,     'user');
    equals(url.password, 'pass');
    equals(url.host,     '127.0.0.1');
    equals(url.port,     342);
    equals(url.isRelative(), false);
    equals(url.isAbsolute(), true);    
    equals(url.toString(), originalUrl);
  });

  test("from '/someweird/path.js?q=1#f=2'", function() {
    var originalUrl = '/someweird/path.js?q=1#f=2'
    var url = new URI(originalUrl);
    equals(url.scheme,   null);
    equals(url.host,     null);
    equals(url.port,     null);
    equals(url.path,     '/someweird/path.js');
    equals(url.query,    'q=1');
    equals(url.fragment, 'f=2');
    equals(url.isRelative(), true);
    equals(url.isAbsolute(), false);
    equals(url.toString(), originalUrl);
  });
  
  test("from '/someweird/path.js?#f=2'", function() {
    var originalUrl = '/someweird/path.js?#f=2'
    var url = new URI(originalUrl);
    equals(url.scheme,   null);
    equals(url.host,     null);
    equals(url.port,     null);
    equals(url.path,     '/someweird/path.js');
    equals(url.query,    null);
    equals(url.fragment, 'f=2');
  });
  
  test("from window.location", function() {
    var url = new URI(window.location);
    equals(url.toString(),   window.location.toString());
  });
  
  test("decodeQuery option", function(){
    var originalUrl = '/someweird/path.js?q=1#f=2'    
    var url = new URI(originalUrl, {decodeQuery: true});
    deepEqual(url.query, {'q': '1'});
  });

  test("decodeQuery without query", function(){
    var originalUrl = '/someweird/path.js'    
    var url = new URI(originalUrl, {decodeQuery: true, decodeFragment: true});
    deepEqual(url.query, {});
    deepEqual(url.fragment, {});
  });

  test("decodeFragment option", function(){
    var originalUrl = '/someweird/path.js?q=1#f=2'    
    var url = new URI(originalUrl, {decodeFragment: true});
    deepEqual(url.fragment, {'f': '2'});
  });

  test("toString() should encode query", function(){
    var uri = new URI("http://example.com")
    uri.query = {a: 1, b: [1,2,3]}
    equals(uri.toString(), "http://example.com/?a=1&b[]=1&b[]=2&b[]=3");
  });

  test("toString() should encode fragment", function(){
    var uri = new URI("http://example.com")
    uri.fragment = {"x": "y"}
    equals(uri.toString(), "http://example.com/#x=y");
  });


  
  module("decodeParams");
  test("decodeParams", function(){
    var uri = new URI();
    deepEqual(
      uri.decodeParams("a[]=This+is%20encoded+val&a[]=2"),
      {
        "a": ["This is encoded val", "2"]
      }
    );
    
    deepEqual(
      uri.decodeParams("foo=12%203&a[b][][id]=1&a[b][][id]=2&nope"),
      {
        "foo": "12 3",
        "a": {
          "b": [
            {"id": "1"},
            {"id": "2"}
          ]
        },
        "nope": ""
      }
    );
  });

  
  module("encodeParams");
  test("encodeParams", function(){
    var uri = new URI();
    equals(uri.encodeParams("already=Encoded"), "already=Encoded");
    equals(uri.encodeParams({a: 1, b: 2}), "a=1&b=2")
    equals(
      uri.encodeParams({
        "foo": "12 3",
        "a": {
          "b": [
            {"id": 1},
            {"id": 2}
          ]
        },
        "nope": null // is this what we want?
      }),
      "foo=12%203&a[b][][id]=1&a[b][][id]=2&nope"
    );
  });
  
  
  module("flattenParams");
  test("flattenParams", function(){
    var uri = new URI();
    deepEqual(
      uri.flattenParams({
        "foo": "12 3",
        "a": {
          "b": [
            {"id": 1},
            {"id": 2}
          ]
        },
        "nope": null // is this what we want?
      }),
      [
        ["foo",        "12 3"],
        ["a[b][][id]", 1],
        ["a[b][][id]", 2],
        ["nope",       null]
      ]
    );
  });
  
});
