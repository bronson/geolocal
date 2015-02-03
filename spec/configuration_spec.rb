require 'spec_helper'


describe "configuration" do
  let(:config) { Geolocal.configuration }

  it "has the right defaults" do
    # these need to match the description in the readme
    expect(config.provider).to eq 'Geolocal::Provider::DB_IP'
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


  it "can set the module configuration" do
    Geolocal.configure do |g|
      g.module = "GeoRangeFinder::QuickLook"
    end

    expect(config.module).to eq "GeoRangeFinder::QuickLook"
    expect(config.file).to eq "lib/geo_range_finder/quick_look.rb"
  end
end
