#!/usr/bin/env bash

function get_ipv4() {
  # $1 = IP(v4) address or hostname
  # -----
  if [[ -n "$1" ]]; then
    if IP=$(echo "$1" | grep -P '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' 2> /dev/null); then
      :
      if [[ -n "$VERBOSE_LOGGING" ]]; then
        >&2 echo "DEBUG: Already IP"
      fi
    else
      if IP=$(dig +short "$1" 2> /dev/null); then
        :
        if [[ -n "$VERBOSE_LOGGING" ]]; then
            >&2 echo "DEBUG: Got IP via dig"
        fi
        
      elif IP=$(busybox nslookup "$1." | grep -A999 -m1 'Non-authoritative answer:' | grep 'Address:' | cut -d ' ' -f 2 | grep -P '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' 2> /dev/null); then
        :
        if [[ -n "$VERBOSE_LOGGING" ]]; then
            >&2 echo "DEBUG: Got IP via busybox nslookup"
        fi
    
      # Attempt to resolve $1 into an IP address with s6-dnsip4
      elif IP=$(s6-dnsip4 "$1" 2> /dev/null); then
        :
        if [[ -n "$VERBOSE_LOGGING" ]]; then
            >&2 echo "DEBUG: Got IP via s6-dnsip4"
        fi
        
      # Catch-all (maybe we were given an IP...)
      else
        >&2 echo "DEBUG: No IPv4 address found"
        return 1
      fi
      
      # Return the IP address
      echo "$IP"
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
