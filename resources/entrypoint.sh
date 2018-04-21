#!/bin/bash

for script in /scripts/*
do
  bash $script
done

# start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf