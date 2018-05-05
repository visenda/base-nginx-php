#!/bin/bash

# add custom project based scripts
if [[ -d "$NGINX_WEBROOT/$CUSTOM_SCRIPTS_DIR" ]]; then
    echo "Adding scripts from ${NGINX_WEBROOT}/${CUSTOM_SCRIPTS_DIR} ..."
    cp -f $NGINX_WEBROOT/$CUSTOM_SCRIPTS_DIR/*.sh $SCRIPTS_DIR
    chmod +x $SCRIPTS_DIR/*
fi

# execute all available scripts
for script in $SCRIPTS_DIR/*
do
    echo "+++ Executing ${script} +++"
    bash $script
    echo "+++ Finished executing +++"
    echo " "
done

# start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf