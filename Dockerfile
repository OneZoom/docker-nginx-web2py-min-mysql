FROM madharjan/docker-base:14.04
MAINTAINER Madhav Raj Maharjan <madhav.maharjan@gmail.com>

LABEL description="Docker container for MySQL Server" os_version="Ubuntu 14.04"

ENV HOME /var/lib/mysql
ARG DEBUG=false

RUN mkdir -p /build
COPY . /build

RUN /build/scripts/install.sh && /build/scripts/cleanup.sh

VOLUME ["/etc/mysql/conf.d", "/var/lib/mysql", "/var/log/mysql"]

CMD ["/sbin/my_init"]

EXPOSE 3306
