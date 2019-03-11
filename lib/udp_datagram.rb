# UDPdatagram structure
class UDPDatagram
  attr_reader :bytes

  def initialize(bytes)
    @bytes = bytes
  end

  def source_port
    word16(bytes[0], bytes[1])
  end

  def destination_port
    word16(bytes[2], bytes[3])
  end

  def length
    word16(bytes[4], bytes[5])
  end

  def checksum
    word16(bytes[6], bytes[7])
  end

  # Plucking out the fields in the header
  # combining each 16-bit word into a single integer
  def word16(bytes_a, bytes_b)
    (bytes_a << 8) | bytes_b
  end

  def body
    bytes[8, (length - 8)].pack('C*')
  end
end
