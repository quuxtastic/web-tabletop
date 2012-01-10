# core client-side javascript api
# must be loaded manually, because it contains the require() implementation

loaded_modules={}
load_module=(name,callback) ->
  if loaded_modules[name]?
    if loaded_modules[name].loaded
      callback()
    else
      loaded_modules[name].callbacks.push callback
  else
    loaded_modules[name]=
      loaded:false
      callbacks:[callback]
    $.getScript 'module?name='+name,->
      loaded_modules[name].loaded=true
      for callback in loaded_modules[name].callbacks
        callback()

window.require=(names...,callback) ->
  cnt=names.length
  for name in names
    load_module name,->
      cnt=cnt-1
      if cnt==0
        callback()

