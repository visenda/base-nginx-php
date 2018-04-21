#!/bin/bash

echo "Generating nginx config ..."
printf "\
worker_processes auto;
error_log /proc/self/fd/2 info;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;

    $([[ $NGINX_PROXY_FORWARD_HTTPS == 1 ]] && echo "\
    # Log the real ip instead of docker network ip
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';\
    ")

    access_log /proc/self/fd/1;
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

    $([[ $NGINX_PROXY_FORWARD_HTTPS == 1 ]] && echo "\
        # Redirect to https if behind proxy
        if (\$http_x_forwarded_proto != 'https') {
            return 301 https://\$host\$request_uri;
        }
        real_ip_header X-Forwarded-For;
        set_real_ip_from 172.16.0.0/12;\
    ")

        root $NGINX_WEBROOT;
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