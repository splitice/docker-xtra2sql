FROM debian
MAINTAINER SplitIce mheard@x4b.net

RUN apt-get update; \
    apt-get -y install wget lsb-release gpgv gnupg2 coreutils rsync qpress; \
    wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb; \
    dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb; \
    percona-release enable-only tools release; \
    apt-get update; \
    apt-get -y install percona-xtrabackup-80 mariadb-server mariadb-client
    
ADD restore.sh /opt/restore.sh

RUN chmod +x /opt/restore.sh

CMD ["/opt/restore.sh"]
