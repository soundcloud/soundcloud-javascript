#module "SC.Loader.registerPackage"

module "SC.Loader.Package"

test "should initialize correctly", ->
  fn = new Function
  pkg = new SC.Loader.Package "test", fn
  deepEqual pkg.callbacks, []
  equal pkg.state, SC.Loader.States.UNLOADED
  equal pkg.loadFunction, fn

test "#addCallback should add a callback", ->
  fn = new Function
  pkg = new SC.Loader.Package "test", (new Function)
  pkg.addCallback(fn)
  deepEqual pkg.callbacks, [fn]

test "#runCallbacks should run callbacks and remove them once called", 2, ->
  pkg = new SC.Loader.Package "test", (new Function)
  pkg.addCallback ->
    ok "callback was called"
  pkg.runCallbacks()
  deepEqual pkg.callbacks, []

test "#setReady should set state and run callbacks", 2, ->
  pkg = new SC.Loader.Package "test", (new Function)
  pkg.addCallback ->
    ok "callback was called"
  pkg.setReady()
  equal pkg.state, SC.Loader.States.READY

test "#whenReady when READY should call immediatly with calling load", 1, ->
  pkg = new SC.Loader.Package "test", ->
    ok false, "Load Function was called"
  pkg.state = SC.Loader.States.READY
  pkg.whenReady ->
    ok "callback called"

test "#whenReady when UNLOADED should add callback, set state and call load", 3, ->
  fn = new Function
  pkg = new SC.Loader.Package "test", () ->
    equal @state, SC.Loader.States.LOADING
    ok "load function was called"
    deepEqual @callbacks, [fn]
    @setReady()
  pkg.whenReady(fn)

test "#whenReady when LOADING should call once it's ready when package is loading", 1, ->
  pkg = new SC.Loader.Package "test", ->
    ok false, "Load Function was called"
  pkg.state = SC.Loader.States.LOADING
  pkg.whenReady ->
    ok "callback was called"
  pkg.setReady()


asyncTest "#load should call loadFunction and set states correctly", 3, ->
  pkg = new SC.Loader.Package "test", ->
    setTimeout (=>
      ok "loadFunction was called"
      @setReady()
      equal @state, SC.Loader.States.READY
      start()
    ), 10

  pkg.load()
  equal pkg.state, SC.Loader.States.LOADING

module "SC.Loader.registerPackage"

test "Should add package to packages", ->
  pkg = new SC.Loader.Package "test", (new Function)
  SC.Loader.registerPackage pkg
  equal SC.Loader.packages.test, pkg
