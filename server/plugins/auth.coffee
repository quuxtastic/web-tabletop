# authentication

url=require 'url'
crypto=require 'crypto'

response=require 'response_helpers'
log=require 'log'

conf=require('module_conf').conf.plugins.auth

TIMEOUT=1000*60*60 # one hour

users={}
keys={}

make_session_key=(salt) ->
  hash=crypto.createHash 'md5'
  hash.update salt
  hash.update ''+Date.now()
  hash.update ''+Math.random()
  return hash.digest 'hex'

exports.add_user=(name,password,admin) ->
  users[name]=
    password:password
    admin:admin

exports.remove_user=(name) -> users[name]=null

do_verify=(q) ->
  if not q.auth_key? or not q.auth_user?
    return [false,'Requires authentication']
  if not keys[q.auth_user]?
    return [false,'Not logged in']
  if keys[q.auth_user].key!=q.auth_key
    return [false,'Bad key']
  if (Date.now()-keys[q.auth_user].timestamp)>TIMEOUT
    return [false,'Session timed out']

  return [true]

exports.verify=(req,res,callback) ->
  q=(url.parse req.url,true).query
  [success,error_text]=do_verify q
  if success
    callback req,res,q.auth_user
  else
    response.unauthorized req,res,error_text

exports.verify_admin=(req,res,callback) ->
  exports.verify req,res,(req,res,username) ->
    if not users[username].admin
      response.forbidden req,res,'Not an admin'
    else
      callback req,res,username

exports.verify_stream_handshake=(auth,callback) ->
  [success,error_text]=do_verify auth.query
  if success
    callback null,true
  else
    callback error_text

exports.verify_stream_handshake_admin=(auth,callback) ->
  [success,error_text]=do_verify auth.query
  if success
    if not users[auth.query.auth_user].admin
      callback 'Not an admin'
     else
       callback null,true
  else
    callback error_text

exports.handle_login=(req,res,query) ->
  if not query.username? or not query.password?
    response.bad_request req,res,'Requires username and password'
    return

  if not users[query.username]?
    response.json req,res,[false,'Unknown user '+query.username]
    return

  if query.password!=users[query.username].password
    response.json req,res,[false,'Invalid password']
    return

  if not keys[query.username]? or (Date.now()-keys[query.username].timestamp)>TIMEOUT
    new_key=
      timestamp:Date.now()
      key:make_session_key query.username
    keys[query.username]=new_key
    log.log query.username+' logged in - session '+new_key.key

  response.json req,res,[true,keys[query.username].key]

exports.handle_logout=(req,res) ->
  keys[username]=null
  response.ok req,res

for username,cfg of conf.users
  exports.add_user username,cfg.password,cfg.admin

