# authentication

url=require 'url'

response=require 'response_helpers'

conf=require('module_conf').conf.plugins.auth

TIMEOUT=10000

users={}
keys={}

make_random_string=(bits) ->
  CHARS='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  s=''
  while bits>0
    r=Math.floor Math.random()*0x100000000
    i=26
    while i>0 and bits>0
      s+=CHARS[0x3f & r>>>i]
      i-=6
      bits-=6
  return s

exports.add_user=(name,password,admin) ->
  users[name]=
    password:password
    admin:admin

exports.remove_user=(name) -> users[name]=null

exports.verify=(req,res,callback) ->
  q=(url.parse req.url,true).query
  if not q.auth_key? or not q.auth_user
    response.unauthorized req,res,'Requires authentication key'
    return

  if not keys[q.auth_user]?
    response.unauthorized req,res,'Not logged in'
    return

  if not keys[q.auth_user].key!=q.auth_key
    response.unauthorized req,res,'Bad authentication key'
    return

  if keys[q.auth_user].timeout>Date.now()
    response.unauthorized req,res,'Session timed out'
    return

  callback req,res,q.auth_user

exports.verify_admin=(req,res,callback) ->
  exports.verify req,res,(req,res,username) ->
    if not users[username].admin
      response.forbidden req,res,'Not an admin'
    else
      callback req,res,username

exports.handle_login=(req,res,query) ->
  if not query.username? or not query.password?
    response.bad_request 'Requires username and password'
    return

  if not users[query.username]?
    response.json req,res,[false,'Unknown user '+query.username]
    return

  if query.password!=users[query.username].password
    response.json req,res,[false,'Invalid password']
    return

  if not keys[username]? or (keys[username].timeout>Date.now())
    keys[username]=
      timeout:Date.now()+TIMEOUT
      key:make_random_string 32

  response.json req,res,[true,keys[username].key]

exports.handle_logout=(req,res) ->
  keys[username]=null
  response.ok req,res

for username,cfg of conf.users
  exports.add_user username,cfg.password,cfg.admin

