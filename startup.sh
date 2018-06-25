#!/bin/bash

echo "RUNNING..."

/var/config.sh


# Start supervisor
# /usr/local/bin/supervisord -n -c /etc/supervisord.conf

# start phpfpm
# service php7.0-fpm start


# Call parent entrypoint (CMD)
/sbin/my_init
