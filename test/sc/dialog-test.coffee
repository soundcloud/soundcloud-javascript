module "SC.dialog"

asyncTest "Echo Dialog should immediatly return with passed options", 1, ->
  testOptions = {hello: "world"}
  SC.dialog SC.Dialog.ECHO, testOptions, (options) ->
    expected = SC.Helper.merge testOptions,
      redirect_uri: SC.options.redirect_uri
    deepEqual(options, expected)
    start()

module "SC.Dialog._generateWindowName"
test "should be recognized by _isDialogWindowName", 1, ->
  name = SC.Dialog._generateWindowName()
  ok SC.Dialog._isDialogWindowName(name), "recognized"

module "SC.Dialog.buildUrlForDialog"
test "should build the correct url for echo dialog", 1, ->
  equal SC.Dialog.buildUrlForDialog(SC.Dialog.ECHO, {}), "http://connect.soundcloud.dev" + SC._dialogsPath + "/echo#redirect_uri=%2Fexamples%2Fcallback.html"

test "should build the correct url for connect dialog", 1, ->
  equal SC.Dialog.buildUrlForDialog(SC.Dialog.CONNECT, {}), "https://soundcloud.com/connect?redirect_uri=%2Fexamples%2Fcallback.html"
