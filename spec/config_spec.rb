require "spec_helper"

describe Geocode::Static do
  it "has the right configuration defaults" do
    # these must match the values in the README
    config = Geocode::Static::Base.new.config
    expect(config.provider).to eq "Geocode::Static::DB_IP"
    expect(config.module).to   eq "Geocode"
    expect(config.file).to     eq "lib/geocode.rb"
    expect(config.tmpdir).to   eq "tmp/geocode-static"
    expect(config.expires).to  be_within(60).of(Time.now + 86400*30)
    expect(config.countries).to eq({})
  end


  describe "#configure" do
    before do
      Geocode::Static.configure do |config|
        # config.provider = Geocode::Static::Provider::Test
        config.module = "GeoRanges::Static"
      end
    end

    it "can receive new configuration" do
      config = Geocode::Static::Base.new.config
      expect(config.module).to eq "GeoRanges::Static"
    end
  end
end
