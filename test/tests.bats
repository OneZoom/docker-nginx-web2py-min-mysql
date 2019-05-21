@test "checking process: mysqld (enabled by default)" {
  run docker exec mysql /bin/bash -c "ps aux | grep -v grep | grep '/usr/sbin/mysqld'"
  [ "$status" -eq 0 ]
}

@test "checking process: mysqld (disabled by DISABLE_MYSQL)" {
  run docker exec mysql_no_mysql /bin/bash -c "ps aux | grep -v grep | grep '/usr/sbin/mysqld'"
  [ "$status" -eq 1 ]
}

@test "checking database: mysql (temp)" {
  run docker exec mysql_default /bin/bash -c "mysql -N -s -e 'SHOW DATABASES;' | grep temp"
  [ "$status" -eq 0 ]
}

@test "checking database: mysql (mydb)" {
  run docker exec mysql /bin/bash -c "mysql -N -s -e 'SHOW DATABASES;' | grep mydb"
  [ "$status" -eq 0 ]
}

@test "checking sql: mysql" {

  run docker exec mysql /bin/bash -c "mysql -N -s -e 'SHOW DATABASES;' | grep mydb"
  [ "$status" -eq 0 ]
  [ "$output" = "mydb" ]
}
