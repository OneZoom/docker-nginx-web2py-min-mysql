#!/bin/bash

set -e

if [ "${DEBUG}" = true ]; then
  set -x
fi

MYSQL_DATABASE=${MYSQL_DATABASE:-temp}
MYSQL_USERNAME=${MYSQL_USERNAME:-mysql}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-mysql}

MYSQL_CHARSET=${MYSQL_CHARSET:-utf8}
MYSQL_COLLATION=${MYSQL_COLLATION:-utf8_unicode_ci}

MYSQL_USER=mysql
MYSQL_DATA_DIR=${MYSQL_DATA_DIR:-/var/lib/mysql}
MYSQL_LOG_DIR=/var/log/mysql/
MYSQL_RUN_DIR=/var/run/mysqld/

mkdir -p ${MYSQL_DATA_DIR}
chmod -R 0700 ${MYSQL_DATA_DIR}
chown -R ${MYSQL_USER}:${MYSQL_USER} ${MYSQL_DATA_DIR}

mkdir -p ${MYSQL_RUN_DIR}
chmod -R 0755 ${MYSQL_RUN_DIR}
chown -R ${MYSQL_USER}:root ${MYSQL_RUN_DIR}

mkdir -p ${MYSQL_LOG_DIR}
chmod -R 0755 ${MYSQL_LOG_DIR}
chown -R ${MYSQL_USER}:root ${MYSQL_LOG_DIR}

DISABLE_MYSQL=${DISABLE_MYSQL:-0}

if [ ! "${DISABLE_MYSQL}" -eq 0 ]; then
  touch /etc/service/mysql/down
else
  rm -f /etc/service/mysql/down
fi

sed -i -e '/bind-address/d' /etc/mysql/mysql.conf.d/mysqld.cnf
if [ -f "/etc/mysql/conf.d/mysqld-skip-name-resolv.cnf" ]; then
  echo "mysqld-skip-name-resolv.cnf already exists"
else 
  cp /config/etc/mysql/conf.d/mysqld-skip-name-resolv.cnf /etc/mysql/conf.d/mysqld-skip-name-resolv.cnf
fi

if [ -f "/etc/mysql/conf.d/mysqld-bind-address.cnf" ]; then
  echo "mysqld-bind-address.cnf already exists"
else
  cp /config/etc/mysql/conf.d/mysqld-bind-address.cnf /etc/mysql/conf.d/mysqld-bind-address.cnf
fi

# Blank password for debian-sys-maint user
sed 's/password = .*/password =  /g' -i /etc/mysql/debian.cnf

if [ ! -d ${MYSQL_DATA_DIR}/mysql ]; then
  echo "Initializing database ..."
  mysqld --initialize-insecure --user=${MYSQL_USER} 
  echo "Starting MySQL Server ..."
  /usr/bin/mysqld_safe >/dev/null 2>&1 &

  timeout=30
  echo -n "Waiting for database server to accept connections"
  while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
  do
    timeout=$(($timout - 1))
    if [ $timeout -eq 0 ]; then
      echo -e "\nCould not connect to database server. Aborting..."
      exit 1
    fi
    echo -n "."
    sleep 1
  done
  echo

  echo "Creating debian-sys-maint user ..."
  mysql -uroot -e "CREATE USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '';"
  mysql -uroot -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' WITH GRANT OPTION;"

  /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
fi

if [ -n "${MYSQL_DATABASE}" -o -n "${MYSQL_USERNAME}" ]; then
  echo "Starting MySQL Server ..."
  /usr/bin/mysqld_safe >/dev/null 2>&1 &

  timeout=30
  echo -n "Waiting for database server to accept connections"
  while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
  do
    timeout=$(($timout - 1))
    if [ $timeout -eq 0 ]; then
      echo -e "\nCould not connect to database server. Aborting..."
      exit 1
    fi
  done
  echo

  if [ -n "${MYSQL_DATABASE}" ]; then
    echo "Creating database ..."
    mysql --defaults-file=/etc/mysql/debian.cnf \
      -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` DEFAULT CHARACTER SET \`${MYSQL_CHARSET}\` COLLATE \`${MYSQL_COLLATION}\`;"

    if [ -n "${MYSQL_USERNAME}" ]; then
      echo "Granting access to database \"${MYSQL_DATABASE}\" for user \"${MYSQL_USERNAME}\"..."
      mysql --defaults-file=/etc/mysql/debian.cnf \
        -e "CREATE USER '${MYSQL_USERNAME}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
      mysql --defaults-file=/etc/mysql/debian.cnf \
        -e "GRANT ALL PRIVILEGES on \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USERNAME}'@'localhost';"
    fi
  fi

  /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
fi
