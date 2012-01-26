# client-side chatbox

define 'chat','ui','auth','store',(exports,ui,auth,store) ->
  CHAT_DLG="""
    <p>
      <div name="chat-log" style="width:275px;height:150px;overflow:auto;"></div>
      <br>
      <textarea name="msg-input" rows="3" cols="20"
        style="resize:none;"></textarea>
    </p>
  """

  ENTER_KEY=13
  SHIFT_KEY=16

  socket=null

  shift_is_down=false
  chat_dlg=ui.dialog CHAT_DLG,'Chat',false,false
  enterbox=chat_dlg.get_any '[name="msg-input"]'
  enterbox.keydown (evt) ->
    if evt.keyCode==ENTER_KEY and not shift_is_down
      evt.preventDefault()
      post_chat_message chat_dlg.get 'msg-input'
      enterbox.val ''
    if evt.keyCode==SHIFT_KEY
      shift_is_down=true
  enterbox.keyup (evt) ->
    if evt.keyCode==SHIFT_KEY
      shift_is_down=false

  logbox=chat_dlg.get_any '[name="chat-log"]'

  post_chat_message=(msg) ->
    socket.emit 'chat',
      text:msg

  recv_chat_message=(data) ->
    if data.server?
      logbox.append '<p><i>'+data.text+'</i></p>'
    else
      clr=if data.from==auth.current_user() then 'blue' else 'red'
      $('<p><b>'+data.from+'</b>&nbsp;'+data.text+'</p>')
        .css('color',clr)
        .appendTo logbox

    logbox.scrollTop 9999999 # blarg

  $ ->
    auth.login (user) ->
      chat_dlg.open()

      user=store.session.get 'auth.user'
      key=store.session.get 'auth.key'
      socket=io.connect('http://localhost?auth_user='+user+'&auth_key='+key)
        .on('chat',recv_chat_message)
        .on 'error', ->
          recv_chat_message
            server:true
            text:'Failed to connect to socket.io :('

