#!/bin/bash
set -e

. /root/init-script


make_config() {
    echo "Generating ejabberd config file..."
    cat ${CONFIGTEMPLATE} | \
    python -c "import sys; import os; import jinja2; sys.stdout.write(jinja2.Template(sys.stdin.read()).render(env=os.environ))" \
    > ${CONFIGFILE}
}


set_erlang_node() {
    echo "Set erlang node to ${HOSTNAME}..."
    echo "ERLANG_NODE=ejabberd@${HOSTNAME}" >> ${CTLCONFIGFILE}
}

set_erlang_cookie() {
    echo "Set erlang cookie to ${ERLANG_COOKIE}..."
    chmod u+w ${ERLANGCOOKIEFILE}
    echo ${ERLANG_COOKIE} > ${ERLANGCOOKIEFILE}
    chmod u-w ${ERLANGCOOKIEFILE}
}


## main

# generate config file
make_config

## environment

# set erlang node to hostname if ERLANG_NODE is true
is_true ${ERLANG_NODE} \
  && set_erlang_node

# set erlang cookie if ERLANG_COOKIE is set
is_set ${ERLANG_COOKIE} \
  && set_erlang_cookie


# run ejabberd
exec /sbin/setuser ${EJABBERDUSER} ${EJABBERDCTL} "live" 2>&1
