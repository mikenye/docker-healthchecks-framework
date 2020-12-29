#!/usr/bin/env bash

# get path where this script is located
SCRIPTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source "checks" functions
for i in "${SCRIPTPATH}/checks/"*.sh; do
  . "$i"
done

# source "helpers" functions
for i in "${SCRIPTPATH}/helpers/"*.sh; do
  . "$i"
done
