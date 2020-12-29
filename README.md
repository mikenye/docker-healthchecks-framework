# mikenye/docker-healthchecks-framework

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
check_tcp4_connection_established ANY ANY dbhost.internal.domain 3306
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
