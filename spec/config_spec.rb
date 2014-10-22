require "spec_helper"


describe "configuration" do
  it "has the right defaults" do
    # these must match the values in the README
    config = Geocode::Static::Base.new.config

    expect(config.provider).to eq "Geocode::Static::DB_IP"
    expect(config.module).to   eq "Geocode"
    expect(config.file).to     eq "lib/geocode.rb"
    expect(config.tmpdir).to   eq "tmp/geocode-static"
    expect(config.expires).to  be_within(60).of(Time.now + 86400*30)
    expect(config.countries).to eq({})
  end


  it "can set the module configuration" do
    Geocode::Static.configure do |config|
      # config.provider = Geocode::Static::Provider::Test
      config.module = "GeoRanges::Quick"
    end

    config = Geocode::Static::Base.new.config
    expect(config.module).to eq "GeoRanges::Quick"
    expect(config.file).to eq "lib/geo_ranges/quick.rb"
  end


  describe "reset method" do
    before :each do
      Geocode::Static.configure do |config|
        config.module = "Changed"
      end
    end

    it "resets the configuration" do
      expect(Geocode::Static.configuration.module).to eq "Changed"
      Geocode::Static.reset_configuration
      expect(Geocode::Static.configuration.module).to eq "Geocode"
    end
  end
end
