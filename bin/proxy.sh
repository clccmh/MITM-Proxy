#!/bin/bash
sudo ruby ../lib/arp_spoof.rb $1 &
ruby ../lib/http_proxy.rb 8000

