#!/usr/bin/env bash

oneTimeSetUp() {
  
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
  
}

test_check_tcp4_connection_established() {

  # connection that doesn't exist
  assertFalse \
    "connection that doesn't exist" \
    'docker exec -i testclient bash -x /workdir/checks/check_tcp4_connection_established.sh ANY ANY 172.28.3.10 6380'
  
  # connection that does exist
  assertTrue \
    'connection that does exist' \
    'docker exec -i testclient bash -x /workdir/checks/check_tcp4_connection_established.sh ANY ANY 172.28.3.10 6379'
  
}

oneTimeTearDown() {

  # clean up
  docker kill testclient
  docker kill testserver
  docker network rm testnet

}

# Load shUnit2.
. /opt/shunit2/shunit2
