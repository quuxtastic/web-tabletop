# :mode=coffeescript:indentSize=2:noTabs=true:tabSize=2:
# main server

http=require 'http'
tty=require 'tty'
url=require 'url'
path=require 'path'
util=require 'util'
fs=require 'fs'

request_handler=require 'request_handler'

conf=JSON.parse fs.readFileSync './server-conf.json','utf8'

request_handler.set_default 'static'
request_handler.get('static').forward '/','workspace.html'

server=http.createServer (req,res) ->
  request_handler.handle req,res
server.listen conf.port

console.log 'Started listening on 0.0.0.0:'+conf.port
console.log 'In '+process.cwd()

if tty.isatty process.stdin
  console.log 'Terminate with Ctrl-C'
  process.stdin.resume()
  tty.setRawMode true
  process.stdin.on 'keypress',(c,k) ->
    if k and k.ctrl and k.name=='c'
      process.exit()

