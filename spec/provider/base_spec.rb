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

  describe 'ipv4 option' do
    it 'can be turned off' do
      Geolocal.configure do |config|
        config.ipv4 = false
      end

      io = StringIO.new
      provider.output io, example_results
      expect(io.string).to include '0..42540528726795050063891204319802818559'
      # expect(io.string).not_to include '34605568..34606591'
    end
  end

  describe 'ipv6 option' do
    it 'can be turned off' do
      Geolocal.configure do |config|
        config.ipv6 = false
      end

      io = StringIO.new
      provider.output io, example_results
      expect(io.string).to include '34605568..34606591'
      # expect(io.string).not_to include '0..42540528726795050063891204319802818559'
    end
  end
end
