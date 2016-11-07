FROM mariadb:10.1

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests curl git \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apt/lists/*

COPY conf.d/* /etc/mysql/conf.d/
COPY bin/galera-healthcheck /usr/local/bin/galera-healthcheck
COPY mysqld.sh /usr/local/bin/mysqld.sh
COPY bootstrap.sh /usr/local/bin/bootstrap.sh
COPY zabbix/zabbix.sh /usr/local/bin/zabbix.sh
COPY zabbix/zabbix-mariadb.sh /usr/local/bin/zabbix-mariadb.sh
COPY zabbix-backup/get-table-list.pl /usr/local/bin/get-table-list.pl
COPY zabbix-backup/zabbix-mysql-dump /usr/local/bin/zabbix-mysql-dump

# Add VOLUME to allow backup of data
VOLUME ["/var/lib/mysql"]

# Set TERM env to avoid mysql client error message "TERM environment variable not set" when running from inside the container
ENV TERM xterm

EXPOSE 3306 4444 4567 4567/udp 4568

HEALTHCHECK CMD curl -f -o - http://127.0.0.1:8080/ || exit 1

CMD ["/usr/local/bin/zabbix.sh"]
ENTRYPOINT ["bootstrap.sh"]

