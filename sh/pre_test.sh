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
  cp $DIRS/$CERTS $DEST_CERTS && cp $DIRS/$KEYS $DEST_KEYS
}
copy_modsecfile () {
  cp $DIRS/$MODSCONF $DEST_MODS
}
## nginx
start_ngx() {
    configtest_q || exit 1
    echo -n "start nginx : "
     /etc/init.d/nginx  start
    ret=$?
    if [ $ret -eq 0 ]; then
        echo "[OK]"
    else
        echo "[NG]"
        exit $ret
    fi
}
## run at docker
run_remote() {
  sudo -s
  cp $DIRS/$CUSTCONF $DEST_CUST
  cp $DIRS/`echo $CERTS |sed 's/\// /g' |awk '{print $3}'` $DEST_CERTS
  cp $DIRS/`echo $KEYS |sed 's/\// /g' |awk '{print $3}'` $DEST_KEYS
  cp $DIRS/$MODSCONF $DEST_MODS
  /etc/init.d/nginx start
  exit
  exit
}

## main
`nc -z -w5 $SERVER $PORTS`
STATUS=$?

if [  "$STATUS" != 0 ]; then
  echo 'tcp/20022, not OPEN'
  exit 1
else
  echo "Docker Alive, Go head"
  for i in $CUSTCONF $MODSCONF $CERTS $KEYS
  do
    scp -i $PKEY -P $PORTS $i $TARGETS:$DIRS
  done && \
  ssh -i $PKEY -p $PORTS -t -t $TARGET "$(set); run_remote"
fi
