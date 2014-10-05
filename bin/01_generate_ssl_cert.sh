#!/bin/bash
set -e

. /root/init-script


make_snakeoil_certificate() {
    local domain=$1
    local certfile=$2

    openssl req -subj "/CN=${domain}" \
                -new \
                -newkey rsa:2048 \
                -days 365 \
                -nodes \
                -x509 \
                -keyout /tmp/selfsigned.key \
                -out /tmp/selfsigned.crt

    echo "Writing ssl cert and private key to '${certfile}'..."
    cat /tmp/selfsigned.crt /tmp/selfsigned.key > ${certfile}
    chown ${EJABBERDUSER} ${certfile}
    rm /tmp/selfsigned.crt /tmp/selfsigned.key
}


make_host_snakeoil_certificate() {
    local domain='localhost'

    is_true ${ERLANG_NODE} \
      && domain=${HOSTNAME}

    echo -n "Missing ssl cert for your host. "
    echo "Generating snakeoil ssl cert for ${domain}..."

    make_snakeoil_certificate ${domain} ${SSLCERTHOST}
}


make_domain_snakeoil_certificate() {
    local domain='localhost'

    is_set ${XMPP_DOMAIN} \
      && domain=${XMPP_DOMAIN}

    echo -n "Missing ssl cert for your xmpp domain. "
    echo "Generating snakeoil ssl cert for ${domain}..."

    make_snakeoil_certificate ${domain} ${SSLCERTDOMAIN}
}


# generate host ssl cert if missing
file_exist ${SSLCERT_DOMAIN} \
|| make_host_snakeoil_certificate

# generate xmmp domain ssl cert if missing
file_exist ${SSLCERT_HOST} \
|| make_domain_snakeoil_certificate
