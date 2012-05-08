module "SC.dialog"

asyncTest "Echo Dialog should immediatly return with passed options", 1, ->
  testOptions = {hello: "world"}
  SC.initialize
    redirect_uri: "/test/fixtures/callback.html"
  SC.dialog SC.Dialog.ECHO, testOptions, (options) ->
    expected = SC.Helper.merge testOptions,
      redirect_uri: SC.options.redirect_uri
    deepEqual(options, expected)
    start()

module "SC.Dialog._generateDialogId"
test "should be recognized by _isDialogId", 1, ->
  name = SC.Dialog._generateDialogId()
  ok SC.Dialog._isDialogId(name), "recognized"

module "SC.Dialog._getDialogIdFromWindow()"
test "should extract the id out of the state param", 1, ->
  id = SC.Dialog._generateDialogId()
  win =
    location: "http://somewhere.com/?state=#{id}"
  equal SC.Dialog._getDialogIdFromWindow(win), id

module "SC.Dialog.buildUrlForDialog"
test "should build the correct url for echo dialog", 1, ->
  url = SC.Dialog.buildUrlForDialog(SC.Dialog.ECHO, {})
  ok url.match(SC._dialogsPath + "/echo/#redirect_uri=%2Fexamples%2Fcallback.html")

test "should build the correct url for connect dialog", 1, ->
  equal SC.Dialog.buildUrlForDialog(SC.Dialog.CONNECT, {}), "https://soundcloud.com/connect?redirect_uri=%2Fexamples%2Fcallback.html"
