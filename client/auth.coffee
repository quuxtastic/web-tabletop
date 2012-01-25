# client-side authorization UI

define 'auth','ui',(exports,ui) ->
  logon_callbacks=[]
  logout_callbacks=[]
  exports.on_logon=(callback) ->
    logon_callbacks.push callback
  exports.on_logout=(callback) ->
    logout_callbacks.push callback

  # initial startup
  $ ->
    ui.show_dialog 'auth/login',true,(dlg,cmd) ->
      if cmd=='login'
        name=dlg.get_field 'username'
        password=dlg.get_field 'password'
        $.getJSON 'api/login?username='+name+'&password='+password, (res) ->
          if not res[0]
            dlg.set_status res[1]
          else
            dlg.close()

