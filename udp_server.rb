require 'socket'
$LOAD_PATH.unshift File.join(__dir__, 'lib')

require 'utils'
require 'ethernet_frame'
require 'ip_packet'
require 'udp_datagram'

INTERFACE_NAME = 'eth1'.freeze
UDP_PORT = 4321

BUFFER_SIZE = 1024

# Size in bytes of a C `ifreq` structure
# on a 64-bit system

IFREQ_SIZE = 0x0028

# Size in bytes of the `ifr_ifindex`
# field in the `ifreq` structure

IFINDEX_SIZE = 0x0004

# Operation number to fetch the "index"
# of the interface

SIOCGIFINDEX = 0x8933

# Receive every packet
ETH_P_ALL = 0x0300

# Size in bytes of a C `sockaddr_ll` structure
# on a 64-bit system
SOCKADDR_LL_SIZE = 0x0014

# https://en.wikipedia.org/wiki/List_of_IP_protocol_numbers
UDP_PROTOCOL = 0x11

socket = Socket.open(:PACKET, :RAW)

# Convert the interface name into a string of bytes
# padded with NULL bytes to make it `IFREQ_SIZE` bytes long
ifreq = [INTERFACE_NAME].pack("a#{IFREQ_SIZE}")

# Perform the syscall
socket.ioctl(SIOCGIFINDEX, ifreq)

# Pull the bytes containing the result out of the string
# (where the `ifr_ifindex` field would be)
index = ifreq[Socket::IFNAMSIZ, IFINDEX_SIZE]

sockaddr_ll = [Socket::AF_PACKET].pack('s')
sockaddr_ll << [ETH_P_ALL].pack('s')
sockaddr_ll << index
sockaddr_ll << ("\x00" * (SOCKADDR_LL_SIZE - sockaddr_ll.length))

socket.bind(sockaddr_ll)

loop do
  data = socket.recv(BUFFER_SIZE).bytes

  frame = EthernetFrame.new(data)

  next unless frame.ip_packet.protocol == UDP_PROTOCOL &&
              frame.ip_packet.udp_datagram.destination_port == 4321

  puts '-------'
  puts 'Ethernet:'
  puts "  Source MAC: #{frame.source_mac}"
  puts "  Destination MAC: #{frame.destination_mac}"
  puts
  puts 'IP:'
  puts "  Version: #{frame.ip_packet.version}"
  puts "  IHL: #{frame.ip_packet.ihl}"
  puts "  DSCP: #{frame.ip_packet.dscp}"
  puts "  ECN: #{frame.ip_packet.ecn}"
  puts "  Total Length: #{frame.ip_packet.total_length}"
  puts "  Identification: #{frame.ip_packet.identification}"
  puts "  Flags: #{frame.ip_packet.flags}"
  puts "  Fragment Offset: #{frame.ip_packet.fragment_offset}"
  puts "  Time To Live: #{frame.ip_packet.time_to_live}"
  puts "  Protocol: #{frame.ip_packet.protocol}"
  puts "  Header Checksum: #{frame.ip_packet.header_checksum}"
  puts "  Source IP Address: #{frame.ip_packet.source_ip_address}"
  puts "  Destination IP Address: #{frame.ip_packet.destination_ip_address}"
  puts
  puts 'UDP:'
  puts "  Source Port: #{frame.ip_packet.udp_datagram.source_port}"
  puts "  Destination Port: #{frame.ip_packet.udp_datagram.destination_port}"
  puts "  Length: #{frame.ip_packet.udp_datagram.length}"
  puts "  Checksum: #{frame.ip_packet.udp_datagram.checksum}"
  puts "  Body: #{frame.ip_packet.udp_datagram.body}"
  puts

  UDPSocket.new.send(
    frame.ip_packet.udp_datagram.body.upcase,
    0,
    frame.ip_packet.source_ip_address,
    frame.ip_packet.udp_datagram.source_port
  )
end
