#!/bin/bash

echo "Adding custom scripts  ..."
if [ -d "$WEBSERVER_SCRIPTS_DIR" ]; then
    /bin/cp -f $WEBSERVER_SCRIPTS_DIR/*.sh $SCRIPTS_DIR
    chmod +x $SCRIPTS_DIR/*
fi