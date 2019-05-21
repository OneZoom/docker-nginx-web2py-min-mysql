# docker-mysql

[![Build Status](https://travis-ci.com/madharjan/docker-mysql.svg?branch=master)](https://travis-ci.com/madharjan/docker-mysql)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-mysql.svg)](http://microbadger.com/images/madharjan/docker-mysql)

Docker container for MySQL Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Environment variables to create database, user and set password
* Bats [bats-core/bats-core](https://github.com/bats-core/bats-core) based test cases

## MySQL Server 5.7 (docker-mysql)

### Environment

| Variable        | Default      | Example        |
|-----------------|--------------|----------------|
| DISABLE_MYSQL   | 0            | 1 (to disable) |
| MYSQL_DATABASE  | temp         | mydb           |
| MYSQL_USERNAME  | mysql        | myuser         |
| MYSQL_PASSWORD  | mysql        | mypass         |

## Build

```bash
# clone project
git clone https://github.com/madharjan/docker-mysql
cd docker-mysql

# build
make

# tests
make run
make test

# clean
make clean
```

## Run

**Note**: update environment variables below as necessary

```bash
# prepare foldor on host for container volumes
sudo mkdir -p /opt/docker/mysql/etc/conf.d
sudo mkdir -p /opt/docker/mysql/lib/
sudo mkdir -p /opt/docker/mysql/log/

# stop & remove previous instances
docker stop mysql
docker rm mysql

# run container
docker run -d \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USERNAME=user \
  -e MYSQL_PASSWORD=pass \
  -p 3306:3306 \
  -v /opt/docker/mysql/etc/conf.d:/etc/mysql/conf.d \
  -v /opt/docker/mysql/lib:/var/lib/mysql \
  -v /opt/docker/mysql/log:/var/log/mysql \
  --name mysql \
  madharjan/docker-mysql:5.5
```

## Systemd Unit File

**Note**: update environment variables below as necessary

```txt
[Unit]
Description=MySQL Server

After=docker.service

[Service]
TimeoutStartSec=0

ExecStartPre=-/bin/mkdir -p /opt/docker/mysql/etc/conf.d
ExecStartPre=-/bin/mkdir -p /opt/docker/mysql/lib
ExecStartPre=-/bin/mkdir -p /opt/docker/mysql/log
ExecStartPre=-/usr/bin/docker stop mysql
ExecStartPre=-/usr/bin/docker rm mysql
ExecStartPre=-/usr/bin/docker pull madharjan/docker-mysql:5.7

ExecStart=/usr/bin/docker run \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USERNAME=user \
  -e MYSQL_PASSWORD=pass \
  -p 3306:3306 \
  -v /opt/docker/mysql/etc/conf.d:/etc/mysql/conf.d \
  -v /opt/docker/mysql/lib/:/var/lib/mysql \
  -v /opt/docker/mysql/log:/var/log/mysql \
  --name mysql \
  madharjan/docker-mysql:5.7

ExecStop=/usr/bin/docker stop -t 2 mysql

[Install]
WantedBy=multi-user.target
```

## Generate Systemd Unit File

| Variable            | Default          | Example                                                          |
|---------------------|------------------|------------------------------------------------------------------|
| PORT                | 3306             | 8080                                                             |
| VOLUME_HOME         | /opt/docker      | /opt/data                                                        |
| NAME                | mysql            | docker-mysql                                                           |
| MYSQL_DATABASE      | temp             | mydb                                                             |
| MYSQL_USERNAME      | mysql            | user                                                             |
| MYSQL_PASSWORD      | mysql            | pass                                                             |

```bash
# generate postgresql.service
docker run --rm \
  -e PORT=3306 \
  -e VOLUME_HOME=/opt/docker \
  -e NAME=docker-mysql \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USERNAME=user \
  -e MYSQL_PASSWORD=pass \
  madharjan/docker-mysql:5.7 \
  mysql-systemd-unit | \
  sudo tee /etc/systemd/system/mysql.service

sudo systemctl enable mysql
sudo systemctl start mysql
```
