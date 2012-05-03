TestSuite = 
  compiledSrc: "../sdk.js"
  tests: ["helper-test.coffee", "sc-test.coffee", "sc/api-test.coffee", "sc/stream-test.coffee", "integration.coffee", "sc/dialog-test.coffee", "sc/loader-test.coffee"]

  setTestsFromParams: ->
    loc = new (SC.URI || URI) location, decodeQuery: true
    if loc.query.tests
      @tests = loc.query.tests

  initialize: () ->
    QUnit.reset = () ->
      SC.accessToken(null)


    @loadJavascript @compiledSrc, =>
      @setTestsFromParams()
      SC._baseUrl = "http://" + window.location.hostname
      SC.initialize
        client_id: "YOUR_CLIENT_ID"
        redirect_uri: "/examples/callback.html"
      @loadCoffeescripts @tests


  loadCoffeescripts: (scripts, callback) ->
    script = scripts.shift()
    if script == undefined
      callback() if callback
      return []
    CoffeeScript.load script + "?" + Math.random(), () =>
      @loadCoffeescripts(scripts, callback)

  loadJavascript: (src, callback) ->
    s = document.createElement('script')
    s.type = 'text/javascript'
    s.onload = callback
    s.src = src;
    document.body.appendChild(s)

TestSuite.initialize()