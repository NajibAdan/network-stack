# utils
module Utils
  # Plucking out the fields in the header
  # combining each 16-bit word into a single integer
  def self.word16(bytes_a, bytes_b)
    (bytes_a << 8) | bytes_b
  end
end
