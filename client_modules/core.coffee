# core client-side javascript api
# must be loaded manually, because it contains the implementation of require()
# and define()

READY_CHECK_DELAY=100
LATEST_VERSION='latest'

window.mixin=(src,target,force) ->
  for prop of src
    if force or not target[prop]?
      target[prop]=src[prop]

  return target

window.is_func=(thing) ->
  Object.prototype.toString.call(thing) == '[object Function]';
window.is_array=(thing) ->
  Object.prototype.toString.call(thing) == '[object Array]';

load_script_tracker={}
load_script=(name,version,callback) ->
  # only load this script if we haven't already started
  if load_script_tracker[name]?
    if load_script_tracker[name][version]?
      return
    else
      load_script_tracker[name]={}
  else

  return if load_script_tracker[name]?[version]?
  load_script_tracker[name][version]=true

  tag=document.createElement 'script'
  tag.type='text/javascript'
  tag.charset='utf-8'
  tag.async=true
  tag.src='api/module/'+name+'/'+version

  onload=(evt) ->
    if evt.type=='load'
      evt.srcElement.removeEventListener 'load',onload,false
      console.log 'Loaded script '+tag.src
      callback name,version
  tag.attachEvent 'load',onload,false

  # go!
  document.getElementsByTagName('head')[0].appendChild tag

modules={}
find_module=(name,version) ->
  return null unless modules[name]?
  version=version ? LATEST_VERSION
  return modules[name][version]?

register_module=(name,version,module) ->
  modules[name][version]=module
  console.log 'Loaded module '+name+'-'+version

module_ready_check=(depends) ->
  depend_objs=[]
  ready=true
  for depend in depends
    module=null
    if is_array depend
      module=find_module depend...
    else
      module=find_module depend

    if not module? then ready=false else depend_objs.append module

  return [ready,depend_objs]

# each dependency can either be the string name of the module or an array
# with the module name and a desired version

window.define=(name,version,depends...,def_body) ->
  window.require depends...,(depend_objs)->
    exports={}
    module=(def_body exports,depends_objs...)()
    register_module name,version,mixin exports,module

window.require=(depends...,def_body) ->
  for depend in depends
    if is_array depend
      load_script depend...
    else
      load_script depend,LATEST_VERSION

  iid=null
  ready_interval= ->
    [ready,depend_objs]=module_ready_check depends
    if ready
      clearInterval iid
      def_body?(depend_objs...)
  iid=setInterval ready_interval,READY_CHECK_DELAY

# startup initialization
$.getJSON 'api/modlist',(modules) ->
  require modules...,->
    # allow jquery to fire DOM events now
    #$.ready true

