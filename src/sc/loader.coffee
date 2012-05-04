window.SC = SC.Helper.merge SC || {},
  Loader:
    States:
      UNLOADED: 1
      LOADING:  2
      READY:    3
    Package: (name, loadFunction) ->
      {
        name: name
        callbacks: []
        loadFunction: loadFunction
        state: SC.Loader.States.UNLOADED

        addCallback: (fn) ->
          @callbacks.push(fn)

        runCallbacks: ->
          for callback in @callbacks
            callback.apply(this)
          @callbacks = []

        setReady: ->
          @state = SC.Loader.States.READY
          @runCallbacks()

        load: ->
          @state = SC.Loader.States.LOADING
          @loadFunction.apply(this)

        whenReady: (callback) ->
          switch @state
            when SC.Loader.States.UNLOADED
              @addCallback(callback)
              @load()
            when SC.Loader.States.LOADING
              @addCallback(callback)
            when SC.Loader.States.READY
              callback()
      }

    packages: {}
    registerPackage: (pkg) ->
      @packages[pkg.name] = pkg
