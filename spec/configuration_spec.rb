require 'spec_helper'


describe "configuration" do
  let(:config) { Geolocal.configuration }

  it "has the right defaults" do
    # reset the configuration so we get the default configuration,
    # not the test configuration that the spec_helper has set up.
    Geolocal.reset_configuration
    defaults = Geolocal.configuration

    # these need to match the description in the readme
    expect(defaults.provider).to eq 'Geolocal::Provider::DB_IP'
    expect(defaults.module).to   eq 'Geolocal'
    expect(defaults.file).to     eq 'lib/geolocal.rb'
    expect(defaults.tmpdir).to   eq 'tmp/geolocal'
    expect(defaults.expires).to  eq nil
    expect(defaults.ipv4).to     eq true
    expect(defaults.ipv6).to     eq true
    expect(defaults.quiet).to    eq false
    expect(defaults.countries).to eq({})
  end


  describe "reset method" do
    before :each do
      Geolocal.configure do |conf|
        conf.module = "Changed"
      end
    end

    it "resets the configuration" do
      expect(Geolocal.configuration.module).to eq "Changed"
      Geolocal.reset_configuration
      expect(Geolocal.configuration.module).to eq "Geolocal"
    end
  end


  describe "module names" do
    it "can handle typical module names" do
      module_name = "GeoRangeFinderID::QuickLook"
      Geolocal.configure do |g|
        g.module = module_name
      end

      expect(config.module).to eq module_name
      expect(config.file).to eq "lib/geo_range_finder_id/quick_look.rb"
    end

    it "can handle a pathological module name" do
      module_name = "Geolocal::Provider::DB_IP"
      Geolocal.configure do |g|
        g.module = module_name
      end

      expect(config.module).to eq module_name
      expect(config.file).to eq "lib/geolocal/provider/db_ip.rb"
    end
  end


  describe "to_hash" do
    it "can do the conversion" do
      expect(config.to_hash).to eq({
        provider: 'Geolocal::Provider::DB_IP',
        module: 'Geolocal',
        file: 'lib/geolocal.rb',
        tmpdir: 'tmp/geolocal',
        expires: nil,
        ipv4: true,
        ipv6: true,
        quiet: true,
        countries: {}
      })
    end
  end


  describe "module paths" do
    it "includes the correct provider when running as a gem" do
      expect(Kernel).to receive(:require).with('geolocal/provider/db_ip')
      config.require_provider_file
    end

    it "includes the correct provider when running locally" do
      expect(Kernel).to receive(:require).with('geolocal/provider/db_ip') { raise LoadError }
      expect(Kernel).to receive(:require).with('./lib/geolocal/provider/db_ip.rb')
      config.require_provider_file
    end
  end
end
