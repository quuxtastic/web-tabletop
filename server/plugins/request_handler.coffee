# request handler registry

url=require 'url'
path=require 'path'

response=require 'response_helpers'
log=require 'log'

conf=require('module_conf').conf.plugins.request_handler

handlers={}

get_handler=(name) ->
  throw new Error('Unknown request handler '+name) unless handlers[name]?
  return handlers[name].func

default_handler=(req,res) ->
  response.not_found req,res

parse_handler_str=(str) ->
  parts=str.split ':'
  modname=parts[0]
  funcname='handle'
  args=[]
  if parts[1]?
    parts2=parts[1].split '?'
    funcname=parts2[0]
    if parts2[1]?
      args=parts2[1].split ','

  return {
    module:modname
    func:funcname
    args:args}

get_handler_method=(handler_str) ->
  info=parse_handler_str handler_str
  obj=require path.join process.cwd(),conf.handler_root,info.module
  if not obj[info.func]?
    throw new Error('Request handler '+modname+' has no '+funcname+' method')

  return (req,res,args...) -> obj[info.func] req,res,info.args...,args...

# pathname is just a regex that is matched to a server request
# handler is a string of this syntax:
# module_name[:function_name[?static[,arguments[,here]...]]]
# Order of arguments passed to the handler:
# request, response, static arguments..., regex capture groups...
exports.add=(pathname,handler) ->
  f=get_handler_method handler
  if handlers[pathname]?
    log.warn 'Overwriting request path '+pathname+' with '+handler
  handlers[pathname]=
    regex:new RegExp pathname
    func:f

exports.add_default=(handler) ->
  default_handler=get_handler_method handler

exports.remove=(pathname) ->
  handlers[pathname]=null

if conf.default_request?
  exports.add_default conf.default_request

for pathname,modname of conf.requests
  exports.add pathname,modname

global.on_server_request (req,res) ->
  log.log req.method+' '+req.url+' from '+req.socket.remoteAddress
  parsed_url=url.parse req.url,true
  for h of handlers
    match=handlers[h].regex.exec parsed_url.pathname
    if match
      # pass any captured matching groups to the handler
      # and pass the query arguments if they exist
      handlers[h].func req,res,(match[1...match.length])...,parsed_url.query
      return

  default_handler req,res

