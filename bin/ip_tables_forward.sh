#!/bin/bash

iptables -A FORWARD -p tcp --dport 80 -j REJECT
#iptables -t nat -A PREROUTING --dport 80 -p tcp --to-destination localhost:8000
