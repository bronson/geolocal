require "spec_helper"

describe Geocode::Static do
  # describe "it has the right defaults" do
  #   expect(config.provider).to eq Geocode::Static::Provider::DB_IP
  #   expect(config.module).to eq "Geocode"
  #   expect(config.file).to eq "
  # end

  describe "#configure" do
    before do
      Geocode::Static.configure do |config|
        # config.provider = Geocode::Static::Provider::Test
        # config.module = "GeoRanges::Static"
      end
    end

    it "can receive new configuration" do
      generator = Geocode::Static::Base.new
      # expect(generator.config[:module]).to eq "GeoRanges::Static"
    end
  end
end
