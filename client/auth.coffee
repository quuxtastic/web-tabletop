# client-side authorization UI

define 'auth','ui',(exports,ui) ->
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

  STORAGE_LOGIN_INFO='web-tabletop-storage-login-data'
  SESSION_KEY='web-tabletop-session-key'
  SESSION_USER='web-tabletop-session-user-name'

  login_callbacks=[]
  on_login_success=(callback) ->
    login_callbacks.push callback

  do_login_success=(username,session_key) ->
    window.sessionStorage.setItem SESSION_KEY,session_key
    window.sessionStorage.setItem SESSION_USER,username
    for f in login_callbacks
      f username,session_key
    login_callbacks=[]

  show_login= ->
    login_dlg=ui.feedback_dialog LOGIN_DIALOG,'User Login',true,true,
      "Log In": ->
        # we can't use our server.request api here because the server module
        # depends on us
        $.ajax
          url:'api/login'
          dataType:'json'
          data:
            username:login_dlg.get 'username'
            password:login_dlg.get 'password'
          success:(res) ->
            if not res[0]
              login_dlg.set_error res[1]
            else
              login_dlg.close()
              #if login_dlg.get 'remember'
                #TODO: currently this is disabled
                #window.localStorage.setItem STORAGE_LOGIN_INFO
              do_login_success login_dlg.get('username'),res[1]

  trying_login=false
  exports.login=(callback) ->
    # do nothing if we are already logged in
    if window.sessionStorage.getItem SESSION_KEY
      callback?(window.sessionStorage.getItem(SESSION_USER),window.sessionStorage.getItem(SESSION_KEY))
      return

    on_login_success callback

    # don't try login routine if its already running
    if not trying_login
      trying_login=true

      # attempt to retrieve locally-saved login info if it exists
      k=window.localStorage.getItem STORAGE_LOGIN_INFO
      if k?
        params=JSON.parse k
        serv.request 'login',JSON.parse(k),(res) ->
          if not res[0]
            show_login()
          else
            do_login_success params.username,res[1]
      else
        show_login()

  exports.current_user= -> return window.sessionStorage.getItem SESSION_USER
  exports.session_key= -> return window.sessionStorage.getItem SESSION_KEY

