#!/bin/bash

echo "Generating php config ..."
# general settings
printf "\
memory_limit = $PHP_MEMORY_LIMIT
post_max_size = $PHP_POST_MAX_SIZE
upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE
max_execution_time = $PHP_MAX_EXEC_TIME
access.log = /proc/self/fd/1
error_log = /proc/self/fd/2
log_errors = On
date.timezone = \"Europe/Berlin\"
opcache.memory_consumption = 192
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 8000
opcache.fast_shutdown = 1
opcache.enable_cli = 1
opcache.revalidate_freq = 0
" > /usr/local/etc/php/php.ini

# env dependent settings
if [ $APP_ENV == "prod" ]; then
printf "\
sendmail_path = /usr/bin/msmtp -t
display_errors = Off
zlib.output_compression = On
;cache needs to be invalidated: https://www.digitalocean.com/community/questions/configure-tune-opcache-on-php7
opcache.validate_timestamps = 0
" >> /usr/local/etc/php/php.ini
else
printf "\
sendmail_path = /usr/local/bin/fakemail
display_errors = On
zlib.output_compression = Off
" >> /usr/local/etc/php/php.ini
fi