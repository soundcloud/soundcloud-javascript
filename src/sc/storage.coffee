window.SC = SC.Helper.merge SC || {},
  storage: ->
    @_fakeStorage ||= new SC.Helper.FakeStorage()
