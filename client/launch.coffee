# client module loader widget

define 'launch','ui','auth',(exports,ui,auth) ->
  DLG="""
    <p>
      <p style="text-align:center;">
        <input name="modname">
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

  LOAD_TIMEOUT=5000

  auth.on_login ->
    ui.feedback_dialog DLG,'Load Module',false,true,
      "Load": (me) ->
        me.set_error 'Loading '+me.get('modname')+'...'
        on_timeout= -> me.set_error 'Timed out :('
        errtimeout=setTimeout on_timeout,LOAD_TIMEOUT
        require me.get('modname'), ->
          clearTimeout errtimeout
          me.set_error 'Success!'

