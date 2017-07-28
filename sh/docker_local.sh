#!/bin/bash

## parameter
MAINCONF='nginx.conf'
MAINDEST='/opt/nginx/conf'
UPSTREAMCONF='upstreams_8080.conf'
UPSTREAMDEST='/opt/nginx/conf/upstreams'
CUSTCONF='customer.conf'
DEST_CUST='/opt/nginx/conf/customers'
MODSCONF='modsecurity_default.conf'
UNICODECONF='unicode.mapping'
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
  cp -f $DIRS/$MODSCONF $DEST_MODS && \
  cp -f $DIRS/$UNICODECONF $DEST_MODS && \
  cp -f $DIRS/$CUSTCONF $DEST_CUST && \
  cp -f $DIRS/$MAINCONF $MAINDEST && \
  cp -f $DIRS/$UPSTREAMCONF $UPSTREAMDEST && \
  echo "Ready to start Nginx!" && \
  # /etc/init.d/nginx start
  /opt/nginx/sbin/nginx -c /opt/nginx/conf/nginx.conf
fi

cd $DIR && echo "Hello" > index,html
`nc -z -w5 $SERVER $WEBPORTS`
STATUS=$?

if [ "$STATUS" != 0 ]; then
  python -m SimpleHTTPServer 8080 &
else
  echo 'Alreedy use tcp/8080'
fi
