# server-side chat

socket_io=require 'socket.io'

conf=require('module_conf').conf.plugins.chat
auth=require('../plugins/auth')

io=null # hold onto our global object

connections={}

on_message=(user,text,socket) ->
  #TODO: this is where we would do server-side message processing
  exports.broadcast user,text

exports.broadcast=(origin,text) ->
  for user,data of connections
    if data?
      data.socket.emit 'chat',
        from:origin
        text:text

exports.broadcast_from_server=(text) ->
  for user,data of connections
    if data?
      data.socket.emit 'chat',
        text:text
        server:true

on_server_post_init (server) ->
  io=socket_io.listen server
  io.configure ->
    io.set 'authorization',auth.verify_stream_handshake

  io.sockets.on 'connection',(socket) ->
    username=socket.handshake.query.auth_user
    connections[username]=
      socket:socket

    exports.broadcast_from_server username+' connected'

    socket.on 'chat',(data) -> on_message username,data.text,socket
    socket.on 'disconnect', ->
      exports.broadcast_from_server username+' disconnected'
      delete connections[username]

for username,info of conf.users
  exports.authorize username,info.password,info.admin

