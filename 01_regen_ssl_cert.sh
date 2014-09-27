#!/bin/bash
set -e

readonly CERTFILE="/opt/ejabberd/ssl/cert.pem"

if [[ ! -e $CERTFILE ]]; then
	echo "No SSL host cert available. Generating snakeoil cert..."
	export LC_ALL=C
	export DEBIAN_FRONTEND=noninteractive
	/usr/sbin/make-ssl-cert generate-default-snakeoil --force-overwrite

	touch $CERTFILE
	cat /etc/ssl/certs/ssl-cert-snakeoil.pem >> $CERTFILE
	cat /etc/ssl/private/ssl-cert-snakeoil.key >> $CERTFILE
fi
