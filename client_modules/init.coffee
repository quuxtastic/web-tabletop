# client app initialization

$ ->
  $.getJSON 'api/modlist',(modules) ->
    require modules...

