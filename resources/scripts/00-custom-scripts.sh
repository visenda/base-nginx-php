#!/bin/bash

echo "Adding custom scripts  ..."
if [ -d "$CUSTOM_SCRIPTS_DIR" ]; then
    /bin/cp -f $CUSTOM_SCRIPTS_DIR/*.sh $SCRIPTS_DIR
    chmod +x $SCRIPTS_DIR/*
fi