#

response=require 'response_helpers'

conf=require('module_conf').conf.plugins.auth

users={}

exports.add_user=(name,password,admin) ->

exports.remove_user=(name) ->

exports.verify=(req,res) ->

exports.verify_admin=(req,res) ->

exports.handle_login=(req,res,query) ->
  if not query.username? or not query.password?
    response.bad_request 'Requires username and password'
    return

  if not conf.users[query.username]?
    response.json [false,'Unknown user '+query.username]
    return

  if password!=conf.users[query.username].password
    response.json [false,'Invalid password']

  #

  response.json log_in username,password

exports.handle_logout=(req,res) ->

for username,cfg of conf.users
  exports.add_user username,cfg.password,cfg.admin
