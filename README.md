# mikenye/docker-healthchecks-framework

This set of scripts provide a framework for creating simple and reliable healthcheck scripts for Docker containers.

* [mikenye/docker-healthchecks-framework](#mikenyedocker-healthchecks-framework)
  * [Adding to your image](#adding-to-your-image)
  * [Adding to your healthcheck script](#adding-to-your-healthcheck-script)
  * [Checks](#checks)
    * [`check_tcp4_connection_established`](#check_tcp4_connection_established)
    * [`check_udp4_connection_established`](#check_udp4_connection_established)
    * [`check_tcp4_socket_listening`](#check_tcp4_socket_listening)
    * [`check_udp4_socket_listening`](#check_udp4_socket_listening)
  * [Helpers](#helpers)
    * [`get_ipv4`](#get_ipv4)

## Adding to your image

Clone the repository, and if desired delete files/directories not required, as-per the example below.

```shell
    # Deploy healthchecks framework
    git clone \
      --depth=1 \
      https://github.com/mikenye/docker-healthchecks-framework.git \
      /opt/healthchecks-framework \
      && \
    rm -rf \
      /opt/healthchecks-framework/.git* \
      /opt/healthchecks-framework/*.md \
      /opt/healthchecks-framework/tests \
      && \
```

## Adding to your healthcheck script

In your healthcheck script (which should use `bash` as an interpreter), add the following:

```bash
# Import healthchecks-framework
source /opt/healthchecks-framework/healthchecks.sh
```

You can then call the functions outlined below.

For example, to ensure a web server is listening in your container:

```bash
#!/usr/bin/env bash

# Import healthchecks-framework
source /opt/healthchecks-framework/healthchecks.sh

# Ensure web server listening
if ! check_tcp4_socket_listening ANY 80; then
    exit 1
fi

exit 0
```

You can then set this script in your `HEALTHCHECK` argument in your project's `Dockerfile`.

## Checks

### `check_tcp4_connection_established`

Checks that an IPv4 TCP connection is established.

**Dependencies:**

* `netstat`
  * Provided by the `net-tools` package on Debian/Ubuntu

**Syntax:**

```shell
check_tcp4_connection_established local_ip local_port remote_ip remote_port
```

**Arguments:**

* `local_ip`: The IPv4 address of the local side of the connection, or `ANY`.
* `local_port`: The TCP port of the local side of the connection, or `ANY`.
* `remote_ip`: The IPv4 address of the remote side of the connection, or `ANY`.
* `remote_port`: The TCP port of the remote side of the connection, or `ANY`.

**Example 1:**

Checks to ensure a connection to an external MariaDB database server is always established:

```shell
check_tcp4_connection_established ANY ANY 1.2.3.4 3306
```

**Example 2:**

Check to ensure at least one inbound OpenVPN connecton is always established:

```shell
check_tcp4_connection_established ANY 443 ANY ANY
```

**Example 3:**

Combined usage with `get_ipv4` to resolve a linked container name (in the example below, the container is named "mariadb") to an IP:

```shell
check_tcp4_connection_established ANY ANY $(get_ipv4 mariadb) 3306
```

### `check_udp4_connection_established`

Checks that an IPv4 UDP connection is established.

**Dependencies:**

* `netstat`
  * Provided by the `net-tools` package on Debian/Ubuntu

**Syntax:**

```shell
check_udp4_connection_established local_ip local_port remote_ip remote_port
```

**Arguments:**

* `local_ip`: The IPv4 address of the local side of the connection, or `ANY`.
* `local_port`: The UDP port of the local side of the connection, or `ANY`.
* `remote_ip`: The IPv4 address of the remote side of the connection, or `ANY`.
* `remote_port`: The UDP port of the remote side of the connection, or `ANY`.

**Example 1:**

Checks to ensure a connection to an external RTP server is always established:

```shell
check_udp4_connection_established ANY ANY 1.2.3.4 5234
```

**Example 2:**

Combined usage with `get_ipv4` to resolve a linked container name (in the example below, the container is named "rtmpserver") to an IP:

```shell
check_udp4_connection_established ANY ANY $(get_ipv4 rtmpserver) 5234
```

### `check_tcp4_socket_listening`

Checks that an IPv4 TCP socket is listening.

**Dependencies:**

* `netstat`
  * Provided by the `net-tools` package on Debian/Ubuntu

**Syntax:**

```shell
check_tcp4_socket_listening local_ip local_port
```

**Arguments:**

* `local_ip`: The local IPv4 address the service is listening on, or `ANY`.
* `local_port`: The local TCP port the service is listening on, or `ANY`.

**Example 1:**

Checks to ensure a web server is always listening on `0.0.0.0:80`:

```shell
check_tcp4_socket_listening 0.0.0.0 80
```

**Example 2:**

Check to ensure a database server is always listening on `127.0.0.1:3306`:

```shell
check_tcp4_socket_listening 127.0.0.1 3306
```

### `check_udp4_socket_listening`

Checks that an IPv4 UDP socket is listening.

**Dependencies:**

* `netstat`
  * Provided by the `net-tools` package on Debian/Ubuntu

**Syntax:**

```shell
check_udp4_socket_listening local_ip local_port
```

**Arguments:**

* `local_ip`: The local IPv4 address the service is listening on, or `ANY`.
* `local_port`: The local UDP port the service is listening on, or `ANY`.

**Example 1:**

Checks to ensure an RTP server is always listening on `0.0.0.0:5234`:

```shell
check_udp4_socket_listening 0.0.0.0 5234
```

## Helpers

### `get_ipv4`

Resolves a host/container to an IPv4 address.

**Dependencies:**

One of the following:

* `dig`
  * Provided by the `dnsutils` package on Debian/Ubuntu
* `busybox`
  * Provided by the `busybox` package on Debian/Ubuntu
* `s6-dnsip4`
  * Provided by s6-overlay

**Syntax:**

```shell
get_ipv4 host
```

**Arguments:**

* `host`: Hostname, container name, FQDN or IPv4 address.

**Example 1:**

Combined usage with `check_tcp4_connection_established` to resolve a linked container name (in the example below, the container is named "mariadb") to an IP:

```shell
check_tcp4_connection_established ANY ANY $(get_ipv4 mariadb) 3306
```
