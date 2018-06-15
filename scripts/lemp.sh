#!/bin/bash

if [ ! -f /etc/lemp_configured ]; then
    # Create Directories
    mkdir -p /home/appbox/config
    mkdir -p /home/appbox/config/supervisor/conf.d

    /bin/sh /scripts/nginx_php7.sh

    /bin/sh /scripts/mysql.sh

    # Set Permissions
    chown -R appbox:appbox /home/appbox

    # Clean up.
    rm -fr /sources

    # Finish App install.
    if [ "${START_SUPERVISOR}" = true ]; then
        curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST "https://api.cylo.io/v1/apps/installed/$INSTANCE_ID"
    fi
    touch /etc/lemp_configured
fi

if [ "${START_SUPERVISOR}" = true ]; then
    # Start supervisord and services
    exec /usr/bin/supervisord -n -c /home/appbox/config/supervisor/supervisord.conf
fi