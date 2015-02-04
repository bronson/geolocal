require 'spec_helper'
require 'geolocal/provider/db_ip'

describe Geolocal::Provider::DB_IP do
  let(:it) { described_class }
  let(:provider) { it.new }


  describe 'network operation' do
    let(:country_page) {
      <<-eol
        <div class="container">
          <h3>Free database download</h3>
          <a href='http://download.db-ip.com/free/dbip-country-2015-02.csv.gz' class='btn btn-primary'>Download free IP-country database</a> (CSV, February 2015)
        </div>
      eol
    }

    # todo: would be nice to test returning lots of little chunks
    let(:country_csv) {
      <<-eol.gsub(/^\s*/, '')
        "0.0.0.0","0.255.255.255","US"
        "1.0.0.0","1.0.0.255","AU"
        "1.0.1.0","1.0.3.255","CN"
      eol
    }

    before do
      stub_request(:get, 'https://db-ip.com/db/download/country').
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: country_page, headers: {})

      stub_request(:get, "http://download.db-ip.com/free/dbip-country-2015-02.csv.gz").
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => country_csv, :headers => {'Content-Length' => country_csv.length})

      # disable progress information
      allow(provider).to receive(:puts)
      allow(provider).to receive(:print)
    end

    # wow!!  can't use an around hook because it gets the ordering completely wrong
    # (documentation: "before/after(:each) hooks are wrapped by the around hook"  http://www.relishapp.com/rspec/rspec-core/v/2-0/docs/hooks/around-hooks)
    # Or, a better way of saying it: around hooks can't rely on before hooks to clean up.
    #
    # this causes:
    # - reset (global before hook)
    # - b sets its config
    # - b runs
    # - a's around hook enters (using b's config!!)
    # - reset (global before hook)
    # - then of course a runs and its around hook exits

    around(:each) do |example|
      if File.exist?(provider.csv_file)
        File.delete(provider.csv_file)
      end
      example.run
      File.delete(provider.csv_file)
    end

    it 'can download the csv' do
      provider.download
      expect(File.read provider.csv_file).to eq country_csv
    end
  end


  describe 'generating' do
    it 'can generate countries from a csv' do
      Geolocal.configure do |config|
        config.tmpdir = 'spec/data'
        config.countries = { us: 'US', au: 'AU' }
      end
      provider.update
    end
  end
end
