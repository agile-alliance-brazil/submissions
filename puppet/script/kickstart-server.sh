#!/bin/bash
set -e -x
BOOTSTRAP_URI='https://raw.github.com/dtsato/agile_brazil/master/puppet/script/server_bootstrap.sh'

export DEBIAN_FRONTEND=noninteractive
wget -O server_bootstrap.sh ${BOOTSTRAP_URI}
chmod +x server_bootstrap.sh
./server_bootstrap.sh `whoami`