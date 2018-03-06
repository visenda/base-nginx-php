#!/bin/bash

# set default webroot
WEBROOT="/var/www/html"

# generate php config
echo "Generating php config ..."
printf "\
sendmail_path = $([ $APP_ENV == "prod" ] && echo "/usr/bin/msmtp -t" || echo "/usr/local/bin/fakemail")
display_errors = $([ $APP_ENV == "prod" ] && echo "Off" || echo "On")
memory_limit = $PHP_MEMORY_LIMIT
post_max_size = $PHP_POST_MAX_SIZE
upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE
max_execution_time = $PHP_MAX_EXEC_TIME
zlib.output_compression = On
error_log = /dev/stderr
log_errors = On
date.timezone = \"Europe/Berlin\"
" > /usr/local/etc/php/php.ini

# generate php-fpm config
echo "Generating php-fpm config ..."
printf "\
[global]
error_log = /dev/stderr
[www]
access.log = /dev/stdout
catch_workers_output = yes
user = nginx
group = nginx
listen = /var/run/php-fpm.sock
listen.mode = 0666
listen.owner = nginx
listen.group = nginx
clear_env = no
pm = $PHP_FPM_PM
pm.max_children = $PHP_FPM_PM_MAX_CHILDREN
pm.start_servers = $PHP_FPM_PM_START_SERVERS
pm.min_spare_servers = $PHP_FPM_PM_MIN_SPARE_SERVERS
pm.max_spare_servers = $PHP_FPM_PM_MAX_SPARE_SERVERS
pm.max_requests = $PHP_FPM_PM_MAX_REQUESTS
" > /usr/local/etc/php-fpm.conf

# generate smtp config if production
echo "Generating SMTP config ..."
printf "\
account        default
host           $SMTP_HOSTNAME
port           $SMTP_PORT
from           $SMTP_FROM
user           $SMTP_USERNAME
password       $SMTP_PASSWORD
auth           $([ $SMTP_AUTH == 1 ] && echo "on" || echo "off")
tls            $([ $SMTP_TLS == 1 ] && echo "on" || echo "off")
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /dev/stdout
" > /etc/msmtprc

# generate nginx config
echo "Generating nginx config ..."
printf "\
worker_processes auto;
error_log /dev/stderr info;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;

    $([ $PROXY_FORWARD_HTTPS == 1 ] && echo "\
    # Log the real ip instead of docker network ip
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';\
    ")

    access_log /dev/stdout;
    sendfile on;
    keepalive_timeout 2;
	client_max_body_size 100m;
    server_tokens off;

    upstream fastcgi_backend {
        server unix:/var/run/php-fpm.sock;
    }

    server {
        listen 80;
        server_name _;

    $([ $PROXY_FORWARD_HTTPS == 1 ] && echo "\
        # Redirect to https if behind proxy
        if (\$http_x_forwarded_proto != 'https') {
            return 301 https://\$host\$request_uri;
        }
        real_ip_header X-Forwarded-For;
        set_real_ip_from 172.16.0.0/12;\
    ")

        root $WEBROOT;
        index index.php;

        # PHP entry point for main application
        location ~ \.php\$ {
            try_files      \$uri =404;
            fastcgi_pass   fastcgi_backend;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }

        # Banned locations
        location ~* (\.ht|\.git) {
            deny all;
        }
    }
}
" > /etc/nginx/nginx.conf

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf
