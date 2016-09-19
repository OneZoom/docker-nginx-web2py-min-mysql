# docker-mysql
Docker container for MySQL Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

* MySQL Server 5.7 (docker-mysql)

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
make test

# tag
make tag_latest

# update Makefile & Changelog.md
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

**Run `docker-mysql` container**
```
docker run -d -t \
  --name mysql \
  madharjan/docker-mysql:5.5 /sbin/my_init
```

**Prepare folder on host for container volumes**
```
sudo mkdir -p /opt/docker/mysql/etc/conf.d
sudo mkdir -p /opt/docker/mysql/lib/
sudo mkdir -p /opt/docker/mysql/log/
```

**Copy default configuration to host**
```
sudo docker exec mysql tar Ccf /etc/mysql - conf.d | tar Cxf /opt/docker/mysql/etc -
```

**Run `docker-mysql` with updated configuration**
```
docker stop mysql
docker rm mysql

docker run -d -t \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USERNAME=user \
  -e MYSQL_PASSWORD=pass \
  -p 3306:3306 \
  -v /opt/docker/mysql/etc/conf.d:/etc/mysql/conf.d \
  -v /opt/docker/mysql/lib:/var/lib/mysql \
  -v /opt/docker/mysql/log:/var/log/mysql \
  --name mysql \
  madharjan/docker-mysql:5.5 /sbin/my_init
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
  -p 172.17.0.1:3306:3306 \
  -v /opt/docker/mysql/etc/conf.d:/etc/mysql/conf.d \
  -v /opt/docker/mysql/lib/:/var/lib \
  -v /opt/docker/mysql/log:/var/log/mysql \
  --name mysql \
  madharjan/docker-mysql:5.5 /sbin/my_init

ExecStop=/usr/bin/docker stop -t 2 nginx

[Install]
WantedBy=multi-user.target
```
