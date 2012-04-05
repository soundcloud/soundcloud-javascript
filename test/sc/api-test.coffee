module "SC.api"

test "_getAll() should do multiple .get calls with incremented offsets while returned array is not empty ", 5, ->
  i = 0
  expectCallAndStub SC, "get", 3, (path, query, callback) ->
    i++
    if i == 1
      equal(0, query.offset, "should pass offset=0 first time")
      callback([1,2,3], null)
    else if i == 2
      equal(50, query.offset, "should pass offset=50 2nd time")
      callback([4,5,6], null)
    else
      equal(100, query.offset, "should pass offset=100 3rd time")
      callback([])

  SC._getAll "/tracks", (comments) ->
    equal(comments.length, 6, "Should call callback with all 6 comments")







