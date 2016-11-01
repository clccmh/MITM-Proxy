
require 'arp_scan'
require 'socket'

arp_hosts = ARPScan('--localnet').hosts
arp_ips = arp_hosts.collect {|x| x.ip_addr}
puts 'ARP IPs'
puts arp_ips

puts 'My IPs'
Socket.ip_address_list.each{|x| puts x.ip_address}

Socket.ip_address_list.each do |addr|
  if arp_ips.include? addr.ip_address
    @my_ip = addr.ip_address
  end
end

puts @my_ip

