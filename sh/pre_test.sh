#!/bin/bash

## parameter
CUSTCONF='customer.conf'
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
configtest() {
    ${exec} -t -c ${daemon_config} 2>&1
    ret=$?
    if [ $ret -eq 0 ]; then
        echo "[OK]"
    else
        echo "[NG]"
        exit $ret
    fi
}
configtest_q() {
    configtest > /dev/null 2>&1
}
ngx_status() {
    status -p ${pidfile} ${PROG}
}
ngx_status_q() {
    ngx_status > /dev/null 2>&1
}
reload_conf() {
    ngx_status_q || exit 1
    configtest_q || exit 1
    echo -n "reload config : "
    # kill -HUP
    kill -HUP `cat ${pidfile}`
    ret=$?
    if [ $ret -eq 0 ]; then
        echo "[OK]"
    else
        echo "[NG]"
        exit $ret
    fi
}

## main
`nc -z -w5 $SERVER $PORTS`
STATUS=$?

if [  "$STATUS" != 0 ]; then
  echo 'port 20022 not OPEN'
  exit 1
else
  for i in $CUSTCONF $MODSCONF $CERTS $KEYS
  do
    scp -i $PKEY -P $PORTS $i $TARGETS:$DIRS 
  done && \
  ssh -i $PKEY -p $PORTS $TARGETS << EOF
  sudo -s;
  cp $DIRS/`echo $CERTS |sed 's/\// /g' |awk '{print $3}'` $DEST_CERTS && cp $DIRS/`echo $KEYS |sed 's/\// /g' |awk '{print $3}' $DEST_KEYS;

  cp $DIRS/$MODSCONF $DEST_MODS;
  start_ngx;
EOF
fi
