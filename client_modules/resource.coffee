# fetching certain types of common resources from the server

define 'resource',(exports) ->
  exports.fetch=(path,callback) ->
    content=$.getJSON '/api/resource/fetch/'+path,(content) ->
      callback content

  dlg_cache={}
  exports.fetch_dialog=(path,callback) ->
    if dlg_cache[path]?
      callback dlg_cache[path]
      return
    exports.fetch path,(content) ->
      dlgdata=
        title:content.title
        commands:content.commands
        dom:$('<div></div>').appendChild('#staging').html content.html
      dlg_cache[path]=dlgdata
      callback dlgdata

