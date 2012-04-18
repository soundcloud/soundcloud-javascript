TestSuite = 
  compiledSrc: "../sdk.js"
  tests: ["helper-test.coffee", "sc-test.coffee", "sc/api-test.coffee", "sc/stream-test.coffee", "integration.coffee"]

  setTestsFromParams: ->
    loc = new URI location, decodeQuery: true
    if loc.query.tests
      @tests = loc.query.tests

  initialize: () ->
    QUnit.reset = () ->
      SC.accessToken(null)

    if TestSuite.inDevelopmentMode
      window.SC_DEV_SDK_READY = () =>
        @setTestsFromParams()

        SC.initialize
          client_id: "YOUR_CLIENT_ID"
          redirect_uri: "/examples/callback.html"
          baseUrl: "../vendor"
        @loadCoffeescripts @tests
      @loadJavascript @compiledSrc
    else
      @loadJavascript @compiledSrc, () =>
        SC.initialize
          client_id:  "YOUR_CLIENT_ID"
          baseUrl: ""
        @loadCoffeescripts(@tests)


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

TestSuite.inDevelopmentMode = true;
TestSuite.initialize()