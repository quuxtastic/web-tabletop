# browser ui framework

define 'ui',(exports) ->
  class Widget
    constructor: (@_root) ->

    get: (name) -> return @_root.find('[name="'+name+'"]').val()
    set: (name,text) -> @_root.find('[name="'+name+'"]').val text

    get_any: (selector) -> return @_root.find selector
    set_any: (selector,src) -> return @_root.find(selector).html src

    show: -> @_root.show()
    hide: -> @_root.hide()

  class Dialog extends Widget
    constructor: (src,title,modal,commands) ->
      cmd_wrappers={}
      for disp,func of commands
        cmd_wrappers[disp]= => func this,disp

      super $('<div title="'+title+'"></div>').html src
      @_root.dialog
        autoOpen:false
        resizable:false
        modal:modal
        buttons:cmd_wrappers

    open: -> @_root.dialog 'open'
    close: -> @_root.dialog 'close'
    show: -> @_root.dialog 'show'
    hide: -> @_root.dialog 'hide'

    set_title: (title) -> @_root.dialog 'option','title',title

  class FeedbackDialog extends Dialog
    constructor: (args...) -> super args...

    set_error: (value) ->
      @set_any 'span[name="status-text"]',value
      @get_any('div.ui-state-error').show()
    clear_error: ->
      @get_any('div.ui-state-error').hide()

  ALERT_DIALOG="""
    <div class="ui-widget">
      <div class="ui-state-info ui-corner-all">
        <p>
          <span class="ui-icon ui-icon-info"
            style="float:left;margin-right:.3em;"></span>
          <span name="dlg-text"></span>
        </p>
      </div>
    </div>
  """

  exports.dialog=(source,title,modal,auto_open,handlers) ->
    d=new Dialog source,title,modal,handlers
    d.open() if auto_open
    return d

  exports.feedback_dialog=(source,title,modal,auto_open,handlers) ->
    d=new FeedbackDialog source,title,modal,handlers
    d.open() if auto_open
    return d

  exports.alert=(text,title='Alert',on_close) ->
    d=exports.dialog ALERT_DIALOG,title,true,false,
      "OK": (me,disp) ->
        me.close()
        on_close?(me,disp)
    d.set 'dlg-text',text
    d.open()
    return d

  exports.confirm=(text,title='Confirmation',handler) ->
    d=exports.dialog ALERT_DIALOG,title,true,false,
      "OK": (me,disp) ->
        me.close()
        handler true,me,disp
      "Cancel": (me,disp) ->
        me.close()
        handler false,me,disp
    d.set 'dlg-text',text
    d.open()
    return d

