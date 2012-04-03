TestSuite = 
  compiledSrc: "../sdk.js"
  srcs: ["../src/helper.coffee", "../src/sc.coffee","../src/sc/api.coffee", "../src/sc/auth.coffee", "../src/sc/oembed.coffee", "../src/sc/record.coffee", "../src/sc/storage.coffee", "../src/sc/stream.coffee"]
  tests: ["unit/sc-helper-test.coffee"]
  initialize: () ->
    if TestSuite.inDevelopmentMode
      all = $.merge(@srcs, @tests)
      @loadCoffeescripts(all)
    else
      @loadJavascript @compiledSrc, () =>
        @loadCoffeescripts(@tests)

  loadCoffeescripts: (scripts) ->
    script = scripts.shift()
    return if script == undefined
    CoffeeScript.load script + "?" + Math.random(), () =>
      @loadCoffeescripts(scripts)

  loadJavascript: (src, callback) ->
    s = document.createElement('script')
    s.type = 'text/javascript'
    s.onload = callback
    s.src = src;
    document.body.appendChild(s)

TestSuite.inDevelopmentMode = true;
TestSuite.initialize()