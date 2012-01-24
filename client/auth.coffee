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
        dlg.set_status 'Login not implemented'

