# Ejabberd 14.07

FROM phusion/baseimage:0.9.14

MAINTAINER Rafael Römhild <rafael@roemhild.de>

ENV HOME /

# System update
RUN apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install wget libyaml-0-2 \
    libexpat1 erlang-nox python-jinja2 ssl-cert

# ejabberd
RUN wget -q -O /tmp/ejabberd-installer.run "http://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/14.07/ejabberd-14.07-linux-x86_64-installer.run"
RUN chmod +x /tmp/ejabberd-installer.run
RUN /tmp/ejabberd-installer.run --mode unattended --prefix /opt/ejabberd --adminpw ejabberd

# config
ADD ./ejabberd.yml.tpl /opt/ejabberd/conf/ejabberd.yml.tpl
ADD ./ejabberdctl.cfg /opt/ejabberd/conf/ejabberdctl.cfg
RUN sed -i "s/ejabberd.cfg/ejabberd.yml/" /opt/ejabberd/bin/ejabberdctl

# add ejabberd user and group
RUN groupadd -r ejabberd \
    && useradd -r -g ejabberd -d /opt/ejabberd -s /usr/sbin/nologin ejabberd
RUN mkdir /opt/ejabberd/ssl
RUN chown -R ejabberd:ejabberd /opt/ejabberd
RUN sed -i "s/root/ejabberd/g" /opt/ejabberd/bin/ejabberdctl

# add init-script
ADD bin/init-script /root/init-script

# add runit script
RUN mkdir /etc/service/ejabberd
ADD bin/ejabberd.sh /etc/service/ejabberd/run

# add ssl cert gen script
RUN mkdir -p /etc/my_init.d
ADD bin/01_generate_ssl_cert.sh /etc/my_init.d/01_generate_ssl_cert.sh

# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/opt/ejabberd/database", "/opt/ejabberd/ssl"]
EXPOSE 5222 5269 5280
CMD ["/sbin/my_init"]
