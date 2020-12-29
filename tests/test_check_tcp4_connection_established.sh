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
      net-tools \
      procps
  
  # make a connection
  docker exec \
    -d \
    testclient \
    nc -4 --no-shutdown testserver 6379
    
  sleep 3
  
  docker exec \
    -i \
    testclient \
    ps ax
  
  # show connections
  docker exec \
    -i \
    testclient \
    netstat -an
  
  set +x
}

test_function_sourced_ok() {
   
   # source the healthchecks functions
   . ./healthchecks.sh
   
   # ensure this function is available
   assertContains \
     "ensure the function can be sourced via healthchecks.sh" \
     "$(declare -F)" \
     "declare -f check_tcp4_connection_established"

}

test_pass() {

  set -x

  # Save the place that stdout (1) points to.
  exec 3>&1

  # Run command.  stderr is captured.
  output_pass=$(docker exec -i testclient /workdir/checks/check_tcp4_connection_established.sh ANY ANY 172.28.3.10 6379 2>&1 1>&3)

  # Close FD #3.
  exec 3>&-

  set +x
  
  # connection that does exist
  assertContains \
    'connection that does exist' \
    "$output_pass" \
    'PASS'
  
}

test_fail() {

  set -x

  # Save the place that stdout (1) points to.
  exec 3>&1

  # Run command.  stderr is captured.
  output_fail=$(docker exec -i testclient /workdir/checks/check_tcp4_connection_established.sh ANY ANY 172.28.3.10 6380 2>&1 1>&3)
  
  # Close FD #3.
  exec 3>&-

  set +x

  # connection that doesn't exist
  assertContains \
    "connection that doesn't exist" \
    "$output_fail" \
    'FAIL'
    
}

oneTimeTearDown() {
  set -x
  # clean up
  docker kill testclient
  docker kill testserver
  docker network rm testnet
  docker image rm testimage
  set +x
}

# Load shUnit2.
. /opt/shunit2/shunit2
