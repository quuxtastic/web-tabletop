#!/bin/bash

if [ -d "$WEB_TABLETOP_ROOT" ]; then
  cd $WEB_TABLETOP_ROOT
fi

if [ -e "$COFFEE" ]; then
  node $COFFEE server/server.coffee
else
  coffee server/server.coffee
fi

