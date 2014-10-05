# docker-ejabberd

[Ejabberd][ejabberd] server version 14.07 with SSL, internal and anonymous auth enabled by default. To control the XMPP server, register an admin user 'admin@\<domain\>' with your prefered XMPP client. You can change the default domain `localhost` and other settings through [environment variables](#environment-variables-runtime-configuration).

This branch is base on the [phusion-baseimage][phusion-baseimage] and tagged as `phusion` on the docker registry.

[ejabberd]: http://ejabberd.im
[phusion-baseimage]: https://github.com/phusion/baseimage-docker

## Usage

### Run in foreground

```
$ docker run -i -P rroemhild/ejabberd:phusion
```

### Run in background

```
$ docker run -d -i -p 5222:5222 -p 5269:5269 -p 5280:5280 rroemhild/ejabberd:phusion
```

### Run with erlang shell

Set the `-t` (Allocate a pseudo-TTY) option to write into the erlang shell.

```
$ docker run -i -t -p 5222:5222 -p 5269:5269 -p 5280:5280 rroemhild/ejabberd:phusion
```

### Run using fig

```yaml
xmpp:
  image: rroemhild/ejabberd:phusion
  environment:
    ERL_OPTIONS: "-noshell" # Avoid attaching a shell, which requires STDIN to be attached, which `fig up` does not do. See https://github.com/docker/fig/issues/480.
```


### Using your ssl certificates

TLS is enabled by default and the run script will auto-generate two snakeoil certificates during boot if you don't provide your ssl certificates.

To use your own certificates mount the volume `/opt/ejabberd/ssl` to a local directory with the `.pem` files:

* /tmp/ssl/host.pem (SERVER_HOSTNAME)
* /tmp/ssl/xmpp_domain.pem (XMPP_DOMAIN)

Make sure that the certificate and private key are in one `.pem` file. If one file is missing it will be auto-generated. I.e. you can provide your certificate for your `XMMP_DOMAIN` and use a snakeoil certificate for the `SERVER_HOSTNAME`.

## Using docker-ejabberd as base image

The image is called `rroemhild/ejabberd:phusion` and is available on the Docker registry.

```
FROM rroemhild/ejabberd:phusion
ADD ./ejabberd.yml.tpl /opt/ejabberd/conf/ejabberd.yml.tpl
```

If you need root privileges switch to `USER root` and go back to `USER ejabberd` if you're done.

## TLS

TLS is enabled by default. If you don't provide your own certificate this image generates a self-signed snaikoil certificate on boot. If you want to use your own certifcate use the `/opt/ejabberd/ssl` export and copy your cert and key into `cert.pem`.

```
$ mkdir -p /tmp/ejabberd/ssl
$ touch /tmp/ejabberd/ssl/cert.pem
$ cat yourcert.crt >> /tmp/ejabberd/ssl/cert.pem
$ cat yourcert.key >> /tmp/ejabberd/ssl/cert.pem
```

```
$ docker run -i -P -v /tmp/ejabberd/ssl:/opt/ejabberd/ssl rroemhild/ejabberd:phusion
```

## Environment variables / Runtime configuration

You can additionally provide extra runtime configuration in a downstream image by replacing the config template `ejabberd.yml.tpl` with one based on this image's template and include extra interpolation of environment variables. The template is parsed by Jinja2 with the runtime environment (equivalent to Python's `os.environ` available as `env`).

### XMPP domain

By default the container will serve the XMPP domain `localhost`. In order to serve a different domain at runtime, provide the `XMPP_DOMAIN` variable as such:

```
$ docker run -i -P -e "XMPP_DOMAIN=foo.com" rroemhild/ejabberd:phusion
```

### Loglevel

By default the loglevel is set to INFO (4). To set another loglevel provide the `LOGLEVEL` variable as such:

```
$ docker run -i -P -e "LOGLEVEL=5" rroemhild/ejabberd:phusion
```

```
loglevel: Verbosity of log files generated by ejabberd.
0: No ejabberd log at all (not recommended)
1: Critical
2: Error
3: Warning
4: Info
5: Debug
```

### Erlang node

By devault the erlang node is set to localhost. If you want so set the erlang node to the hostname provide the `ERLANG_NODE` variable such as:

```
$ docker run -i -P -e "ERLANG_NODE=true" rroemhild/ejabberd:phusion
```

### Erlang cookie

By default the erlang cookie is generated when ejabberd starts and can't find the `.erlang.cookie` file in $HOME. To set your own cookie provide the `ERLANG_COOKIE` variable such as:

```
$ docker run -i -P -e "ERLANG_COOKIE=YOURERLANGCOOKIE" rroemhild/ejabberd:phusion
```

## Stop ejabberd in attached mode

If you run this image in foreground you can terminate it with `ctrl+c`.

## Exposed ports

* 5222
* 5269
* 5280

## Exposed volumes

* /opt/ejabberd/database
* /opt/ejabberd/ssl
