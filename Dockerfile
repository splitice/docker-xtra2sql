FROM debian
MAINTAINER SplitIce mheard@x4b.net

RUN apt-get update; \
    apt-get install wget lsb-release  ; \
    wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb; \
    dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb; \
    percona-release enable-only tools release; \
    apt-get update; \
    apt-get -y install percona-xtrabackup
    
ADD restore.sh /opt/restore.sh

RUN chmod +x /opt/restore.sh

CMD ["/opt/restore.sh"]
