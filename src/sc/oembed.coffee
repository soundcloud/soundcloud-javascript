window.SC = SC.Helper.merge SC || {},
  oEmbed: (trackUrl, query, callback) ->
    # optional query
    if !callback?
      callback = query
      query = undefined
    query ||= {}
    query.url = trackUrl

    uri = new SC.URI("http://" + SC.hostname() + "/oembed.json")
    uri.query = query

    # rewrite callback if it's a DOM
    if callback.nodeType != undefined && callback.nodeType == 1
       element = callback;
       callback = (oembed) =>
         element.innerHTML = oembed.html

    @._request "GET", uri.toString(), null, null, (responseText, xhr) ->
      response = SC.Helper.responseHandler(responseText, xhr)
      callback(response.json, response.error)
