# server communication

define 'server','auth',(exports,auth) ->
  exports.request=(name,q_args=null,callback) ->
    $.ajax
      url:'api/'+name
      dataType:'json'
      data:q_args
      success:callback
      error:(xhr,text_status,err) ->
        callback null,text_status

  exports.request_auth=(name,q_args=null,callback) ->
    auth.login (username,key) ->
      q_args=q_args ? {}
      q_args.auth_key = key
      exports.request name,q_args,callback

  class Socket
    constructor: (@_socket) ->

    send: (msgtype,data) -> @_socket.emit msgtype,data
    on: (msgtype,callback) -> @_socket.on msgtype,callback

    close: -> @_socket.disconnect()

  exports.connect=(channel,callback) ->
    exports.request 'socket_channel/'+channel, (data,error_status) ->
      if data?
        if data.auth_required
          auth.login (username,key) ->
            callback new Socket io.connect data.url+'?auth_key='+key
        else
          callback new Socket io.connect data.url

