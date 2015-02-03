require 'spec_helper'
require 'geolocal/provider/db_ip'

describe Geolocal::Provider::DB_IP do
  let(:it) { described_class }
  let(:provider) { it.new }

  describe 'network operation' do
    before do
      download_country_body = <<-eol
        <div class="container">
          <h3>Free database download</h3>
          <a href='http://download.db-ip.com/free/dbip-country-2015-02.csv.gz' class='btn btn-primary'>Download free IP-country database</a> (CSV, February 2015)
        </div>
      eol

      stub_request(:get, 'https://db-ip.com/db/download/country').
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: download_country_body, headers: {})
    end

    it 'can download the csv' do
      provider.download
    end
  end
end
