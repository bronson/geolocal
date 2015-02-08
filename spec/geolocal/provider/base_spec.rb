require 'spec_helper'
require 'geolocal/provider/base'


describe Geolocal::Provider::Base do
  let(:it) { described_class }
  let(:provider) { it.new }

  let(:example_results) { {
    'USv4' => "0..16777215,\n34603520..34604031,\n34605568..34606591,\n",
    'USv6' => "0..42540528726795050063891204319802818559,\n" +
              "42540569291614257367232052214305390592..42540570559264857595461453711008595967,\n"
  } }


  describe '#add_to_results' do
    it 'adds to results' do
      result = { 'USv4'=>[] }
      expect(
        provider.add_to_results(result, 'US', '192.168.1.3', '192.168.1.4')
      ).to eq 'USv4'
      expect(result).to eq({ "USv4" => ["3232235779..3232235780,\n"] })

      expect(
        provider.add_to_results({'USv6'=>[]}, 'US', '2001:400::', '2001:404::')
      ).to eq 'USv6'
    end

    it 'complains if given a bad range' do
      expect {
        provider.add_to_results({}, 'US', '192.168.1.5', '192.168.1.4')
      }.to raise_error(/wrong order: 192.168.1.5\.\.192.168.1.4/)
    end

    it 'complains if given an illegal address' do
      expect {
        provider.add_to_results({}, 'US', 'dog', 'cat')
      }.to raise_error(/invalid address/)
    end

    it 'complains if given non-matching addresses' do
      expect {
        provider.add_to_results({}, 'US', '192.168.1.5', '2001:400::')
      }.to raise_error(/must be in the same address family/)
    end
  end


  before do
    Geolocal.configure do |config|
      config.countries = { 'us': 'US' }
    end
  end

  it 'can generate both ipv4 and ipv6' do
    Geolocal.configure do |config|
      config.module = 'Geolocal_v4v6'
    end

    io = StringIO.new
    provider.output io, example_results
    expect(io.string).to include '0..42540528726795050063891204319802818559'
    expect(io.string).to include '34605568..34606591'

    eval io.string
    expect(Geolocal_v4v6.in_us? '2.16.13.255').to eq true
    expect(Geolocal_v4v6.in_us? IPAddr.new('2.16.13.255')).to eq true
    expect(Geolocal_v4v6.in_us? 34606591, Socket::AF_INET).to eq true
    expect(Geolocal_v4v6.in_us? 34606592, Socket::AF_INET).to eq nil

    expect(Geolocal_v4v6.in_us? '2001:400::').to eq true
    expect(Geolocal_v4v6.in_us? IPAddr.new('2001:400::')).to eq true
    expect(Geolocal_v4v6.in_us? 42540570559264857595461453711008595967, Socket::AF_INET6).to eq true
    expect(Geolocal_v4v6.in_us? 42540570559264857595461453711008595968, Socket::AF_INET6).to eq nil
  end

  it 'can turn off ipv4' do
    Geolocal.configure do |config|
      config.ipv4 = false
      config.module = 'Geolocal_v6'
    end

    io = StringIO.new
    provider.output io, example_results.tap { |h| h.delete('USv4') }
    expect(io.string).to include '0..42540528726795050063891204319802818559'
    expect(io.string).not_to include '34605568..34606591'

    eval io.string
    expect{ Geolocal_v6.in_us? '2.16.13.255' }.to raise_error(/ipv4 was not compiled in/)
    expect( Geolocal_v6.in_us? '2001:400::'  ).to eq true
  end

  it 'can turn off ipv6' do
    Geolocal.configure do |config|
      config.ipv6 = false
      config.module = 'Geolocal_v4'
    end

    io = StringIO.new
    provider.output io, example_results.tap { |h| h.delete('USv6') }
    expect(io.string).to include '34605568..34606591'
    expect(io.string).not_to include '0..42540528726795050063891204319802818559'

    eval io.string
    expect{ Geolocal_v4.in_us? '2001:400::'  }.to raise_error(/ipv6 was not compiled in/)
    expect( Geolocal_v4.in_us? '2.16.13.255' ).to eq true
  end

  it 'can turn off both ipv4 and ipv6' do
    Geolocal.configure do |config|
      config.ipv4 = false
      config.ipv6 = false
    end

    io = StringIO.new
    provider.output io, example_results.tap { |h| h.delete('USv4'); h.delete('USv6') }
    expect(io.string).not_to include '34605568..34606591'
    expect(io.string).not_to include '0..42540528726795050063891204319802818559'
  end
end
