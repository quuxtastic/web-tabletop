# browser ui framework

define 'ui',(exports) ->
  class Window
    constructor: (dlg_root,title,modal,buttons,pos,move,resize) ->
      @dlg=dlg_root.dialog
        autoOpen:false
        draggable:move?true
        resizable:resize?true
        title:title?''
        position:pos?'center'
        modal:modal?false
        buttons:buttons?{}

    open: ->
      @dlg.dialog 'open'

    close: ->
      @dlg.dialog 'close'

    show: ->
      @dlg.dialog 'show'

    hide: ->
      @dlg.dialog 'hide'

    set_elem: (selector,value) ->
      @dlg.find(selector).val value

    set_title: (title) ->
      @dlg.dialog 'option','title',title

  exports.create_dialog=(dlg,modal,callback) ->
    buttons={}
    for cmd of dlg.commands
      buttons[cmd.display]= -> callback cmd
    return new Window dlg.dom,dlg.title,modal,buttons

  exports.show_dialog=(dlg,modal,callback) ->
    w=exports.create_dialog(dlg,modal,callback)
    w.open()
    return w

