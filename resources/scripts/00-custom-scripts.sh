#!/bin/bash

echo "Adding custom scripts  ..."
CUSTOM_SCRIPTS_DIR="$NGINX_WEBROOT/webserver-scripts"

if [ -d "$WEBSERVER_SCRIPTS_DIR" ]; then
    /bin/cp -f $WEBSERVER_SCRIPTS_DIR/*.sh $SCRIPTS_DIR
    chmod +x $SCRIPTS_DIR/*
fi