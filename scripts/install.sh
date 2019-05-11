#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

MYSQL_CONFIG_PATH=/build/config/mysql

apt-get update

## Install MySQL and runit service
/build/services/mysql/mysql.sh

mkdir -p /config/etc/mysql/conf.d
cp ${MYSQL_CONFIG_PATH}/mysqld-skip-name-resolv.cnf /config/etc/mysql/conf.d/
cp ${MYSQL_CONFIG_PATH}/mysqld-bind-address.cnf /config/etc/mysql/conf.d/

mkdir -p /etc/my_init.d
cp /build/services/20-mysql.sh /etc/my_init.d
chmod 750 /etc/my_init.d/20-mysql.sh

cp /build/bin/mysql-systemd-unit /usr/local/bin
chmod 750 /usr/local/bin/mysql-systemd-unit
