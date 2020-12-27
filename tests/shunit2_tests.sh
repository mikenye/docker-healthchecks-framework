#!/usr/bin/env bash

oneTimeSetUp() {
  set -x
  
  # build base test image
  docker build \
    -t testimage \
    -f ./tests/Dockerfile.testimage.debian \
    .
    
  # set up network for testing
  docker network create \
    --subnet=172.28.0.0/16 \
    --ip-range=172.28.5.0/24 \
    --gateway=172.28.5.254 \
    testnet
  
  # set up server container for test
  docker run \
    --rm \
    -i \
    -d \
    --name=testserver \
    --network=testnet \
    --ip="172.28.3.10" \
    --entrypoint redis-server \
    redis
  
  # set up client container for test
  docker run \
    --rm \
    -i \
    -d \
    --name=testclient \
    --network=testnet \
    --ip="172.28.4.10" \
    testimage
    
  # install prerequisites on client
  docker exec \
    -i \
    testclient \
      apt-get update
  docker exec \
    -i \
    testclient \
      apt-get install -y --no-install-recommends \
      ncat \
      net-tools
  
  # make a connection
  docker exec \
    -i \
    -d \
    testclient \
    nc testserver 6379
    
  sleep 3
  
  # show connections
  docker exec \
    -i \
    testclient \
    netstat -an
  
  set +x
}

test_check_tcp4_connection_established() {

set -x

# Save the place that stdout (1) points to.
exec 3>&1

# Run commands.  stderr is captured.
output_fail=$(docker exec -i testclient /workdir/checks/check_tcp4_connection_established.sh ANY ANY 172.28.3.10 6380 2>&1 1>&3)
output_pass=$(docker exec -i testclient /workdir/checks/check_tcp4_connection_established.sh ANY ANY 172.28.3.10 6379 2>&1 1>&3)

# Close FD #3.
exec 3>&-

set +x

  # connection that doesn't exist
  assertContains \
    "connection that doesn't exist" \
    "$output_fail" \
    'FAIL'
  
  # connection that does exist
  assertContains \
    'connection that does exist' \
    "$output_pass" \
    'PASS'
  
}

oneTimeTearDown() {
  set -x
  # clean up
  docker kill testclient
  docker kill testserver
  docker network rm testnet
  set +x
}

# Load shUnit2.
. /opt/shunit2/shunit2
