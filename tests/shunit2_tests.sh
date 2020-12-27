#!/usr/bin/env bash

oneTimeSetUp() {
  
  # build base test image
  docker build \
    -t testimage \
    -f ./tests/Dockerfile.testimage.debian \
    . > /dev/null 2>&1
  
}

test_check_tcp4_connection_established() {

  # set up network for testing
  docker network create \
    --subnet=172.28.0.0/16 \
    --ip-range=172.28.5.0/24 \
    --gateway=172.28.5.254 \
    testnet > /dev/null 2>&1
  
  # set up server container for test
  docker run \
    --rm \
    -i \
    -d \
    --name=testserver \
    --network=testnet \
    --ip="172.28.3.10" \
    --entrypoint redis-server \
    redis > /dev/null 2>&1
  
  # set up client container for test
  docker run \
    --rm \
    -i \
    -d \
    --name=testclient \
    --network=testnet \
    --ip="172.28.4.10" \
    testimage > /dev/null 2>&1
    
  # install prerequisites on client
  docker exec \
    -i \
    testclient \
      apt-get update > /dev/null 2>&1
  docker exec \
    -i \
    testclient \
      apt-get install -y --no-install-recommends \
      ncat \
      net-tools > /dev/null 2>&1
  
  # before making connection
  assertFalse \
    'before making connection' \
    'docker exec -i testclient bash -x /workdir/checks/check_tcp4_connection_established.sh ANY ANY 172.28.3.10 6379'
    
  # make a connection
  docker exec \
    -i \
    -d \
    testclient \
    nc testserver 6379 > /dev/null 2>&1
    
  # netstat output
  docker exec \
    -i \
    -d \
    testclient \
    netstat -an
  
  # after making connection
  assertTrue \
    'after making connection' \
    'docker exec -i testclient bash -x /workdir/checks/check_tcp4_connection_established.sh ANY ANY 172.28.3.10 6379'
    
  # clean up
  docker kill testclient > /dev/null 2>&1
  docker kill testserver > /dev/null 2>&1
  docker network rm testnet > /dev/null 2>&1
  
}

# Load shUnit2.
. /opt/shunit2/shunit2
