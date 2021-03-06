# static file serving

fs=require 'fs'
path=require 'path'
url=require 'url'

response=require 'response_helpers'
mime=require 'mime_types'

conf=require('module_conf').conf.plugins.static

STATIC_FILE_ROOT=path.join process.cwd(),conf.content_root

forwards={}

exports.forward=(srcpath,destpath) ->
  forwards[srcpath]=destpath

exports.handle=(req,res) ->
  pathname=(url.parse req.url).pathname
  file_path=path.join STATIC_FILE_ROOT,forwards[pathname] ? pathname
  fs.stat file_path,(err,stats) ->
    unless err
      fs.readFile file_path,(err,data) ->
        unless err
          mime_type=mime.get_type_from_file file_path
          response.content req,res,data,mime_type,stats.size
        else
          response.error req,res,err
    else
      response.not_found req,res,err

for srcpath,destpath of conf.forwards
  exports.forward srcpath,destpath

