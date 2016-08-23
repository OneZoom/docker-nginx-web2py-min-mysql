#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "$DEBUG" == true ]; then
  set -x
fi

MYSQL_BUILD_PATH=/build/services/mysql

## Install MySQL Server
apt-get install -y --no-install-recommends mysql-server

rm -rf /var/lib/mysql
rm -f /etc/mysql/conf.d/mysqld_safe_syslog.cnf

mkdir -p /etc/service/mysql
cp ${MYSQL_BUILD_PATH}/mysql.runit /etc/service/mysql/run
chmod 750 /etc/service/mysql/run

## Configure logrotate
