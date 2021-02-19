#!/usr/bin/env bash

function check_tcp4_socket_listening_for_pid() {
    # $1 = local IP
    # $2 = local port
    # $3 = process PID
    # ----
    
    # source common regexes
    SCRIPTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    . "${SCRIPTPATH}/../common/common_regex_patterns.sh"
    
    # Check local IP input
    if [[ "$1" == "ANY" ]]; then
      : # pass
    elif ! echo "$1" | grep -P "${regex_any_ipv4}" > /dev/null 2>&1; then
      >&2 echo "Expected local IPv4 address or 'ANY'. Given '$1': FAIL"
      return 1
    fi
    
    # Check source port input
    if [[ "$2" == "ANY" ]]; then
      : # pass
    elif [[ "$2" -lt 1 ]] || [[ "$2" -gt 65535 ]]; then
      echo "Expected local TCP port or 'ANY'. Given '$2': FAIL"
      return 1
    fi

    # Check PID
    if [[ "$3" == "ANY" ]]; then
      : # pass
    elif [[ "$3" -lt 1 ]] || [[ "$3" -gt 4194304 ]]; then
      echo "Expected process PID or 'ANY'. Given '$3': FAIL"
      return 1
    fi
    
    # Prepare the part of the regex pattern that has the local IP
    if [[ "$1" == "ANY" ]]; then
      regex_local_ip="${regex_any_ip_v4or6}"
    else
      # regex_src_ip=$(echo "$1" | sed 's/\./\\./g')
      regex_local_ip=${1//\./\\.}
    fi
    
    # Prepare the part of the regex pattern that has the local port
    if [[ "$2" == "ANY" ]]; then  
      regex_local_port="${regex_any_port}"
    else
      regex_local_port="$2"
    fi

    # Prepare the part of the regex pattern that has the PID
    if [[ "$3" == "ANY" ]]; then
      regex_pid_process_name="${regex_netstat_connection_any_process}"
    else
      regex_pid_process_name="$3\/\S+"
    fi
       
    # Prepare the remainder of the regex including the IP and port
    regex="^tcp6?\s+\d+\s+\d+\s+${regex_local_ip}:${regex_local_port}\s+${regex_any_ip_v4or6}:\*\s+LISTEN\s+${regex_pid_process_name}\s*$"
    
    # Check to see if the connection is established
    if netstat -anp | grep -P "$regex" > /dev/null 2>&1; then
      >&2 echo "TCP4 listening on $1:$2 (tcp) for PID $3: PASS"
      true
    else
      >&2 echo "TCP4 not listening on $1:$2 (tcp) for PID $3: FAIL"
      false
    fi
}

# If the script is called directly, run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  check_tcp4_socket_listening_for_pid "$1" "$2"
fi
