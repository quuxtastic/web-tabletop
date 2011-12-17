# :mode=coffeescript:indentSize=2:noTabs=true:tabSize=2:
# main server

http=require 'http'
tty=require 'tty'
url=require 'url'
path=require 'path'
util=require 'util'
fs=require 'fs'

conf=require('module_conf').load('./server-conf.json')

# add hook to get at server requests and post-startup initialization
server_request_callbacks=[]
global.on_server_request=(callback) ->
  server_request_callbacks.push callback
server_post_init_callbacks=[]
global.on_server_post_init=(callback) ->
  server_post_init_callbacks.push callback

# initialize all modules
for modname,modconf of conf.modules
  obj=require modname

# start our server
server=http.createServer (req,res) ->
  for f in server_request_callbacks
    f req,res
server.listen conf.listen_port,conf.listen_addr

# post-server startup hooks
for f in server_post_init_callbacks
  f server

console.log 'Started listening on '+conf.listen_addr+':'+conf.listen_port
console.log 'In '+process.cwd()

# terminate on Ctrl-C if user wants
if tty.isatty process.stdin and conf.grab_tty
  console.log 'Terminate with Ctrl-C'
  process.stdin.resume()
  tty.setRawMode true
  process.stdin.on 'keypress',(c,k) ->
    if k and k.ctrl and k.name=='c'
      process.exit()

