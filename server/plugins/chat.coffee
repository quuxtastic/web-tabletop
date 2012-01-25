# server-side chat

socket_io=require 'socket.io'

conf=require('module_conf').conf.plugins.chat

clients={}

on_message=(text,socket) ->
  #out_text=''
  #last_index=0
  #while (m=text.match /\\(\d+)d(\d+)/)?
  #  out_text=out_text+text.slice(last_index,m.index-1)+m[0]+'&'+m[1]
  #  last_index=m.lastIndex
  exports.broadcast
    name:socket.handshake.name
    text:text

exports.create_room=(name) ->

exports.remove_room=(name) ->

exports.authorize=(name,password,admin) ->
  clients[name]=
    password:password
    admin:admin

exports.kick=(name) ->
  if clients[name].socket?
    clients[name].socket.close()
  clients[name]=null

exports.ban=(name) ->
  exports.kick name
  clients[name]=null

exports.allow_in_room=(name,room,allow) ->

exports.join=(name,room) ->

exports.leave=(name,room) ->

exports.broadcast=(msg) ->
  io.sockets.broadcast.emit msg

on_server_post_init (server) ->
  io=socket_io.listen server
  io.configure () ->
    io.set 'authorization',(auth,callback) ->
      if not auth.query.name?
        callback 'Missing user in query'
        return
      if not auth.query.passwd?
        callback 'Missing password in query'
        return
      if not clients[auth.query.name]?
        callback 'Unknown user '+auth.query.name
        return
      if clients[auth.query.name].password!=auth.query.passwd
        callback 'Bad password'
        return

      callback null,true

  io.sockets.on 'connection',(socket) ->
    clients[socket.handshake.name].socket=socket

    socket.on 'message' (text) ->
      on_message text,socket

    socket.on 'disconnect' ->
      clients[socket.handshake.name].socket=null

for username,info of conf.users
  exports.authorize username,info.password,info.admin
