#!/bin/bash

set -e

if [ "${DEBUG}" == true ]; then
  set -x
fi

MYSQL_DATABASE=${MYSQL_DATABASE:-temp}
MYSQL_USERNAME=${MYSQL_DB_USERNAME:-mysql}
MYSQL_PASSWORD=${MYSQL_DB_PASSWORD:-mysql}

MYSQL_CHARSET=${MYSQL_CHARSET:-utf8}
MYSQL_COLLATION=${MYSQL_COLLATION:-utf8_unicode_ci}

MYSQL_USER=${MYSQL_USER:-mysql}
MYSQL_DATA_DIR=${MYSQL_DATA_DIR:-/var/lib/mysql}

mkdir -p ${MYSQL_DATA_DIR}
chmod -R 0700 ${MYSQL_DATA_DIR}
chown -R ${MYSQL_USER}:${MYSQL_USER} ${MYSQL_DATA_DIR}

# Blank password for debian-sys-maint user
sed 's/password = .*/password =  /g' -i /etc/mysql/debian.cnf

if [ ! -d ${MYSQL_DATA_DIR}/mysql ]; then
  echo "Initializing database ..."
  mysql_install_db --user=${MYSQL_USER} >/dev/null 2>&1
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

  echo "Creating debian-sys-maint user ..."
  mysql -uroot -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '' WITH GRANT OPTION;"

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
        -e "GRANT ALL PRIVILEGES on \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USERNAME}' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    fi
  fi

  /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
fi
