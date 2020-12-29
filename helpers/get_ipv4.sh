#!/usr/bin/env bash

function get_ipv4() {
  # $1 = IP(v4) address or hostname
  # -----
  
  # source common regexes
    SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
    . "$SCRIPTPATH/../common/common_regex_patterns.sh"
  
  if [[ -n "$1" ]]; then
    if IP=$(echo "$1" | grep -P "^${regex_any_ipv4}\$" 2> /dev/null); then
      :
      if [[ -n "$VERBOSE_LOGGING" ]]; then
        >&2 echo "DEBUG: Already IP"
      fi
    else
      
      # Attempt to resolve $1 into an IP address with dig
      if which dig > /dev/null 2>&1; then
        if IP=$(dig +short "$1" 2> /dev/null); then
          if [[ -n "$VERBOSE_LOGGING" ]]; then
            >&2 echo "DEBUG: Got IP via dig"
          fi
          echo "$IP"
          return 0
        fi
      fi
      
      # Attempt to resolve $1 into an IP address with busybox nslookup
      if which busybox > /dev/null 2>&1; then
        if IP=$(busybox nslookup "$1." | grep -A999 -m1 'Non-authoritative answer:' | grep 'Address:' | cut -d ' ' -f 2 | grep -P "^${regex_any_ipv4}\$" 2> /dev/null); then
          if [[ -n "$VERBOSE_LOGGING" ]]; then
            >&2 echo "DEBUG: Got IP via busybox nslookup"
          fi
          echo "$IP"
          return 0
        fi
      fi
    
      # Attempt to resolve $1 into an IP address with s6-dnsip4
      if which s6-dnsip4 > /dev/null 2>&1; then
        if IP=$(s6-dnsip4 "$1" 2> /dev/null); then
          if [[ -n "$VERBOSE_LOGGING" ]]; then
            >&2 echo "DEBUG: Got IP via s6-dnsip4"
          fi
          echo "$IP"
          return 0
        fi
      fi
        
      # Catch-all (maybe we were given an IP...)
      >&2 echo "DEBUG: No IPv4 address found"
      return 1
      
    fi
  else
    >&2 echo "Expected a hostname or IPv4 address."
    return 1
  fi
}

# If the script is called directly, run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  get_ipv4 "$1"
fi
