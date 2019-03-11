# Ethernet frame
# https://en.wikipedia.org/wiki/Ethernet_frame
class EthernetFrame
  attr_reader :bytes

  def initialize(bytes)
    @bytes = bytes
  end

  # extracts the destination address
  def destination_mac
    format_mac(bytes[0, 6])
  end

  # extracts the source address
  def source_mac
    format_mac(bytes[6, 6])
  end

  # Drop the first 14 bytes (MAC Header)
  # and last 4 bytes (CRC Checksum)
  def ip_packet
    IPPacket.new(bytes.drop(14))
  end

  private

  def format_mac(mac_bytes)
    mac_bytes.map do |byte|
      byte.to_s(16).rjust(2, '0')
    end.join(':').upcase
  end
end
