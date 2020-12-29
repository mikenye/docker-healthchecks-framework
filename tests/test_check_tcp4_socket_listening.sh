#!/usr/bin/env bash

oneTimeSetUp() {
  set -x
  
  # build base test image
  docker build \
    -t testimage \
    -f ./tests/Dockerfile.testimage.debian \
    .
  
  # set up client container for test that should pass
  docker run \
    --rm \
    -i \
    -d \
    --name=testcontainer_pass \
    testimage
  
  # set up client container for test that should fail
  docker run \
    --rm \
    -i \
    -d \
    --name=testcontainer_fail \
    testimage
    
  # install prerequisites on client
  docker exec \
    -i \
    testcontainer_pass \
      apt-get update
  docker exec \
    -i \
    testcontainer_pass \
      apt-get install -y --no-install-recommends \
      net-tools \
      nginx \
      procps
  
  # start service
  docker exec \
    -d \
    testcontainer_pass \
    nginx
    
  sleep 3
  
  docker exec \
    -i \
    testcontainer_pass \
    ps ax
  
  # show connections
  docker exec \
    -i \
    testcontainer_pass \
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
     "declare -f check_tcp4_socket_listening"

}

test_pass() {

  set -x

  # Save the place that stdout (1) points to.
  exec 3>&1

  # Run command.  stderr is captured.
  output_pass=$(docker exec -i testcontainer_pass /workdir/checks/check_tcp4_socket_listening.sh 0.0.0.0 80 2>&1 1>&3)

  # Close FD #3.
  exec 3>&-

  set +x
  
  # connection that does exist
  assertContains \
    'listening on 0.0.0.0:80' \
    "$output_pass" \
    'PASS'

}

test_fail() {

  set -x

  # Save the place that stdout (1) points to.
  exec 3>&1

  # Run command.  stderr is captured.
  output_fail=$(docker exec -i testcontainer_fail /workdir/checks/check_tcp4_socket_listening.sh 0.0.0.0 80 2>&1 1>&3)
  
  # Close FD #3.
  exec 3>&-

  set +x

  # connection that doesn't exist
  assertContains \
    "not listening on 0.0.0.0:80" \
    "$output_fail" \
    'FAIL'
    
}

oneTimeTearDown() {
  set -x
  # clean up
  docker kill testcontainer_fail
  docker kill testcontainer_pass
  docker image rm testimage
  set +x
}

# Load shUnit2.
. /opt/shunit2/shunit2
