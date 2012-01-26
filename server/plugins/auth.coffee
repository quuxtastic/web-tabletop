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

get_user=(name) -> return users[name]

get_user_by_key=(key) ->
  return if keys[key]? then users[keys[key].username] else null

get_keys_by_user=(username) ->
  out=[]
  for key,data of keys
    out.push key if data.username==username

add_session=(username) ->
  session_data=
    username:username
    timestamp:Date.now()
  key=make_session_key username
  keys[key]=session_data

  return [session_data,key]

remove_session=(key) -> delete keys[key]

get_session=(key) -> return keys[key]

reap_keys= ->
  for key,data of keys
    delete keys[key] if Date.now()-data.timestamp > TIMEOUT

exports.add_user=(name,password,admin) ->
  users[name]=
    password:password
    admin:admin

exports.remove_user=(name) -> delete users[name]

do_verify=(q) ->
  if not q.auth_key?
    return [null,'Requires authentication key']

  session=get_session q.auth_key
  if not session?
    return [null,'Bad key']
  if (Date.now()-session.timestamp)>TIMEOUT
    return [null,'Session timed out']

  if not get_user(session.username)?
    return [null,'No user for session']

  return [session.username]

exports.verify=(req,res,callback) ->
  q=(url.parse req.url,true).query
  [success,error_text]=do_verify q
  if success?
    callback req,res,success
  else
    response.unauthorized req,res,error_text

exports.verify_admin=(req,res,callback) ->
  exports.verify req,res,(req,res,username) ->
    if not get_user(username).admin
      response.forbidden req,res,'Not an admin'
    else
      callback req,res,username

exports.verify_stream_handshake=(auth,callback) ->
  [success,error_text]=do_verify auth.query
  if success?
    callback null,true
  else
    callback error_text

exports.verify_stream_handshake_admin=(auth,callback) ->
  [success,error_text]=do_verify auth.query
  if success?
    if not get_user(success).admin
      callback 'Not an admin'
     else
       callback null,true
  else
    callback error_text

exports.handle_login=(req,res,query) ->
  if not query? or not query.username? or not query.password?
    response.bad_request req,res,'Requires username and password'
    return

  user=get_user query.username
  if not user?
    response.json req,res,[false,'Unknown user '+query.username]
    return

  if query.password!=user.password
    response.json req,res,[false,'Invalid password']
    return

  [session_data,key]=add_session query.username
  log.log query.username+' logged in - session '+key

  response.json req,res,[true,key]

exports.handle_logout=(req,res,query) ->
  if not query? or not query.auth_key?
    response.bad_request req,res,'Requires authentication key'
    return

  delete keys[query.auth_key]
  response.ok req,res

exports.handle_ping=(req,res,query) ->
  if not query? or not query.auth_key?
    response.bad_request req,res,'Requires authentication key'
  [success,error_text]=do_verify query
  if success?
    # save our session keys
    get_session(query.auth_key).timestamp=Date.now()
    response.json req,res,[true,query.auth_key]
  else
    response.json req,res,[false,error_text]

for username,cfg of conf.users
  exports.add_user username,cfg.password,cfg.admin

