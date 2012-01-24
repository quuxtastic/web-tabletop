# browser ui framework

define 'ui',(exports) ->
  get_dialog_paths=(name) ->
    return ['/dlg/'+name+'.json','/dlg/'+name+'.html']

  class Dialog
    constructor: (dlg_root,modal=false,buttons={},pos='center',move=true,resize=true) ->
      @_dlg=dlg_root.dialog
        autoOpen:false
        draggable:move
        resizable:resize
        position:pos
        modal:modal
        buttons:buttons
      @_dlg.data 'parent',this

    open: ->
      @_dlg.dialog 'open'

    close: ->
      @_dlg.dialog 'close'

    show: ->
      @_dlg.dialog 'show'

    hide: ->
      @_dlg.dialog 'hide'

    set_status: (value) ->
      if value?
        @_dlg.find('span[name="status-text"]').html value
        @_dlg.find('div.ui-state-error').show()
      else
        @_dlg.find('div.ui-state-error').hide()

    set_title: (title) ->
      @_dlg.dialog 'option','title',title

  exports.create_dialog=(dlg_name,modal,handler,callback) ->
    [json,html]=get_dialog_paths dlg_name
    $.getJSON json,(dlg_info) ->
      buttons={}
      for cmd,display of dlg_info.commands
        buttons[display]= -> handler $(this).data('parent'),cmd

      dlg_dom=$('<div title="'+dlg_info.title+'"></div>')
      dlg_dom.load html, ->
        callback?(new Dialog dlg_dom,modal,buttons)

  exports.show_dialog=(dlg,modal,handler,callback) ->
    exports.create_dialog dlg,modal,handler,(w) ->
      w.open()
      callback?(w)

  class Canvas
    constructor: (title,w,h,pos='center') ->
      @_canvas=$('<canvas></canvas>').appendTo '#root'

