# core client-side javascript api
# must be loaded manually, because it contains the implementation of require()
# and define()

READY_CHECK_DELAY=100

load_script_tracker={}
load_script=(name,callback) ->
  # only load this script if we haven't already started
  if load_script_tracker[name]?
    return

  load_script_tracker[name]=true

  tag=document.createElement 'script'
  tag.type='text/javascript'
  tag.charset='utf-8'
  tag.async=true
  tag.src='api/module/'+name

  onload=(evt) ->
    if evt.type=='load'
      evt.srcElement.removeEventListener 'load',onload,false
      console.log 'Loaded script '+tag.src
      callback?(name,version)
  tag.addEventListener 'load',onload,false

  # go!
  document.getElementsByTagName('head')[0].appendChild tag

modules={}
find_module=(name) -> return modules[name] ? null

register_module=(name,module) ->
  modules[name]=module
  console.log 'Loaded module '+name

are_depends_ready=(depends) ->
  depend_objs=[]
  ready=true
  for depend in depends
    module=find_module depend
    if not module? then ready=false else depend_objs.push module

  return [ready,depend_objs]

window.define=(name,depends...,def_body) ->
  window.require depends...,(depend_objs...) ->
    exports={}
    def_body exports,depend_objs...
    register_module name,exports

window.require=(depends...,def_body) ->
  for depend in depends
    load_script depend

  iid=null
  ready_interval= ->
    [ready,depend_objs]=are_depends_ready depends
    if ready
      clearInterval iid
      def_body?(depend_objs...)
  iid=setInterval ready_interval,READY_CHECK_DELAY

# startup initialization
$.ajax
  url:'api/init_modules'
  dataType:'json'
  success:(modules) ->
    require modules..., ->
      console.log 'Starting GUI...'
      if $.holdReady?
        $.holdReady false
      else
        $.ready true
  error:(xhr,text_status,err) ->
    console.error 'Failed to get module init list:'
    console.error '\t'+text_status

