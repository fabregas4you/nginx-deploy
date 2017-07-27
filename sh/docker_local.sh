#!/bin/bash

## parameter
CUSTCONF='customer.conf'
DEST_CUST='/opt/nginx/conf/customers'
MODSCONF='modsecurity_default.conf'
DEST_MODS='/opt/nginx/conf/modsecurity'
CERTS='ssl/certs/sample.crt'
KEYS='ssl/keys/sample.key'
DEST_CERTS='/opt/nginx/ssl/crt'
DEST_KEYS='/opt/nginx/ssl/key'
PKEY='ssh/id_rsa'
TARGETS=docker@localhost
SERVER=localhost
PORTS=20022
DIRS=/var/tmp
PROG="nginx"
EXEC="/opt/nginx/sbin/nginx"
daemon_options="/etc/sysconfig/${PROG}"
pidfile="/var/run/nginx.pid"

## copy files
copy_sslfiles () {
  cp $DIRS/`echo $CERTS |sed 's/\// /g' |awk '{print $3}'` $DEST_CERTS && \
  cp $DIRS/`echo $KEYS |sed 's/\// /g' |awk '{print $3}'` $DEST_KEYS
}
copy_modsecfile () {
  cp $DIRS/$MODSCONF $DEST_MODS
}
copy_custconf () {
  cp $DIRS/$CUSTCONF $DEST_CUST
}

## main

if [ `ls -l /var/tmp/sample.* 2>/dev/null | wc -l` -gt 2 ]; then
    echo "Config file not enough!"
  exit 1
else
  echo "Config files OK, Go head"
  copy_sslfiles && \
  copy_modsecfile && \
  copy_custconf && \
  /etc/init.d/nginx start
fi
