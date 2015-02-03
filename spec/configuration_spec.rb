require 'spec_helper'


describe "configuration" do
  let(:config) { Geolocal.configuration }

  it "has the right defaults" do
    # these need to match the description in the readme
    expect(config.provider).to eq Geolocal::Provider::DB_IP
    expect(config.module).to   eq 'Geolocal'
    expect(config.file).to     eq 'lib/geolocal.rb'
    expect(config.tmpdir).to   eq 'tmp/geolocal'
    expect(config.expires).to  be_within(60).of(Time.now + 86400*30)
    expect(config.ipv6).to     eq true
    expect(config.countries).to eq({})
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
end
