# client-side authorization UI

define 'auth','ui','store',(exports,ui,store) ->
  LOGIN_DIALOG="""
    <p>
      <p style="text-align:center;">
        <label for="username">Username</label>
        <input name="username">
        <br>
        <label for="password">Password</label>
        <input name="password" type="password">
        <br><br>
        <label for="remember">Remember me</label>
        <input type="checkbox" name="remember">
      </p>
      <div class="ui-widget">
        <div class="ui-state-error ui-corner-all"
            style="margin-top:20px;padding:0 .7em;display:none;">
          <p>
            <span class="ui-icon ui-icon-alert"
              style="float:left;margin-right:.3em;"></span>
            <span name="status-text"></span>
          </p>
        </div>
      </div>
    </p>
  """

  login_callbacks=[]

  trying_login=false

  on_login_success=(callback) ->
    login_callbacks.push callback

  do_login_success=(username,session_key) ->
    store.session.put 'auth.key',session_key
    store.session.put 'auth.user',username
    for f in login_callbacks
      f username,session_key
    login_callbacks=[]
    trying_login=false

  show_login= ->
    login_dlg=ui.feedback_dialog LOGIN_DIALOG,'User Login',true,true,
      "Log In": ->
        # we can't use our server.request api here because the server module
        # depends on us
        login_info=
          username:login_dlg.get 'username'
          password:login_dlg.get 'password'
        remember=login_dlg.get_any('[name="remember"]:checked').val()=='on'
        $.ajax
          url:'api/login'
          dataType:'json'
          data:login_info
          success:(res) ->
            if not res[0]
              login_dlg.set_error res[1]
            else
              login_dlg.close()

              if remember
                console.log 'saved login info'
                store.local.put 'auth.login-info',login_info
              do_login_success login_info.username,res[1]

  exports.login=(callback) ->
    # do nothing if we are already logged in
    if store.session.get 'auth.key'
      callback?(store.session.get('auth.user'),store.session.get('auth.key'))
      return

    on_login_success callback

    # don't try login routine if its already running
    if not trying_login
      trying_login=true

      # attempt to retrieve locally-saved login info if it exists
      login_info=store.local.get 'auth.login-info'
      if login_info
        $.ajax
          url:'api/login'
          dataType:'json'
          data:login_info
          success:(res) ->
            if not res[0]
              # clear locally-saved login info
              store.local.remove 'auth.login-info'
              console.log 'cleared invalid login info'
              show_login()
            else
              do_login_success login_info.username,res[1]
      else
        show_login()

  exports.current_user= -> return store.session.get 'auth.user'
  exports.session_key= -> return store.session.get 'auth.key'

