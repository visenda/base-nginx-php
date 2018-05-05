#!/bin/bash

echo "Generating SMTP config ..."
printf "\
account        default
host           $SMTP_HOSTNAME
port           $SMTP_PORT
from           $SMTP_FROM
user           $SMTP_USERNAME
password       $SMTP_PASSWORD
auth           $([[ $SMTP_AUTH == 1 ]] && echo "on" || echo "off")
tls            $([[ $SMTP_TLS == 1 ]] && echo "on" || echo "off")
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /proc/self/fd/1
" > /etc/msmtprc

# prepare fakemail dir if dev env
if [[ $APP_ENV != "prod" ]]; then
    mkdir -p $NGINX_WEBROOT/$APP_FAKEMAIL_DIR
    touch $NGINX_WEBROOT/$APP_FAKEMAIL_DIR/index.html
    chmod -R 777 $APP_FAKEMAIL_DIR
fi