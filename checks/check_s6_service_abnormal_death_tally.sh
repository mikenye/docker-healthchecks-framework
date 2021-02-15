#!/usr/bin/env bash

function check_s6_service_abnormal_death_tally() {
    # $1 = service name
    # $2 = path to service dir
    # ----
    
    # If path to service dir has been given, use that instead of default
    if [[ -n "$2" ]]; then
      S6_SERVICE_PATH="$2"
    else
      S6_SERVICE_PATH="/run/s6/services"
    fi

    # Check to ensure service path is present
    if [[ -d "$S6_SERVICE_PATH" ]]; then
      : # pass
    else
      >&2 echo "Service directory $S6_SERVICE_PATH does not exist. FAIL"
      return 1
    fi

    # If all services are to be checked, get a list of services
    if [[ "$1" == "ALL" ]]; then
      S6_SERVICES=( $(ls "$S6_SERVICE_PATH") )
    else
      S6_SERVICES=( "$1" )
    fi

    # Remove s6-services from list of services checked
    S6_SERVICES=( ${S6_SERVICES[@]/s6-fdholderd/} )

    # For each service...
    for service in "${S6_SERVICES[@]}"; do

        # Get number of non-zero service exits
        returnvalue=$(s6-svdt \
                        -s "$S6_SERVICE_PATH/$service" | \
                        grep -cv 'exitcode 0')

        # Reset service death counts
        s6-svdt-clear "$S6_SERVICE_PATH/$service"

        # Log healthy/unhealthy and exit abnormally if unhealthy
        if [[ "$returnvalue" -eq "0" ]]; then
            >&2 echo "Abnormal death count for s6 service $service is $returnvalue: PASS"
            true
        else
            >&2 echo "Abnormal death count for s6 service $service is $returnvalue: FAIL"
            false
        fi
    done

}

# If the script is called directly, run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  check_s6_service_abnormal_death_tally "$1" "$2"
fi
