FROM ubuntu:16.04
MAINTAINER krutpong "krutpong@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
ENV LANG en_US.UTF-8

#add Thailand repo
RUN echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial main restricted" > /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-updates main restricted" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial universe" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-updates universe" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial multiverse" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-updates multiverse" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-security main restricted" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-security universe" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-security multiverse" >> /etc/apt/sources.list && \
    apt-get update

ENV MEMCACHED_VERSION="1.5.7"

COPY entrypoint.sh /sbin/entrypoint.sh

RUN \
 BUILD_DEPS='curl gcc libc6-dev make libevent-dev' \
 && groupadd -r memcache && useradd -r -g memcache memcache \
 && set -x \
 && apt-get update && apt-get install -y --no-install-recommends ${BUILD_DEPS} libevent-2.0-5 \
 && curl -SL "http://memcached.org/files/memcached-${MEMCACHED_VERSION}.tar.gz" -o memcached.tar.gz \
 && mkdir -p /usr/src/memcached \
 && tar -xzf memcached.tar.gz -C /usr/src/memcached --strip-components=1 \
 && rm memcached.tar.gz \
 && cd /usr/src/memcached \
 && ./configure \
 && make \
 && make install \
 && cd / && rm -rf /usr/src/memcached \
 #&& sed 's/^-d/# -d/' -i /etc/memcached.conf \
 # Cleaning
 && apt-get purge -y --auto-remove ${BUILD_DEPS} \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && chmod 755 /sbin/entrypoint.sh

USER memcache
EXPOSE 11211
ENTRYPOINT ["/sbin/entrypoint.sh"]