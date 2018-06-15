#!/bin/bash
mkdir -p /home/appbox/mysql/run
mkdir -p /home/appbox/mysql/data
mkdir -p /home/appbox/logs/mysql

touch /home/appbox/logs/mysql/error.log
rm -fr /etc/mysql/mysql.conf.d/mysqld.cnf
mv /sources/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
#mv /var/lib/mysql/* /home/appbox/mysql/

chmod 600 /etc/mysql/mysql.conf.d/mysqld.cnf
chown -R appbox:appbox /home/appbox

mysqld --initialize-insecure

DB_NAME=${DB_NAME:-""}
DB_USER=${DB_USER:-""}
DB_PASS=${DB_PASS:-""}

service mysql start
service mysql stop

mkdir -p /var/run/mysqld
touch /var/run/mysqld/mysqld.sock
chown -R appbox:appbox /var/run/mysqld

/usr/bin/mysqld_safe &
sleep 10

echo "Setting up root password."
mysqladmin -u root password ${MYSQL_ROOT_PASSWORD}

echo "Enable remote root login."
mysql --user=root --password=${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

if [ -n "$DB_NAME" ]; then
    echo "Adding new DB $DB_NAME"
    mysql --user=root --password=${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE $DB_NAME"
fi
if [ -n "$DB_USER" ]; then
    echo "Adding User $DB_USER"
    mysql --user=root --password=${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'; FLUSH PRIVILEGES;"
    mysql --user=root --password=${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS'; FLUSH PRIVILEGES;"
fi
if [ -n "$DB_NAME" ]; then
    mysql --user=root --password=${MYSQL_ROOT_PASSWORD} -e "select user, host FROM mysql.user;"
fi

pkill -9 mysql

#echo "Installing Database"
#mysql -u${DB_USER} -p${DB_PASS} ${DB_NAME} < /sources/dbsource.sql

cat << EOF >> /home/appbox/config/supervisor/conf.d/mysql.conf
[program:mysql]
command=/usr/sbin/mysqld --verbose=0 --socket=/run/mysqld/mysqld.sock
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


