#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" == true ]; then
  set -x
fi

MYSQL_CONFIG_PATH=/build/config/mysql

apt-get update

## Install MySQL and runit service
/build/services/mysql/mysql.sh

cp ${MYSQL_CONFIG_PATH}/mysqld-skip-name-resolv.cnf /etc/mysql/conf.d/
cp ${MYSQL_CONFIG_PATH}/mysqld-bind-address.cnf /etc/mysql/conf.d/

mkdir -p /etc/my_init.d
cp /build/services/mysql-startup.sh /etc/my_init.d
chmod 750 /etc/my_init.d/mysql-startup.sh
