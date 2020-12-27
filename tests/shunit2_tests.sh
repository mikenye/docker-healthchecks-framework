#!/usr/bin/env bash

oneTimeSetUp() {
  
  # build base test image
  docker build \
    -t testimage \
    -f ./tests/Dockerfile.testimage.debian \
    .
  
}

test_check_tcp4_connection_established() {

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
  
  # before making connection
  assertFalse \
    'before making connection' \
    'docker exec -i testclient bash -x /workdir/checks/check_tcp4_connection_established.sh ANY ANY 172.28.3.10 6379'
    
  # make a connection
  docker exec \
    -i \
    -d \
    testclient \
    nc -vv testserver 6379
  
  # after making connection
  assertTrue \
    'after making connection' \
    'docker exec -i testclient bash -x /workdir/checks/check_tcp4_connection_established.sh ANY ANY 172.28.3.10 6379'
    
  # clean up
  docker kill testclient
  docker kill testserver
  docker network rm testnet
  
}

# Load shUnit2.
. /opt/shunit2/shunit2
