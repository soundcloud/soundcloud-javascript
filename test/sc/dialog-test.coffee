module "SC.Dialog.AbstractDialog"

test "#generateId should generate a DialogId", ->
  dlg = new SC.Dialog.AbstractDialog()
  ok SC.Dialog._isDialogId(dlg.generateId()), "DialogId was recognized"


test "#buildUri should return a URI object", ->
  dlg = new SC.Dialog.AbstractDialog()
  equal dlg.buildURI().constructor, SC.URI, "returns SC.URI object"


module "SC.Dialog.ConnectDialog"
test "#buildUri should return URI to connect screen", ->
  dlg = new SC.Dialog.ConnectDialog
    redirect_uri: SC.options.redirect_uri
  dlg.id = ""
  url = dlg.buildURI().toString()
  equal url, "https://soundcloud.com/connect?state=&redirect_uri=%2Fexamples%2Fcallback.html"


module "SC.Dialog.EchoDialog"
test "#buildUri should return URI to echo screen", ->
  dlg = new SC.Dialog.EchoDialog
    redirect_uri: SC.options.redirect_uri
  dlg.id = ""
  url = dlg.buildURI().toString()
  ok url.match(SC._dialogsPath + "/echo/#state=&redirect_uri=%2Fexamples%2Fcallback.html")


module "SC.dialog"

#asyncTest "Echo Dialog should immediatly return with passed options", 1, ->
#  testOptions = {hello: "world"}
#  SC.initialize
#    redirect_uri: "/test/fixtures/callback.html"
#  SC.dialog SC.Dialog.ECHO, testOptions, (options) ->
#    expected = SC.Helper.merge testOptions,
#      redirect_uri: SC.options.redirect_uri
#    deepEqual(options, expected)
#    start()

module "SC.Dialog._getDialogIdFromWindow()"
test "should extract the id out of the state param", 1, ->
  dlg = new SC.Dialog.AbstractDialog()
  win =
    location: "http://somewhere.com/?state=#{dlg.id}"
  equal SC.Dialog._getDialogIdFromWindow(win), dlg.id
