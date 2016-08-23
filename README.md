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

### Development Environment
using VirtualBox & Ubuntu Cloud Image (Mac & Windows)

**Install Tools**

* [VirtualBox][virtualbox] 4.3.10 or greater
* [Vagrant][vagrant] 1.6 or greater
* [Cygwin][cygwin] (if using Windows)

Install `vagrant-vbguest` plugin to auto install VirtualBox Guest Addition to virtual machine.
```
vagrant plugin install vagrant-vbguest
```

[virtualbox]: https://www.virtualbox.org/
[vagrant]: https://www.vagrantup.com/downloads.html
[cygwin]: https://cygwin.com/install.html

**Clone this project**

```
git clone https://github.com/madharjan/docker-mysql
cd docker-mysql
```

**Startup Ubuntu VM on VirtualBox**

```
vagrant up
```

**Build Container**

```
# login to DockerHub
vagrant ssh -c "docker login"  

# build
vagrant ssh -c "cd /vagrant; make"

# test
vagrant ssh -c "cd /vagrant; make test"

# tag
vagrant ssh -c "cd /vagrant; make tag_latest"

# update Makefile & Changelog.md
# release
vagrant ssh -c "cd /vagrant; make release"
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
  -e MYSQL_DB_NAME=mydb \
  -e MYSQL_DB_USERNAME=user \
  -e MYSQL_DB_PASSWORD=pass \
  -p 3306:3306 \
  -v /opt/docker/mysql/etc/conf.d:/etc/mysql/conf.d \
  -v /opt/docker/mysql/lib:/var/lib/mysql \
  -v /opt/docker/mysql/log:/var/log/mysql \
  --name mysql \
  madharjan/docker-mysql:5.5 /sbin/my_init
```

**Restart `mysql`** (runit service)
```
docker exec -t \
  mysql \
  /bin/bash -c "/usr/bin/sv stop mysql; sleep 1; /usr/bin/sv start mysql;"
```
