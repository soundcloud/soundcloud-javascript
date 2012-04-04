module "SC.api"

test "_getAll() should do multiple .get calls with incremented offsets while returned array is not empty ", 3, ->
  first = true
  expectCallAndStub SC, "get", 2, (path, query, callback) ->
    if first
      first = false
      equal(0, query.offset, "should pass offset=0 first time")
      callback([1,2,3], null)
    else
      equal(50, query.offset, "should pass offset=50 second time")
      callback([])

  SC._getAll "/tracks", () ->
    console.log('called')







