require 'spec_helper'
require 'geolocal/provider/base'


describe Geolocal::Provider::Base do
  let(:it) { described_class }
  let(:provider) { it.new }


  describe '#add_to_results' do
    it 'adds a v4 address to the results' do
      result = { 'USv4'=>[] }
      expect(
        provider.add_to_results(result, 'US', '192.168.1.3', '192.168.1.4')
      ).to eq 'USv4'
      expect(result).to eq({ "USv4" => [3232235779..3232235780] })
    end

    it 'adds a v6 address to the results' do
      result = { 'USv6'=>[] }
      expect(
        provider.add_to_results(result, 'US', '2001:400::', '2001:404::')
      ).to eq 'USv6'
      # wow, rspec bug?  this expectation causes rspec to enter an infinite loop
      # expect(result).to eq({ "USv6" => ["3232235779..3232235780,\n"] })
      expect(result).to eq({ "USv6" =>
        [42540569291614257367232052214305390592..42540569608526907424289402588481191936] })
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


  describe '#countries' do
    it 'preprocesses the countries' do
      Geolocal.configure do |config|
        config.countries = { ua: :UA, na: ['MX', 'CA', :US] }
      end

      expect(provider.countries).to eq({ 'na' => Set['CA', 'MX', 'US'], 'ua' => Set['UA'] })
    end

    it 'preprocesses countries with an odd name' do
      Geolocal.configure do |config|
        config.countries = { 'U s-a': 'US', 'Mex': 'MX' }
      end

      expect(provider.countries).to eq({ 'mex' => Set['MX'], 'u_s_a' => Set['US'] })
    end

    it 'refuses invalid identifiers' do
      Geolocal.configure do |config|
        config.countries = { '1nation': 'US' }
      end

      expect { provider.countries }.to raise_error(/invalid identifier/)
    end
  end


  describe '#coalesce_ranges' do
    it 'can coalesce some ranges' do
      expect(provider.coalesce_ranges([1..2, 3..4])).to eq [1..4]
      expect(provider.coalesce_ranges([8..9, 6..7])).to eq [6..9]
      expect(provider.coalesce_ranges([1..2, 4..5])).to eq [1..2, 4..5]
      expect(provider.coalesce_ranges([7..9, 0..2])).to eq [0..2, 7..9]
      expect(provider.coalesce_ranges([1..1, 2..2])).to eq [1..2]
      expect(provider.coalesce_ranges([3..3, 1..1])).to eq [1..1, 3..3]
      expect(provider.coalesce_ranges([1..2, 3..4, 2..6, 6..8, 8..9])).to eq [1..9]
    end

    it 'can coalesce some oddball cases' do
      expect(provider.coalesce_ranges([])).to eq []
      expect(provider.coalesce_ranges([1..1])).to eq [1..1]
    end

    it 'can coalesce some questionable ranges' do
      expect(provider.coalesce_ranges([1..2, 2..4])).to eq [1..4]
      expect(provider.coalesce_ranges([1..8, 2..9])).to eq [1..9]
      expect(provider.coalesce_ranges([2..4, 1..2])).to eq [1..4]
      expect(provider.coalesce_ranges([2..9, 1..8])).to eq [1..9]
    end
  end


  describe 'generating' do
    let(:example_results) { {
      'USv4' => [0..16777215, 34603520..34604031, 34605568..34606591],
      'USv6' => [0..42540528726795050063891204319802818559,
                42540569291614257367232052214305390592..42540570559264857595461453711008595967]
    } }

    before do
      Geolocal.configure do |config|
        config.countries = { 'US': 'US' }
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
end
