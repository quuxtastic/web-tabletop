# client-side chatbox

define 'chat','ui','auth',(exports,ui,auth) ->
  CHAT_DLG="""
    <p>
      <div name="chat-log" style="width:275px;height:150px;overflow:auto;"></div>
      <br>
      <textarea name="msg-input" rows="3" cols="20"></textarea>
    </p>
  """

  ENTER_KEY=13
  SHIFT_KEY=16

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
    recv_chat_message msg,auth.current_user()

  recv_chat_message=(msg,from) ->
    clr=if from==auth.current_user() then 'blue' else 'red'
    logbox.append('<p><b>'+from+'</b>&nbsp;'+msg+'</p>')
      .css 'color',clr
    logbox.scrollTop 9999999 # blarg

  auth.login (user) ->
    chat_dlg.open()

