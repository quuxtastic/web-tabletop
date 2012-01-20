# client-side authorization UI

define 'auth','resource','ui',(exports,res,ui) ->
  logon_callbacks=[]
  logout_callbacks=[]
  exports.on_logon=(callback) ->
    logon_callbacks.push callback
  exports.on_logout=(callback) ->
    logout_callbacks.push callback

  logged_in=false

  # initial startup
  $ ->
    res.fetch_dialog 'auth/login',(dlg_obj) ->
      auth_dlg=ui.show_dialog dlg_obj,true,(cmd) ->
        if cmd=='login'
          #TODO: here we would ask the server to help us log the person in
          # currently, just assume login failed
          auth_dlg.set_elem 'status','Failed to log in'

