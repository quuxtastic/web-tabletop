# client-side authorization UI

define 'auth','server','ui',(exports,serv,ui) ->
  logon_callbacks=[]
  logout_callbacks=[]
  exports.on_login=(callback) ->
    logon_callbacks.push callback
  exports.on_logout=(callback) ->
    logout_callbacks.push callback

  LOGIN_DIALOG="""
    <p>
      <p style="text-align:center;">
        <input name="username">
        <br>
        <input name="password" type="password">
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

  # initial startup
  $ ->
    login_dlg=ui.feedback_dialog LOGIN_DIALOG,'User Login',true,true,
      "Log In": ->
        params=
          username:login_dlg.get 'username'
          password:login_dlg.get 'password'
        serv.request 'login',params,(res) ->
          if not res[0]
            login_dlg.set_error res[1]
          else
            login_dlg.close()
            for f in logon_callbacks
              f params.username

