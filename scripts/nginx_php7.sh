#!/bin/bash

mkdir -p /home/appbox/config/nginx/sites-enabled
mkdir -p /home/appbox/config/nginx/modules-enabled
mkdir -p /home/appbox/config/php-fpm/pool.d
mkdir -p /home/appbox/logs/nginx
mkdir -p /home/appbox/public_html

# Move Sources
mv /sources/supervisord.conf /home/appbox/config/supervisor/supervisord.conf
mv /sources/nginx.conf /home/appbox/config/nginx/nginx.conf
mv /sources/default-site.conf /home/appbox/config/nginx/sites-enabled/default-site.conf
mv /sources/php-fpm.conf /home/appbox/config/php-fpm/php-fpm.conf
mv /sources/www.conf /home/appbox/config/php-fpm/pool.d/www.conf

# Copy NGINX fastcgi_params
cp /etc/nginx/fastcgi_params /home/appbox/config/nginx/fastcgi_params


# Install Nginx Supervisor Config
cat << EOF >> /home/appbox/config/supervisor/conf.d/nginx.conf
[program:nginx]
command=/usr/sbin/nginx -c /home/appbox/config/nginx/nginx.conf -g "daemon off;"
autostart=true
autorestart=true
priority=10
stdout_events_enabled=true
stderr_events_enabled=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF

# Install PHP-FPM Supervisor Config
cat << EOF >> /home/appbox/config/supervisor/conf.d/phpfpm.conf
[program:php-fpm]
command = /usr/sbin/php-fpm7.2 --nodaemonize --fpm-config /home/appbox/config/php-fpm/php-fpm.conf
autostart=true
autorestart=true
priority=5
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF