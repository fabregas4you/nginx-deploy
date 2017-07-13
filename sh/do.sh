#!/bin/bash

set -eu

/root_password.sh
exec /usr/sbin/sshd -D
