#!/usr/bin/env bash

# common IP address matches
regex_any_ipv4='(\d{1,3}\.?){4}'
regex_any_ipv6='([a-fA-F0-9]{0,4}\:?){2,8}'
regex_any_ip_v4or6="(${regex_any_ipv6}|${regex_any_ipv4})"

# common TCP/UDP port matches
regex_any_port='\d{1,5}'
