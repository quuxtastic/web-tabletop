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

