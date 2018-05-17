FROM mariadb:10.2

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
      curl \
      netcat \
      pigz \
      percona-toolkit \
      pv \
    && curl -sSL -o /tmp/qpress.tar http://www.quicklz.com/qpress-11-linux-x64.tar \
    && tar -C /usr/local/bin -xf /tmp/qpress.tar qpress \
    && chmod +x /usr/local/bin/qpress \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apt/lists/*

COPY conf.d/*                /etc/mysql/conf.d/
COPY *.sh                    /usr/local/bin/
COPY bin/galera-healthcheck  /usr/local/bin/galera-healthcheck
COPY primary-component.sql   /

#RUN echo "[mysqld]\n\
#innodb_large_prefix=true\n\
#innodb_file_format=barracuda\n\
#innodb_file_per_table=1" \
#>> /etc/mysql/my.cnf

# Fix permissions
RUN chown -R mysql:mysql /etc/mysql && chmod -R go-w /etc/mysql

EXPOSE 3306 4444 4567 4567/udp 4568 8080 8081

HEALTHCHECK CMD /usr/local/bin/healthcheck.sh

ENV SST_METHOD=xtrabackup-v2

ENTRYPOINT ["start.sh"]
