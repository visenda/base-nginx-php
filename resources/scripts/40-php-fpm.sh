#!/bin/bash

echo "Generating php-fpm config ..."
printf "\
[global]
error_log = /proc/self/fd/2
[www]
access.log = /proc/self/fd/1
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