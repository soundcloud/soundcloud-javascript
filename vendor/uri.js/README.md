# URI.js
## Description
URI.js provides a ruby URI likish class for JavaScript with Rails likish params en/decoding.

## Usage
  You can create an URI object from any URI String:
  
      var uri = new URI("http://example.com/bla?abc=def#foo=bar")
      
  All important URI components are accessible through the attributes:
  
      uri.scheme        // => 'http'
      uri.user          // => null
      uri.password      // => null
      uri.host          // => 'example.com'
      uri.port          // => null
      uri.path          // => '/bla'
      uri.query         // => 'abc=def'
      uri.fragment      // => 'foo=bar'
  
  You can check if the URI is relative or absolute usining isRelative() or isAbsolute():
  
      uri.isRelative()  // => false
      uri.isAbsolute()  // => true
      
  All fragments can be manipulated through the attributes.
  The URI string can be reconstructed using toString():
  
      uri.host = "somewhere.net"
      uri.toString()    // => "http://somewhere.net/bla?abc=def#foo=bar"
      
      
  To take advantage of the rails likish params parsing pass decodeQuery and/or decodeFragment as an option:
  
      var uri = new URI("http://example.com/bla?abc=def#foo=bar", {"decodeQuery": true, "decodeFragment": true});
      uri.query         // => {"abc": "def"}
      uri.fragment      // => {"foo": "bar"}
  
  The toString() method will take care of the encoding if the query or fragment is an object:
  
      uri.query = {"some": {"deep": ["array", "stuff"]}}
      uri.toString()    // => "http://example.com/bla?some[deep][]=array&some[deep][]=stuff#foo=bar"

## Changelog

- 0.1 initial commit
  
## Development
### Requirements

- QUnit
- CoffeeScript
- JSL (JavaScript Lint)
- rake

### Getting started
    # open the test suite
    $ rake test 
    
    # watch coffeescript and build as soon as it's modified
    $ rake watch      

    # build and minify
    $ rake build


    