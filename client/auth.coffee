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
        <input type="checkbox" name="remember" value="remember">
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

  KEY_REFRESH_TIMEOUT=1000*60 # one minute

  refresh_key=(callback) ->
    cur_key=store.session.get 'auth.key'
    if cur_key?
      $.ajax
        url:'api/auth/ping'
        dataType:'json'
        data:{auth_key:cur_key}
        success:(res) ->
          if res[0]
            store.session.put 'auth.key',res[1]
            callback?(true,res[1])
          else
            callback?(false,res[1])

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

    refresh_key_timeout= ->
      refresh_key (success) ->
        if success
          setTimeout refresh_key_timeout,KEY_REFRESH_TIMEOUT
    setTimeout refresh_key_timeout,KEY_REFRESH_TIMEOUT

  login_dlg=ui.feedback_dialog LOGIN_DIALOG,'User Login',true,false,
    "Log In": ->
      # we can't use our server.request api here because the server module
      # depends on us
      login_info=
        username:login_dlg.get 'username'
        password:login_dlg.get 'password'
      remember=login_dlg.get('remember')=='on'
      $.ajax
        url:'api/auth/login'
        dataType:'json'
        data:login_info
        success:(res) ->
          if not res[0]
            login_dlg.set_error res[1]
          else
            login_dlg.close()

            if remember
              store.local.put 'auth.login-info',login_info
            else
              store.local.remove 'auth.login-info'
            do_login_success login_info.username,res[1]

  show_login= -> login_dlg.open()

  try_login=(callback) ->
    on_login_success callback

    # don't try login routine if its already running
    if not trying_login
      trying_login=true

      # attempt to use locally-saved login info if it exists
      login_info=store.local.get 'auth.login-info'
      if login_info?
        $.ajax
          url:'api/auth/login'
          dataType:'json'
          data:login_info
          success:(res) ->
            if not res[0]
              show_login()
            else
              do_login_success login_info.username,res[1]
      else
        show_login()

  exports.login=(callback) ->
    # check our auth key
    cur_key=store.session.get 'auth.key'
    if cur_key?
      refresh_key (success,val) ->
        if success
          callback?(store.session.get('auth.user'),store.session.get('auth.key'))
        else
          try_login callback
    else
      try_login callback

  exports.logout=(callback) ->
    # we don't really care if the logout fails
    $.ajax
      url: 'api/auth/logout'
      dataType:'json'
      data:{auth_key:store.session.get('auth.key')}

    store.session.remove 'auth.user'
    store.session.remove 'auth.key'

  exports.current_user= -> return store.session.get 'auth.user'
  exports.session_key= -> return store.session.get 'auth.key'

