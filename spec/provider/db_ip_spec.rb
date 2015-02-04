require 'spec_helper'
require 'geolocal/provider/db_ip'

describe Geolocal::Provider::DB_IP do
  let(:it) { described_class }
  let(:provider) { it.new }

  describe 'network operation' do
    before do
      country_page = <<-eol
        <div class="container">
          <h3>Free database download</h3>
          <a href='http://download.db-ip.com/free/dbip-country-2015-02.csv.gz' class='btn btn-primary'>Download free IP-country database</a> (CSV, February 2015)
        </div>
      eol

      country_csv = <<-eol.gsub(/^\s*/, '')
        "0.0.0.0","0.255.255.255","US"
        "1.0.0.0","1.0.0.255","AU"
        "1.0.1.0","1.0.3.255","CN"
      eol

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

    it 'can download the csv' do
      provider.download
    end
  end
end
