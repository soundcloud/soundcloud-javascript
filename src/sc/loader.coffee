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
          @runCallbacks()
          @state = SC.Loader.States.READY

        load: ->
          @state = SC.Loader.States.LOADING
          @loadFunction()

        whenReady: (callback) ->
          switch @state
            when SC.Loader.States.UNLOADED
              @addCallback(callback)
              loadFunction.apply(this)
            when SC.Loader.States.LOADING
              @addCallback(callback)
            when SC.Loader.States.READY
              callback()
      }

    packages: {}
    registerPackage: (package) ->
      @packages[package.name] = package
