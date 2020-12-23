#!/usr/bin/env bash

function check_tcp4_connection_established() {
    # $1 = source IP
    # $2 = source port
    # $3 = destination IP
    # $4 = destination port
    # ——
    
    # Check source IP input
    if [[ "$1" == "ANY" ]]; then
      : # pass
    elif ! echo "$1" | grep -P "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" > /dev/null 2>&1; then
      >&2 echo "Expected source IPv4 address or 'ANY'. Given '$1': FAIL"
      return 1
    fi
    
    # Check source port input
    if [[ "$2" == "ANY" ]]; then
      : # pass
    elif [[ "$2" -lt 1 ]] || [[ "$2" -gt 65535 ]]; then
      echo "Expected source TCP port or 'ANY'. Given '$2': FAIL"
      return 1
    fi
    
    # Check destination IP input
    if [[ "$3" == "ANY" ]]; then
      : # pass
    elif ! echo "$3" | grep -P "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" > /dev/null 2>&1; then
      >&2 echo "Expected destination IPv4 address or 'ANY'. Given '$3': FAIL"
      return 1
    fi
    
    # Check destination port input
    if [[ "$4" == "ANY" ]]; then
      : # pass
    elif [[ "$4" -lt 1 ]] || [[ "$4" -gt 65535 ]]; then
      echo "Expected destination TCP port or 'ANY'. Given '$4': FAIL"
      return 1
    fi
    
    # Prepare the part of the regex pattern that has the source IP
    if [[ "$1" == "ANY" ]]; then
      regex_src_ip="\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
    else
      regex_src_ip=$(echo "$1" | sed 's/\./\\./g')
    fi
    
    # Prepare the part of the regex pattern that has the source port
    if [[ "$2" == "ANY" ]]; then
      regex_src_port="\d{1,5}"
    else
      regex_src_port="$2"
    fi
    
    # Prepare the part of the regex pattern that has the destination IP
    if [[ "$3" == "ANY" ]]; then
      regex_dst_ip="\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
    else
      regex_dst_ip=$(echo "$3" | sed 's/\./\\./g')
    fi
    
    # Prepare the part of the regex pattern that has the destination port
    if [[ "$4" == "ANY" ]]; then
      regex_dst_port="\d{1,5}"
    else
      regex_dst_port="$4"
    fi
    
    # Prepare the remainder of the regex including the IP and port
    regex=“^tcp\s+\d+\s+\d+\s+${regex_src_ip}:${regex_src_port}\s+${regex_dst_ip}:${regex_dst_port}\s+ESTABLISHED$”
    
    # Check to see if the connection is established
    if netstat -an | grep -P “$regex” > /dev/null 2>&1; then
      >&2 echo "Connection from $1:$2 to $3:$4 established: PASS"
      true
    else
      >&2 echo "Connection from $1:$2 to $3:$4 not established: FAIL"
      false
    fi
}

# If the script is called directly, run the function
if [[ "${#BASH_SOURCE[@]}" -eq 1 ]]; then
    check_tcp4_connection_established "$1" "$2" "$3" "$4"
fi
