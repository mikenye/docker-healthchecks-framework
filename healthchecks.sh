#!/usr/bin/env bash

# get path where this script is located
SCRIPTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source functions
. "${SCRIPTPATH}/checks/*.sh"
. "${SCRIPTPATH}/helpers/*.sh"
