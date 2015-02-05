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

  before do
    Geolocal.configure do |config|
      config.countries = { 'us': 'US' }
    end
  end

  it 'can generate both ipv4 and ipv6' do
    io = StringIO.new
    provider.output io, example_results
    expect(io.string).to include '0..42540528726795050063891204319802818559'
    expect(io.string).to include '34605568..34606591'
  end

  it 'can turn off ipv4' do
    Geolocal.configure do |config|
      config.ipv4 = false
    end

    io = StringIO.new
    provider.output io, example_results.tap { |h| h.delete('USv4') }
    expect(io.string).to include '0..42540528726795050063891204319802818559'
    expect(io.string).not_to include '34605568..34606591'
  end

  it 'can turn off ipv6' do
    Geolocal.configure do |config|
      config.ipv6 = false
    end

    io = StringIO.new
    provider.output io, example_results.tap { |h| h.delete('USv6') }
    expect(io.string).to include '34605568..34606591'
    expect(io.string).not_to include '0..42540528726795050063891204319802818559'
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

  it 'can execute the resulting file' do
    modname = "Geolocal_#{rand(1000000)}"
    Geolocal.configure do |config|
      config.module = modname
    end

    io = StringIO.new
    provider.output io, example_results
    eval io.string
    geolocal = Module.const_get(modname)

    expect(geolocal.in_us? '2.16.13.255').to eq true
    expect(geolocal.in_us? IPAddr.new('2.16.13.255')).to eq true
    expect(geolocal.in_us? 34606591, Socket::AF_INET).to eq true
    expect(geolocal.in_us? 34606592, Socket::AF_INET).to eq nil

    expect(geolocal.in_us? '2001:400::').to eq true
    expect(geolocal.in_us? IPAddr.new('2001:400::')).to eq true
    expect(geolocal.in_us? 42540570559264857595461453711008595967, Socket::AF_INET6).to eq true
    expect(geolocal.in_us? 42540570559264857595461453711008595968, Socket::AF_INET6).to eq nil
  end
end
