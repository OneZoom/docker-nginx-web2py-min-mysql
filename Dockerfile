FROM madharjan/docker-base:14.04
MAINTAINER Madhav Raj Maharjan <madhav.maharjan@gmail.com>

LABEL description="Docker container for MySQL Server" os_version="Ubuntu 14.04"

ARG MYSQL_VERSION
ARG DEBUG=false

RUN mkdir -p /build
COPY . /build

RUN /build/scripts/install.sh && /build/scripts/cleanup.sh

VOLUME ["/etc/mysql/conf.d", "/var/lib/mysql", "/var/log/mysql"]

CMD ["/sbin/my_init"]

EXPOSE 3306
