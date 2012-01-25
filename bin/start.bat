@echo off
setlocal

set SERVER=server/server.coffee

if defined WEB_TABLETOP_ROOT cd %WEB_TABLETOP_ROOT%
if defined %COFFEE% (node %COFFEE% %SERVER%) else coffee %SERVER%

