# main server

http=require 'http'
tty=require 'tty'
url=require 'url'
path=require 'path'
util=require 'util'
fs=require 'fs'

conf_path=path.join process.cwd(),'./conf/server-conf.json'
if process.argv[2]?
  conf_path=process.argv[2]

conf=require('module_conf').load(conf_path)
log=require 'log'

# add hook to get at server requests and post-startup initialization
server_request_callbacks=[]
global.on_server_request=(callback) ->
  server_request_callbacks.push callback
server_post_init_callbacks=[]
global.on_server_post_init=(callback) ->
  server_post_init_callbacks.push callback

# initialize all modules
for modname,modconf of conf.plugins
  p=path.join process.cwd(),conf.plugin_root,modname
  obj=require path.join process.cwd(),conf.plugin_root,modname
  log.log 'Loaded plugin '+modname

# start our server
server=http.createServer (req,res) ->
  for f in server_request_callbacks
    f req,res
server.listen conf.listen_port,conf.listen_addr

# post-server startup hooks
for f in server_post_init_callbacks
  f server

log.log 'Listening on '+conf.listen_addr+':'+conf.listen_port+' in '+process.cwd()
process.on 'exit', ->
  log.log 'Stopped'
  log.close()

# terminate on Ctrl-C if user wants
if tty.isatty process.stdin and conf.grab_tty
  console.log 'Terminate with Ctrl-C'
  process.stdin.resume()
  tty.setRawMode true
  process.stdin.on 'keypress',(c,k) ->
    if k and k.ctrl and k.name=='c'
      process.exit(0)

