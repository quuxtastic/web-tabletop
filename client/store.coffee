# client-side storage

define 'store',(exports) ->
  STORAGE_PRE='web-tabletop-storage'

  exports.session=
    get: (key) ->
      s=window.sessionStorage.getItem STORAGE_PRE+'.'+key
      return if s? then JSON.parse(s) else null
    put: (key,data) ->
      window.sessionStorage.setItem STORAGE_PRE+'.'+key,JSON.stringify data
    remove: (key) ->
      window.sessionStorage.removeItem STORAGE_PRE+'.'+key

    clear: ->
      window.sessionStorage.clear()

  exports.local=
    get: (key) ->
      s=window.localStorage.getItem STORAGE_PRE+'.'+key
      return if s? then JSON.parse(s) else null
    put: (key,data) ->
      window.localStorage.setItem STORAGE_PRE+'.'+key,JSON.stringify data
    remove: (key) ->
      window.localStorage.removeItem STORAGE_PRE+'.'+key

