FROM debian:jessie
MAINTAINER SplitIce mheard@x4b.net

RUN apt-get update; \
    apt-get -y install wget lsb-release gpgv gnupg2 coreutils rsync; \
    wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb; \
    dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb; \
    percona-release enable-only tools experimental; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive  apt-get -y install percona-xtrabackup mariadb-server mariadb-client qpress
    
ADD restore.sh /opt/restore.sh

RUN chmod +x /opt/restore.sh

CMD ["/opt/restore.sh"]
