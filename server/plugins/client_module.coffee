# handler for client script requests

path=require 'path'
url=require 'url'
fs=require 'fs'
proc=require 'child_process'

response=require 'response_helpers'
log=require 'log'

conf=require('module_conf').conf.plugins.client_module

SRC_PATH=path.join process.cwd(),conf.module_root
OUT_PATH=path.join process.cwd(),conf.output_path
COFFEE_CMD=conf.coffee_shell? 'coffee'

exports.handle_mod_init=(req,res) ->
  response.json req,res,conf.init

exports.handle_module=(req,res,modname) ->
  compiled_path=path.join OUT_PATH,modname+'.js'
  src_path=path.join SRC_PATH,modname+'.coffee'

  fs.stat src_path,(err,src_stats) ->
    if err
      response.not_found req,res,src_path
      return

    fs.stat compiled_path,(err,comp_stats) ->
      if err or src_stats.mtime>comp_stats.mtime
        #console.info 'Recompiling '+src_path
        log.log 'Recompiling '+src_path
        cmd_str=COFFEE_CMD+' -co '+OUT_PATH+' '+src_path
        proc.exec cmd_str,(err,stdout,stderr) ->
          if err
            response.error req,res,[err,stdout,stderr]
            return
          fs.readFile compiled_path,(err,data) ->
            if err
              response.error req,res,err
              return
            response.content req,res,data,'text/javascript'
      else
        fs.readFile compiled_path,(err,data) ->
          if err
            response.error req,res,err
            return
          response.content req,res,data,'text/javascript'

