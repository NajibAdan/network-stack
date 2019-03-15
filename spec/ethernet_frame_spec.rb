require 'spec_helper'

require 'ethernet_frame'
require 'ip_packet'
require 'udp_datagram'
require 'utils'

RSpec.describe EthernetFrame do
  let(:frame_bytes) { File.binread(File.join(__dir__, 'fixtures/ethernet_frame.dat')).bytes }
  let(:ethernet_frame) { EthernetFrame.new(frame_bytes) }

  example 'returns the correct destination_mac' do
    expect(ethernet_frame.destination_mac).to eq('08:00:27:D7:47:6C')
  end

  example 'returns the correct source_mac' do
    expect(ethernet_frame.source_mac).to eq('0A:00:27:00:00:00')
  end

  describe 'returns the correct ip_packet' do
    let(:ip_packet) { ethernet_frame.ip_packet }

    example 'returns the correct ip version' do
      expect(ip_packet.version).to eq(4)
    end

    example '#ihl' do
      expect(ip_packet.ihl).to eq(5)
    end

    example '#dscp' do
      expect(ip_packet.dscp).to eq(0)
    end

    example '#ecn' do
      expect(ip_packet.ecn).to eq(0)
    end

    example 'returns the correct total_length' do
      expect(ip_packet.total_length).to eq(34)
    end

    example '#identification' do
      expect(ip_packet.identification).to eq(0xE142)
    end

    example 'returns the proper flags' do
      expect(ip_packet.flags).to eq(0)
    end

    example '#fragment_offset' do
      expect(ip_packet.fragment_offset).to eq(0)
    end

    example 'returns the correct time_to_live' do
      expect(ip_packet.time_to_live).to eq(64)
    end

    example 'returns the correct protocol' do
      expect(ip_packet.protocol).to eq(17)
    end

    example 'returns the expected header_checksum' do
      expect(ip_packet.header_checksum).to eq(0xD62C)
    end

    example 'returns the correct source_ip_address' do
      expect(ip_packet.source_ip_address).to eq('192.168.33.1')
    end

    example 'returns the correct destination_ip_address' do
      expect(ip_packet.destination_ip_address).to eq('192.168.33.10')
    end

    describe '#udp_datagram' do
      let(:udp_datagram) { ip_packet.udp_datagram }

      example 'returns the correct source_port' do
        expect(udp_datagram.source_port).to eq(51_261)
      end

      example 'returns the correct destination_port' do
        expect(udp_datagram.destination_port).to eq(4321)
      end

      example 'returns the correct length' do
        expect(udp_datagram.length).to eq(14)
      end

      example 'correct checksum' do
        expect(udp_datagram.checksum).to eq(0x1F7B)
      end

      example 'returns the correct body message' do
        expect(udp_datagram.body).to eq("hello\n")
      end
    end
  end
end
