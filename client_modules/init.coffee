# client app initialization

app_post_init_callbacks=[]
window.on_app_post_init=(callback) ->
  app_post_init_callbacks.push callback

$ ->
  $.getJSON 'api/modlist',(modules) ->
    require modules...,->
      for callback in app_post_init_callbacks
        callback()

