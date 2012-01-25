# server communication

define 'server',(exports) ->
  exports.request=(name,q_args=null,callback) ->
    $.ajax
      url:'api/'+name
      dataType:'json'
      data:q_args
      success:callback
      error:(xhr,text_status,err) ->
        callback null,text_status

