window.SC = SC.Helper.merge SC || {},
  storage: ->
    window.localStorage || this._fakeStorage = new SC.Helper.FakeStorage()
