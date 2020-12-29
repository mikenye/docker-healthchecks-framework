#!/usr/bin/env bash

function check_tcp4_socket_listening() {
    # $1 = local IP
    # $2 = local port
    # ----
    
    regex_any_ip_v4or6='(([a-fA-F0-9]{0,4}\:?){2,8}|(\d{1,3}\.?){4})'
    regex_any_port='\d{1,5}'
    
    # Check local IP input
    if [[ "$1" == "ANY" ]]; then
      : # pass
    elif ! echo "$1" | grep -P "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" > /dev/null 2>&1; then
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
    
    # Prepare the remainder of the regex including the IP and port
    regex="^tcp6?\s+\d+\s+\d+\s+${regex_src_ip}:${regex_src_port}\s+${regex_any_ip_v4or6}:${regex_any_port}\s+LISTEN$"
    
    # Check to see if the connection is established
    if netstat -an | grep -P "$regex" > /dev/null 2>&1; then
      >&2 echo "Listening on $1:$2 (tcp): PASS"
      true
    else
      >&2 echo "Not listening on $1:$2 (tcp): FAIL"
      false
    fi
}

# If the script is called directly, run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  check_tcp4_socket_listening "$1" "$2"
fi
