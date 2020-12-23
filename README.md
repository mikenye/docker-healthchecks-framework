
## Checks

### `check_tcp4_connection_established`

Checks that an IPv4 TCP connection to/from the container is established.

**Dependencies:**

* `netstat`
  * Provided by the `net-tools` package on Debian/Ubuntu

**Syntax:**

```shell
check_tcp4_connection_established local_ip local_port local_ip local_port
```

**Arguments:**

* `local_ip`: The IPv4 address of the local side of the connection,or `ANY`.
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