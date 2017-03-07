# docker-mysql

[![](https://images.microbadger.com/badges/image/madharjan/docker-mysql.svg)](http://microbadger.com/images/madharjan/docker-mysql "Get your own image badge on microbadger.com")

Docker container for MySQL Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

**Features**
* Environment variables to create database, user and set password
* Bats ([sstephenson/bats](https://github.com/sstephenson/bats/)) based test cases

## MySQL Server 5.7 (docker-mysql)

| Variable        | Default      | Example        |
|-----------------|--------------|----------------|
| DISABLE_MYSQL   | 0            | 1 (to disable) |
| MYSQL_DATABASE  | temp         | mydb           |
| MYSQL_USERNAME  | mysql        | myuser         |
| MYSQL_PASSWORD  | mysql        | mypass         |

## Build

**Clone this project**
```
git clone https://github.com/madharjan/docker-mysql
cd docker-mysql
```

**Build Containers**
```
# login to DockerHub
docker login

# build
make

# test
make run
make tests
make clean

# tag
make tag_latest

# update Changelog.md
# release
make release
```

**Tag and Commit to Git**
```
git tag 5.5
git push origin 5.5
```

## Run Container

### MySQL

**Prepare folder on host for container volumes**
```
sudo mkdir -p /opt/docker/mysql/etc/conf.d
sudo mkdir -p /opt/docker/mysql/lib/
sudo mkdir -p /opt/docker/mysql/log/
```

**Run `docker-mysql`**
```
docker stop mysql
docker rm mysql

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

**Systemd Unit File**
```
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
ExecStartPre=-/usr/bin/docker pull madharjan/docker-mysql:5.5

ExecStart=/usr/bin/docker run \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USERNAME=user \
  -e MYSQL_PASSWORD=pass \
  -p 3306:3306 \
  -v /opt/docker/mysql/etc/conf.d:/etc/mysql/conf.d \
  -v /opt/docker/mysql/lib/:/var/lib \
  -v /opt/docker/mysql/log:/var/log/mysql \
  --name mysql \
  madharjan/docker-mysql:5.5

ExecStop=/usr/bin/docker stop -t 2 mysql

[Install]
WantedBy=multi-user.target
```
