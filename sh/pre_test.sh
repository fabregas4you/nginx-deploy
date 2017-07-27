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
DIRS=/var/tmp
REMOTE_DOCKER="sh/docker_local.sh"

## copy files
copy_sslfiles () {
  cp $DIRS/$CERTS $DEST_CERTS && cp $DIRS/$KEYS $DEST_KEYS
}
copy_modsecfile () {
  cp $DIRS/$MODSCONF $DEST_MODS
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

if [ "$STATUS" != 0 ]; then
  echo 'tcp/20022, not OPEN'
  exit 1
else
  echo "Docker Alive, Go head"
  for i in $MAINCONF $UPSTREAMCONF $CUSTCONF $MODSCONF $CERTS $KEYS $REMOTE_DOCKER $UNICODECONF
  do
    scp -i $PKEY -P $PORTS $i $TARGETS:$DIRS
  done
fi
