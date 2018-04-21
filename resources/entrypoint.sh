#!/bin/bash

for script in $SCRIPTS_DIR/*
do
  bash $script
done

# start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf