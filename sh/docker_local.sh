#!/bin/bash

## parameter
MAINCONF='conf/nginx.conf'
MAINDEST='/opt/nginx/conf'
UPSTREAMCONF='conf/upstreams_8080.conf'
UPSTREAMDEST='/opt/nginx/conf/upstreams'
CUSTCONF='conf/customer.conf'
DEST_CUST='/opt/nginx/conf/customers'
MODSCONF='conf/modsecurity_default.conf'
UNICODECONF='conf/unicode.mapping'
DEST_MODS='/opt/nginx/conf/modsecurity'
CERTS='ssl/certs/sample.crt'
KEYS='ssl/keys/sample.key'
DEST_CERTS='/opt/nginx/ssl/crt'
DEST_KEYS='/opt/nginx/ssl/key'
PKEY='ssh/id_rsa'
TARGETS=docker@localhost
SERVER=localhost
PORTS=20022
WEBPORTS=8080
DIRS=/var/tmp
PROG="nginx"
EXEC="/opt/nginx/sbin/nginx"
daemon_options="/etc/sysconfig/${PROG}"
pidfile="/var/run/nginx.pid"

## copy files
copy_sslfiles () {
  cp -f $DIRS/`echo $CERTS |sed 's/\// /g' |awk '{print $3}'` $DEST_CERTS && \
  cp -f $DIRS/`echo $KEYS |sed 's/\// /g' |awk '{print $3}'` $DEST_KEYS
}
copy_modsecfile () {
  cp -f $DIRS/$MODSCONF $DEST_MODS
}
copy_custconf () {
  cp -f $DIRS/$CUSTCONF $DEST_CUST
}

## main

if [ `ls -l /var/tmp/sample.* 2>/dev/null | wc -l` -gt 2 ]; then
    echo "Config file not enough!"
  exit 1
else
  echo "Config files ok, Go ahead" && \
  cp -f $DIRS/`echo $CERTS |sed 's/\// /g' |awk '{print $3}'` $DEST_CERTS && \
  cp -f $DIRS/`echo $KEYS |sed 's/\// /g' |awk '{print $3}'` $DEST_KEYS && \
  cp -f $DIRS/`echo $MODSCONF |sed 's/\// /g' |awk '{print $2}'` $DEST_MODS && \
  cp -f $DIRS/`echo $UNICODECONF |sed 's/\// /g' |awk '{print $2}'` $DEST_MODS && \
  cp -f $DIRS/`echo $CUSTCONF |sed 's/\// /g' |awk '{print $2}'` $DEST_CUST && \
  cp -f $DIRS/`echo $UPSTREAMCONF |sed 's/\// /g' |awk '{print $2}'` $UPSTREAMDEST && \
  cp -f $DIRS/`echo $MAINCONF |sed 's/\// /g' |awk '{print $2}'` $MAINDEST && \
  echo "Ready to start Nginx!" && \
  # /etc/init.d/nginx start
  /opt/nginx/sbin/nginx -c /opt/nginx/conf/nginx.conf
fi

cd $DIRS && echo "Hello" > index,html
`nc -z -w5 $SERVER $WEBPORTS`
STATUS=$?

if [ "$STATUS" != 0 ]; then
  echo 'Starting tiny Backends on 8080'
  python -m SimpleHTTPServer 8080 &>/dev/null &disown
else
  echo 'Port 8080 already in use, quit.'
fi
