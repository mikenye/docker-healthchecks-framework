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
  
  # set up client container for test with dig
  docker run \
    --rm \
    -i \
    -d \
    --name=testclient_dig \
    --network=testnet \
    testimage
    
  # set up client container for test with busybox
  docker run \
    --rm \
    -i \
    -d \
    --name=testclient_busybox \
    --network=testnet \
    testimage
    
  # set up client container for test with s6-overlay
  docker run \
    --rm \
    -i \
    -d \
    --name=testclient_s6 \
    --network=testnet \
    testimage
    
  # install prerequisites on testclient_dig
  docker exec \
    -i \
    testclient_dig \
      apt-get update
  docker exec \
    -i \
    testclient_dig \
      apt-get install -y --no-install-recommends \
      dnsutils
      
  # install prerequisites on testclient_busybox
  docker exec \
    -i \
    testclient_busybox \
      apt-get update
  docker exec \
    -i \
    testclient_busybox \
      apt-get install -y --no-install-recommends \
      busybox
      
  # install prerequisites on testclient_s6
  docker exec \
    -i \
    testclient_s6 \
      apt-get update
  docker exec \
    -i \
    testclient_s6 \
      apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      file \
      gnupg
  docker exec \
    -i \
    testclient_s6 \
      curl -s -o /tmp/deploy-s6-overlay.sh https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh
  docker exec \
    -i \
    testclient_s6 \
      bash /tmp/deploy-s6-overlay.sh
  
  set +x
}

test_function_sourced_ok() {
   
   # source the healthchecks functions
   . ./healthchecks.sh
   
   # ensure this function is available
   assertContains \
     "ensure the function can be sourced via healthchecks.sh" \
     "$(declare -F)" \
     "declare -f get_ipv4"

}

test_dig_stderr() {

  set -x

  # Save the place that stdout (1) points to.
  exec 3>&1

  # Run command.  stderr is captured.
  output=$(docker exec -i testclient_dig /workdir/helpers/get_ipv4.sh testserver 2>&1 1>&3)

  # Close FD #3.
  exec 3>&-

  set +x
  
  # connection that does exist
  assertEquals \
    'use dig if present' \
    "$output" \
    'DEBUG: Got IP via dig'
  
}

test_dig_stdout() {

  set -x

  output=$(docker exec -i testclient_dig /workdir/helpers/get_ipv4.sh testserver)

  set +x
  
  # connection that does exist
  assertEquals \
    'testserver resolves to 172.28.3.10' \
    "$output" \
    '172.28.3.10'
  
}

test_busybox_stderr() {

  set -x

  # Save the place that stdout (1) points to.
  exec 3>&1

  # Run command.  stderr is captured.
  output=$(docker exec -i testclient_busybox /workdir/helpers/get_ipv4.sh testserver 2>&1 1>&3)

  # Close FD #3.
  exec 3>&-

  set +x
  
  # connection that does exist
  assertEquals \
    'use busybox nslookup if present' \
    "$output" \
    'DEBUG: Got IP via busybox nslookup'
  
}

test_busybox_stdout() {

  set -x

  output=$(docker exec -i testclient_busybox /workdir/helpers/get_ipv4.sh testserver)

  set +x
  
  # connection that does exist
  assertEquals \
    'testserver resolves to 172.28.3.10' \
    "$output" \
    '172.28.3.10'
  
}

test_s6_stderr() {

  set -x

  # Save the place that stdout (1) points to.
  exec 3>&1

  # Run command.  stderr is captured.
  output=$(docker exec -i testclient_s6 /workdir/helpers/get_ipv4.sh testserver 2>&1 1>&3)

  # Close FD #3.
  exec 3>&-

  set +x
  
  # connection that does exist
  assertEquals \
    'use s6-dnsip4 if present' \
    "$output" \
    'DEBUG: Got IP via s6-dnsip4'
  
}

test_s6_stdout() {

  set -x

  output=$(docker exec -i testclient_s6 /workdir/helpers/get_ipv4.sh testserver)

  set +x
  
  # connection that does exist
  assertEquals \
    'testserver resolves to 172.28.3.10' \
    "$output" \
    '172.28.3.10'
  
}

oneTimeTearDown() {
  set -x
  # clean up
  docker kill testclient_dig
  docker kill testclient_busybox
  docker kill testclient_s6
  docker kill testserver
  docker network rm testnet
  set +x
}

# Load shUnit2.
. /opt/shunit2/shunit2
