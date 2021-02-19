#!/usr/bin/env bash

function check_udp4_connection_established_for_pid() {
    # $1 = local IP
    # $2 = local port
    # $3 = remote IP
    # $4 = remote port
    # $5 = process PID
    # ——
    
    # source common regexes
    SCRIPTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    . "$SCRIPTPATH/../common/common_regex_patterns.sh"
    
    # Check local IP input
    if [[ "$1" == "ANY" ]]; then
      : # pass
    elif ! echo "$1" | grep -P "${regex_any_ipv4}" > /dev/null 2>&1; then
      >&2 echo "Expected local IPv4 address or 'ANY'. Given '$1': FAIL"
      return 1
    fi
    
    # Check local port input
    if [[ "$2" == "ANY" ]]; then
      : # pass
    elif [[ "$2" -lt 1 ]] || [[ "$2" -gt 65535 ]]; then
      echo "Expected local UDP port or 'ANY'. Given '$2': FAIL"
      return 1
    fi
    
    # Check remote IP input
    if [[ "$3" == "ANY" ]]; then
      : # pass
    elif ! echo "$3" | grep -P "${regex_any_ipv4}" > /dev/null 2>&1; then
      >&2 echo "Expected remote IPv4 address or 'ANY'. Given '$3': FAIL"
      return 1
    fi
    
    # Check remote port input
    if [[ "$4" == "ANY" ]]; then
      : # pass
    elif [[ "$4" -lt 1 ]] || [[ "$4" -gt 65535 ]]; then
      echo "Expected remote UDP port or 'ANY'. Given '$4': FAIL"
      return 1
    fi

    # Check PID
    if [[ "$5" == "ANY" ]]; then
      : # pass
    elif [[ "$5" -lt 1 ]] || [[ "$5" -gt 4194304 ]]; then
      echo "Expected process PID or 'ANY'. Given '$5': FAIL"
      return 1
    fi
    
    # Prepare the part of the regex pattern that has the local IP
    if [[ "$1" == "ANY" ]]; then
      regex_local_ip="${regex_any_ipv4}"
    else
      # escape periods in regex so they match periods
      regex_local_ip=${1//\./\\.}
    fi
    
    # Prepare the part of the regex pattern that has the local port
    if [[ "$2" == "ANY" ]]; then
      regex_local_port="${regex_any_port}"
    else
      regex_local_port="$2"
    fi
    
    # Prepare the part of the regex pattern that has the remote IP
    if [[ "$3" == "ANY" ]]; then
      regex_remote_ip="${regex_any_ipv4}"
    else
      # escape periods in regex so they match periods
      regex_remote_ip=${3//\./\\.}
    fi
    
    # Prepare the part of the regex pattern that has the remote port
    if [[ "$4" == "ANY" ]]; then
      regex_remote_port="${regex_any_port}"
    else
      regex_remote_port="$4"
    fi

    # Prepare the part of the regex pattern that has the PID
    if [[ "$5" == "ANY" ]]; then
      regex_pid_process_name="${regex_netstat_connection_any_process}"
    else
      regex_pid_process_name="$5\/\S+"
    fi
    
    # Prepare the remainder of the regex including the IP and port
    regex="^udp\s+\d+\s+\d+\s+${regex_local_ip}:${regex_local_port}\s+${regex_remote_ip}:${regex_remote_port}\s+ESTABLISHED\s+${regex_pid_process_name}\s*$"
    
    # Check to see if the connection is established
    if netstat -anp | grep -P "$regex" > /dev/null 2>&1; then
      >&2 echo "UDP4 connection between $1:$2 and $3:$4 for PID $5 established: PASS"
      true
    else
      >&2 echo "UDP4 connection between $1:$2 and $3:$4 not PID $5 established: FAIL"
      false
    fi
}

# If the script is called directly, run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  check_udp4_connection_established_for_pid "$1" "$2" "$3" "$4" "$5"
fi
